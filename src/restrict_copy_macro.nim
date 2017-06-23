
import macros
import strutils, boost.richstring
import options

proc isViolationCopy*(valuenode: NimNode): bool =
  if valuenode.kind == nnkEmpty: # var a: T
    return false
  elif getType(valuenode).kind == nnkBracketExpr and
      ($getType(valuenode)[0] == "ref" or $getType(valuenode)[0] == "ptr"): # var a: ref T = t
    return false
  elif valuenode.kind == nnkObjConstr: # var a = T()
    return false
  elif valuenode.kind == nnkCall and ($valuenode[0]).startsWith("init"): # init...* proc
    return false
  else:
    return true

proc checkRestrictCopy*(node: NimNode): Option[NimNode] =
  if node.kind == nnkAsgn:
    if node[1].isViolationCopy:
      return some(node)
  elif node.kind == nnkLetSection or node.kind == nnkVarSection:
    if node[0][2].isViolationCopy:
      return some(node)
  elif node.kind in AtomicNodes:
    discard
  else:
    for c in node.children:
      let res = checkRestrictCopy(c)
      if res.isSome:
        return res
  return none(NimNode)

macro restrictcopy*(procdef: typed): untyped =
  let res = checkRestrictCopy(procdef[6])
  if res.isSome:
    error fmt"`${res.get.repr}` is violation copy", res.get

#
# Example
#

type
  MyInt* = object
    x*: int
    y*: int
  PMyInt* = ref MyInt

proc `$`(mi: PMyInt): string = $mi[]

proc initMyInt*(): MyInt =
  result.x = 1
  result.y = 2
proc copyMyInt*(mi: MyInt): MyInt = mi

proc init*(mi: var MyInt) =
  mi.x = 1
  mi.y = 2

proc copyReturn*(mi: MyInt): MyInt {.restrictcopy.} =
  return mi # compile error
proc copyResult*(mi: MyInt): MyInt {.restrictcopy.} =
  result = mi # compile error

proc main() {.restrictcopy.} =
  let a = MyInt(x: 1, y: 2)
  # let acopy = a # compile error
  let b = initMyInt()
  # let bcopy = copyMyInt(b) # compile error
  var c: MyInt
  c.init()
  let d = PMyInt(x: 3, y: 4)
  let dcopy = d # works
  echo a
  # echo acopy
  echo b
  # echo bcopy
  echo c
  echo d
  echo dcopy

main()
