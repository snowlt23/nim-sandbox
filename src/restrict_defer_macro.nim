
import macros
import strutils
import options
import tables

type
  DeferContext* = ref object
    resources*: Table[string, NimNode]
  TypeName* = string
  CloseName* = string
    
var resourceTypeMap* {.compileTime.} = initTable[string, string]()
macro registerResourceType*(typename: typed, closename: untyped): untyped =
  resourceTypeMap[$typename] = $closename

proc newDeferContext*(): DeferContext =
  new result
  result.resources = initTable[string, NimNode]()

proc checkRestrictDefer*(dc: DeferContext, node: NimNode) =
  if node.kind == nnkLetSection or node.kind == nnkVarSection:
    let name = node[0][0]
    let val = node[0][2]
    let typ = val.getTypeInst()
    if resourceTypeMap.hasKey(typ.repr):
      dc.resources[$name] = val
  elif node.kind in {nnkCall, nnkCommand}:
    let name = if node[0].kind == nnkDotExpr:
                 node[0][0]
               else:
                 node[1]
    let callname = if node[0].kind == nnkDotExpr:
                     node[0][1]
                   else:
                     node[0]
    if dc.resources.hasKey($name):
      let typ = node[1].getTypeInst()
      let closename = resourceTypeMap[typ.repr]
      if $callname == closename:
        dc.resources.del($name)
  elif node.kind in AtomicNodes:
    discard
  else:
    for c in node.children:
      checkRestrictDefer(dc, c)

macro restrictdefer*(procdef: typed): untyped =
  let dc = newDeferContext()
  checkRestrictDefer(dc, procdef[6])
  for name, node in dc.resources:
    error("unclosed resource of $#: $#" % [node.getTypeInst().repr, name], node)

registerResourceType(File, close)

proc resource*() {.restrictdefer.} =
  let file = open("test.txt")
  file.write("Hello!")
