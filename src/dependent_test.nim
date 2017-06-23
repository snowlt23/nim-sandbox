
import typetraits

type
  DependArray*[N: static[int], T] = ref array[N, T]

proc newDependArray*[T](n: static[int], init: T): DependArray[n, T] =
  new result
  for i in 0..<n:
    result[i] = init

proc append*[AN: static[int], BN: static[int], T](a: DependArray[AN, T], b: DependArray[BN, T]): DependArray[AN + BN, T] =
  new result
  for i in 0..<AN:
    result[i] = a[i]
  for i in 0..<BN:
    result[AN+i] = b[i]

proc `+`*[N, T](a, b: DependArray[N, T]): DependArray[N, T] =
  new result
  for i in 0..<N:
    result[i] = a[i] + b[i]

let da1 = newDependArray(10, 1.0)
let da2 = newDependArray(5, 2.0)
let da3 = da1.append(da2)

echo type(da1).name
echo type(da2).name
echo type(da3).name

discard da1 + da1
discard da1 + da2 # compile error!
