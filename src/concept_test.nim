
type
  Countable* = concept c
    count(c) is int

proc count5[T: Countable](c: var T): int =
  discard c.count()
  discard c.count()
  discard c.count()
  discard c.count()
  return c.count()

type
  Counter* = object
    i*: int

proc count*(c: var Counter): int =
  c.i.inc
  return c.i

var c = Counter(i: 5)
var n = 5

echo count5(c)
echo count5(n)
