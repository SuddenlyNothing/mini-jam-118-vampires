extends AnimatedSprite

export(int) var speed := 100
export(int) var chase_speed := 200
export(float) var min_state_dur := 0.1
export(float) var max_state_dur := 2.0
export(float) var rot_speed := 10.0
export(int) var throw_force := 3000
export(int) var gravity := 3000

var player: Node2D
var hole_pos := Vector2()
var wander_pos := Vector2()
var throw_velocity := Vector2()
var throw_rotation := 0.0

onready var spider_states := $SpiderStates
onready var state_change_timer := $StateChangeTimer
onready var bite_free_timer := $BiteFreeTimer
onready var collision := $Area2D/CollisionShape2D


func _ready() -> void:
	Variables.rng.randomize()
	rotation = Variables.rng.randf_range(0, PI * 2)


func stop() -> void:
	collision.call_deferred("set_disabled", true)


func start(p: Node2D) -> void:
	player = p
	start_state_change_timer()
	collision.call_deferred("set_disabled", false)


func start_state_change_timer() -> void:
	Variables.rng.randomize()
	state_change_timer.start(Variables.rng.randf_range(min_state_dur,
			max_state_dur))


func enter_wander() -> void:
	randomize_wander_pos()


func enter_bite() -> void:
	Variables.rng.randomize()
	throw_velocity = Vector2.UP.rotated(Variables.rng.randf_range(
		-PI / 4, PI / 4
	)) * throw_force * Variables.rng.randf()
	throw_rotation = Variables.rng.randf_range(-5 * PI, 5 * PI)
	bite_free_timer.start()


func randomize_wander_pos() -> void:
	Variables.rng.randomize()
	wander_pos = Vector2(
		Variables.rng.randf_range(-960, 960),
		Variables.rng.randf_range(-540, 540)
	)


func move_wander(delta: float) -> void:
	var move_amount := speed * delta
	if position.distance_to(wander_pos) <= move_amount:
		position = wander_pos
		randomize_wander_pos()
	else:
		var dir := position.direction_to(wander_pos)
		face(dir, delta)
		position += dir * move_amount


func move_chase(delta: float) -> void:
	var move_amount := chase_speed * delta
	if global_position.distance_to(player.position) <= move_amount:
		global_position = player.global_position
	else:
		var dir := global_position.direction_to(player.position)
		face(dir, delta)
		global_position += dir * 	move_amount


func move_escape(delta: float) -> void:
	var move_amount := speed * delta
	if position.distance_to(hole_pos) <= move_amount:
		position = hole_pos
	else:
		var dir := hole_pos.direction_to(position)
		face(dir, delta)
		position += dir * move_amount


func move_bite(delta: float) -> void:
	throw_velocity.y += gravity * delta
	position += throw_velocity * delta
	rotation += throw_rotation * delta


func face(dir: Vector2, delta: float) -> void:
	rotation = lerp_angle(rotation, dir.angle() - PI / 2,
			min(1, rot_speed * delta))


func _on_StateChangeTimer_timeout() -> void:
	Variables.rng.randomize()
	var rand := Variables.rng.randf()
	if rand > 0.7:
		spider_states.call_deferred("set_state", "idle")
	elif rand > 0.3:
		spider_states.call_deferred("set_state", "wander")
	else:
		spider_states.call_deferred("set_state", "chase")


func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("hole"):
		hole_pos = area.position
		spider_states.call_deferred("set_state", "escape_hole")
	if area.is_in_group("hand"):
		area.get_bit()
		spider_states.call_deferred("set_state", "bite")


func _on_EscapeTimer_timeout() -> void:
	start_state_change_timer()


func _on_BiteFreeTimer_timeout() -> void:
	queue_free()
