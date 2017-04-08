
import locks, threadpool
import os, random

randomize()

var gdataUnsafe = 0

proc incdataUnsafe() {.thread.} =
  gdataUnsafe += 1
  echo gdataUnsafe

var glock: Lock
var gdataSafe {.guard: glock.} = 0

proc incdataSafe() {.thread.} =
  {.locks: [glock].}:
    gdataSafe += 1
    echo gdataSafe

echo "unsafe:"
for i in 1..10:
  spawn incdataUnsafe()
sync()

echo "safe:"
for i in 1..10:
  spawn incdataSafe()
sync()
