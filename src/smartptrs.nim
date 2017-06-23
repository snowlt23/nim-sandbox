
import macros

type
  SharedPtr*[T] = object
    count: ptr int
    data: ptr T

proc sharedptr*[T](data: T): SharedPtr[T] =
  result.count = cast[ptr int](alloc(sizeof(int)))
  result.count[] = 0
  result.data = cast[ptr T](alloc(sizeof(T)))
  result.data[] = data
proc release*[T](sp: SharedPtr[T]) =
  sp.count.dealloc()
  sp.data.dealloc()
  debugEcho "release!"
proc inc*[T](sp: SharedPtr[T]) =
  sp.count[] += 1
proc dec*[T](sp: SharedPtr[T]) =
  sp.count[] -= 1
  debugEcho "dec!"
  if sp.count[] == 0:
    sp.release()

template rewriteClone*{
  var name = sp
}[T](name: untyped, sp: SharedPtr[T]): untyped =
  debugEcho "clone"
  var name: type(sp)
  name.data = sp.data
  name.count = sp.count
  name.inc()
  defer: name.dec()

proc main() =
  var p = sharedptr 1
  var p2 = p
  echo "hello!"

main()
