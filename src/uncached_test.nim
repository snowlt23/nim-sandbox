
import benchs

type
  Vector3* = object # 16 byte
    x*, y*, z*: float32
    padding: array[4, byte]
  Actor* = object # 48 byte
    position*: Vector3
    velocity*: Vector3
    aiflags*: array[4, float32]

proc `*`*(v: Vector3, s: float32): Vector3 =
  result.x = v.x * s
  result.y = v.y * s
  result.z = v.z * s
proc `+=`*(dist: var Vector3, src: Vector3) =
  dist.x += src.x
  dist.y += src.y
  dist.z += src.z

proc updatePosition*(actor: var Actor, dt: float32) =
  actor.position += actor.velocity * dt
proc updateAi*(actor: var Actor, dt: float32) =
  for val in actor.aiflags.mitems:
    val += dt

const N = 102400

var actors: array[N, Actor]
echo "Uncached bench"
repeatbench 100:
  for actor in actors.mitems:
    actor.updatePosition(1.0'f32)
    actor.updateAi(1.0'f32)
