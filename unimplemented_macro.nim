
import macros

type UnimplementedError* = object of Exception

macro unimplementedMsg*(msg: string, procdef: untyped): untyped =
  let procname = if procdef[0].kind == nnkPostfix:
                   procdef[0][1]
                 else:
                   procdef[0]
  let procstr = newStrLitNode($procname)
  var procdefcopy = procdef.copy
  procdefcopy[6] = quote do:
    raise newException(UnimplementedError, "can't call unimplemented procedure: " & `procstr` & " " & `msg`)
  result = procdefcopy
template unimplemented*(procdef: untyped): untyped =
  unimplementedMsg(msg = "", procdef)

#
# Example
#

proc addproc*(a, b: int): int {.unimplemented.}
proc helloproc*(target: string) {.unimplementedMsg: "will be implemented in 0.2.1".}

# echo addproc(1, 2)
helloproc("world")
