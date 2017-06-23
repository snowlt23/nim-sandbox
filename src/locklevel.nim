
import locks
import threadpool

type
  SharedCounterObj* = object
    L*: Lock
    count* {.guard: L.}: int
  SharedCounter* = ptr SharedCounterObj

proc allocSharedCounter*(): SharedCounter =
  result = cast[SharedCounter](allocShared(sizeof(SharedCounterObj)))
  result.L.initLock()
  withLock result.L:
    result.count = 0
proc free*(sc: SharedCounter) =
  sc.deallocShared()

proc `+=`*(sc: SharedCounter, val: int) =
  withLock sc.L:
    sc.count += val
proc `value`*(sc: SharedCounter): int =
  withLock sc.L:
    return sc.count

proc main() =
  var sc = allocSharedCounter()
  defer: sc.free()
  for i in 0..<100:
    spawn sc += 1
  sync()
  echo sc.value

main()
