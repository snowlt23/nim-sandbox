
import macros
import boost.richstring
import options

proc checkRestrictCopy*(node: NimNode): Option[NimNode] =
  if node.kind == nnkAsgn:
    if node[1].kind != nnkObjConstr:
      return some(node)
  elif node.kind == nnkLetSection or node.kind == nnkVarSection:
    let valuenode = node[0][2]
    if valuenode.kind == nnkEmpty: # var a: T
      discard
    elif getType(valuenode).kind == nnkBracketExpr and
        ($getType(valuenode)[0] == "ref" or $getType(valuenode)[0] == "ptr"): # var a: ref T = t
      discard
    elif valuenode.kind == nnkObjConstr: # var a = T()
      discard
    else:
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

proc main() {.restrictcopy.} =
  let a = MyInt(x: 1, y: 2)
  let b = a # compile error
  let c = PMyInt(x: 3, y: 4)
  let d = c # works
  echo a
  echo b
  echo c
  echo d

main()
