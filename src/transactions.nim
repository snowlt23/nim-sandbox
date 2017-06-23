
import macros
import strutils
import random

macro transaction*(items: untyped, body: untyped): untyped =
  var prepare = newStmtList()
  var rollback = newStmtList()
  for item in items:
    var itemsym = genSym(nskVar, $item)
    prepare.add(nnkVarSection.newTree(nnkIdentDefs.newTree(itemsym, newEmptyNode(), item)))
    rollback.add(nnkAsgn.newTree(item, itemsym))
  result = quote do:
    var completed = false
    `prepare`
    try:
      `body`
      completed = true
    finally:
      if not completed:
        `rollback`
  echo result.repr

#
# Example
#

type
  Stone = int
  Items = seq[string]

let itemlist = [
  "Excalibur", "Mjollnir", "Gungnir", "Gram", "Trident"
]

proc execGacha*(items: var Items, stone: var Stone) =
  let index = random(itemlist.len()-1)
  let item = itemlist[index]
  transaction([items, stone]):
    items.add(item)
    stone -= 1
    raise newException(Exception, "unknown error!")

var items = @["Excalibur"]
var stone = 5
try:
  execGacha(items, stone)
except:
  echo "error!"
echo items
echo stone
