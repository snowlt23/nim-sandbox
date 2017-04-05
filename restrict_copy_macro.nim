
import macros
import boost.richstring
import options

proc checkRestrictCopy*(body: NimNode): Option[NimNode] =
  for b in body:
    if b.kind == nnkAsgn:
      if b[1].kind != nnkObjConstr:
        return some(b)
    elif b.kind == nnkLetSection or b.kind == nnkVarSection:
      if b[0][2].kind == nnkEmpty:
        discard
      elif b[0][2].kind != nnkObjConstr:
        return some(b)
    elif b.kind == nnkStmtList:
      let res = checkRestrictCopy(b)
      if res.isSome:
        return res
    else:
      for c in b.children:
        let res = checkRestrictCopy(c)
        if res.isSome:
          return res
  return none(NimNode)

macro restrictcopy*(procdef: untyped): untyped =
  let res = checkRestrictCopy(procdef[6])
  if res.isNone:
    return procdef
  else:
    error fmt"`${res.get.repr}` is violation copy", res.get

#
# Example
#

type
  MyInt* = object
    x*: int
    y*: int

proc main() {.restrictcopy.} =
  let a = MyInt(x: 1, y: 2)
  let b = a # compile error
  echo a
  echo b

main()
