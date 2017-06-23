
import times
import sequtils

template bench*(body) =
  let starttime = cpuTime()
  body
  let endtime = cpuTime()
  echo "Elapsed: ", endtime - starttime, "sec"
template repeatbench*(n: int, body: untyped) =
  bind foldl
  var times = newSeq[float]()
  for i in 0..<n:
    let starttime = cpuTime()
    body
    let endtime = cpuTime()
    times.add(endtime - starttime)
  echo "Elapsed average: ", times.foldl(a + b) / times.len.float, "sec"
