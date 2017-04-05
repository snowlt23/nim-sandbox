
import macros
import options

template tryout*[T](opt: Option[T]): T =
  if opt.isNone:
    return opt
  opt.get

proc helloproc*(b: bool): Option[string] =
  if b:
    some("hello")
  else:
    none(string)

proc testproc*(): Option[string] =
  let a = tryout helloproc(true)
  echo a
  let b = tryout helloproc(false)
  echo b

echo testproc()
