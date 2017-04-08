
import sequtils, threadpool, os, math, random
import times

{.experimental.}

template time*(e: typed) =
  let starttime = epochTime()
  e
  let endtime = epochTime()
  echo "epoch: " & $(endtime - starttime) & "ms"

proc pMap*[T, S](data: openArray[T], op: proc (x: T): S {.closure, thread.}): seq[S] {.inline.} =
  result = newSeq[S](data.len)
  var values = newSeq[FlowVar[S]](data.len)

  for i in 0..data.high:
    values[i] = spawn op(data[i])
  sync()

  for i in 0..data.high:
    var res = ^values[i]
    result[i] = res

proc doWork(x: int): float =
  # os.sleep(random(100))
  # echo x
  result = x.float
  for i in 0..<10000:
    result = result.sin().cos().tan()

randomize()

time:
  discard toSeq(1..10).map(doWork)
time:
  discard toSeq(1..10).pMap(doWork)

