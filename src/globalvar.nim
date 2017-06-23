
var a = 1
let b = a.addr

template c(): var int =
  b[]

echo a
echo c
c += 1
echo a
echo c
