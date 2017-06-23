
import macros
import strutils
import tables

type
  OwnerContext* = object
    movedIdents: Table[string, bool]

proc initOwnerContext*(): OwnerContext =
  result.movedIdents = initTable[string, bool]()

proc ownerEval*(oc: var OwnerContext, node: NimNode): NimNode =
  if node.kind == nnkAsgn:
    let
      name = node[0]
      val = ownerEval(oc, node[1])
    if val.kind == nnkSym or val.kind == nnkIdent:
      oc.movedIdents[$val] = true
    if name.repr == "result":
      result = parseExpr("resultOwner = $#" % val.repr)
    else:
      result = quote do:
        template `name`(): type(`val`) =
          `val`
  elif node.kind == nnkVarSection or node.kind == nnkLetSection:
    let
      name = node[0][0]
      val = ownerEval(oc, node[0][2])
      typ = if node[0][1].kind != nnkEmpty:
              node[0][1]
            else:
              parseExpr("type($#)" % val.repr)
    if val.kind == nnkSym or val.kind == nnkIdent:
      oc.movedIdents[$val] = true
      result = quote do:
        template `name`(): `typ` =
          `val`
    else:
      result = node
  elif node.kind == nnkReturnStmt:
    let val = node[0]
    result = newStmtList()
    result.add parseExpr("resultOwner = $#" % val.repr)
    result.add parseExpr("return")
  elif node.kind == nnkSym or node.kind == nnkIdent:
    if oc.movedIdents.hasKey($node):
      error("$# is moved!" % $node, node)
    result = node
  elif node.kind in AtomicNodes:
    result = node
  else:
    var comp = node.kind.newTree()
    for e in node.children:
      comp.add(ownerEval(oc, e))
    result = comp

macro ownership*(procdef: untyped): untyped =
  result = newStmtList()

  let proccopy = procdef.copy
  var oc = initOwnerContext()
  let genprocname = if procdef[0].kind == nnkPostfix:
                      ident($procdef[0][1] & "Ownership").postfix("*")
                    else:
                      ident($procdef[0] & "Ownership")
  proccopy[0] = genprocname
  if procdef[3][0].kind != nnkEmpty:
    proccopy[3].add(nnkIdentDefs.newTree(
      ident"resultOwner",
      nnkVarTy.newTree(procdef[3][0]),
      newEmptyNode(),
    ))
    proccopy[3][0] = newEmptyNode()
  proccopy[6] = ownerEval(oc, procdef[6])
  result.add(proccopy)

  let tmpldef = nnkTemplateDef.newTree(
    procdef[0],
    procdef[1],
    procdef[2],
    procdef[3],
    procdef[4],
    procdef[5],
    newStmtList(),
  )
  var genproccall = nnkCall.newTree(genprocname)
  for i in 1..<procdef[3].len:
    genproccall.add(procdef[3][i][0])
  if procdef[3][0].kind != nnkEmpty:
    genproccall.add(ident"resultOwner")
    tmpldef[6].add(parseExpr("var resultOwner: $#" % procdef[3][0].repr))
    tmpldef[6].add(genproccall)
    tmpldef[6].add(parseExpr("resultOwner"))
  else:
    tmpldef[6].add(genproccall)
  result.add(tmpldef)

  echo result.repr

# proc test() {.ownership.} =
#   var a = 1
#   var b = 2
#   b = a
#   echo a

proc calcSeq(): seq[int] {.ownership.} =
  var s =  @[1, 2, 3, 4, 5]
  result = s

proc main() {.ownership.} =
  var s = calcSeq()
  echo s

# test()
main()
