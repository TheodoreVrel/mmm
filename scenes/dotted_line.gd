extends Node2D

var a: Vector2
var b: Vector2

@export var dot_spacing := 58.0
@export var base_radius := 6.0
@export var curve_height := 220.0
@export var jitter := 2.0

var control: Vector2
var seed := randi()

var draw_progress := 0.0 # 0 = nothing drawn, 1 = full line
var draw_speed := 1.0    # fraction per second

func _process(delta):
	if draw_progress < 1.0:
		draw_progress += draw_speed * delta
		if draw_progress > 1.0:
			draw_progress = 1.0
		queue_redraw()

func setup(from: Vector2, to: Vector2):
	a = to_local(from)
	b = to_local(to)
	randomize_curve()
	queue_redraw()


func randomize_curve():
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var dir = (b - a).normalized()
	var normal = Vector2(-dir.y, dir.x)
	var mid = (a + b) / 2

	control = mid + normal * curve_height * rng.randf_range(0.6, 1.4) * randf_range(-1.1, 1.1)


func _draw():
	var steps = int(a.distance_to(b) / dot_spacing * 3)
	var max_index = int(steps * draw_progress)

	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	for i in range(max_index + 1):
		var t = i / float(steps)
		var p = bezier_point(t, a, control, b)

		p += Vector2(
			rng.randf_range(-jitter, jitter),
			rng.randf_range(-jitter, jitter)
		)

		var r = base_radius * rng.randf_range(0.7, 1.3)
	
		#var alpha = clamp((i / float(steps) - (1.0 - draw_progress)) * 10.0, 0.0, 1.0)
		#draw_circle(p, r, Color(1,1,1,alpha))
		draw_circle(p, r, Color.BISQUE)


func bezier_point(t: float, am: Vector2, c: Vector2, bm: Vector2) -> Vector2:
	var u = 1.0 - t
	return am * (u * u) + c * (2.0 * u * t) + bm * (t * t)
