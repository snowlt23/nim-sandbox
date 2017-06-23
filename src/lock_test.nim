
import locks

type
  MyData* = object
    L*: Lock
    data* {.guard: L.}: int

proc initMyData*(): MyData =
  result.L.initLock()

proc main() =
  var md = initMyData()
  withLock md.L:
    echo md.data

main()
