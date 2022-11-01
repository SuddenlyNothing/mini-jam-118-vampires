extends Area2D

export(Vector2) var end_pos
export(float) var min_speed := 150.0
export(float) var max_speed := 400.0
export(bool) var guarantee_shell := false

var speed := 0.0
var dir := Vector2()

onready var anim_sprite := $AnimatedSprite
onready var start_stop_timer := $StartStopTimer
onready var collision := $CollisionShape2D
onready var shell := $AnimatedSprite/Shell
onready var move := $Move


func _ready() -> void:
	Variables.rng.randomize()
	if Variables.rng.randf() > 0.75 or guarantee_shell:
		shell.show()
		collision.call_deferred("set_disabled", false)
	anim_sprite.play("walk")
	speed = Variables.rng.randf_range(min_speed, max_speed)
	dir = position.direction_to(end_pos)
	var dir_a := dir.angle() - PI / 2
	anim_sprite.rotation = dir_a
	collision.position = collision.position.rotated(dir_a)
	start_stop_timer.start(Variables.rng.randf_range(0.5, 4))


func _physics_process(delta: float) -> void:
	var move_amount := speed * delta
	if position.distance_to(end_pos) <= move_amount:
		queue_free()
	position += speed * delta * dir


func grab_shell() -> void:
	shell.hide()
	collision.call_deferred("set_disabled", true)


func _on_StartStopTimer_timeout() -> void:
	if anim_sprite.animation == "walk":
		anim_sprite.play("idle")
		start_stop_timer.start(Variables.rng.randf_range(0.5, 2))
		move.stream_paused = true
	else:
		move.stream_paused = false
		anim_sprite.play("walk")
		start_stop_timer.start(Variables.rng.randf_range(1, 4))
	set_physics_process(not is_physics_processing())


func _on_Hitbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("hand"):
		return
	area.get_bit()
