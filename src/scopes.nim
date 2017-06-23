
import macros
import strutils

macro scope*(resource: untyped, body: untyped): untyped =
  resource.expectKind(nnkInfix)
  if resource[0] != ident"as":
    error("unexpected infix: `$#`" % $resource[0], resource)

  let f = resource[1]
  let name = resource[2]
  result = quote do:
    var `name` = `f`
    try:
      `body`
    finally:
      `name`.close()

#
# Example
#

scope open("LICENSE") as f:
  echo f.readAll()
