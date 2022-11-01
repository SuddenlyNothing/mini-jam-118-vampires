extends Area2D

export(int) var speed := 400
export(float) var max_shake := 60.0
export(float) var return_y := 1080.0
export(int) var return_speed := 1000

var input := Vector2()

onready var shake_timer := $ShakeTimer
onready var shake_time: float = shake_timer.wait_time
onready var cs := $CollisionShape2D
onready var cs2 := $CollisionShape2D2
onready var anim_sprite := $AnimatedSprite
onready var hitbox_collision := $Hitbox/CollisionShape2D


func _process(delta: float) -> void:
	input = Input.get_vector("left", "right", "up", "down")
	if not shake_timer.is_stopped():
		anim_sprite.position = Vector2(
			Variables.rng.randf_range(-max_shake, max_shake),
			Variables.rng.randf_range(-max_shake, max_shake)
		) * shake_timer.time_left / shake_time


func _physics_process(delta: float) -> void:
	move_clamp(position + speed * delta * input)


func move_clamp(to: Vector2) -> void:
	position.x = clamp(to.x, 0, 1920)
	position.y = clamp(to.y, 0, 1080)


func get_hit() -> void:
	cs.call_deferred("set_disabled", true)
	cs2.call_deferred("set_disabled", true)
	shake_timer.start()


func stop_returning() -> void:
	set_physics_process(true)
	anim_sprite.play("default")
	cs.call_deferred("set_disabled", false)
	cs2.call_deferred("set_disabled", false)
	hitbox_collision.call_deferred("set_disabled", false)


func _on_ShakeTimer_timeout() -> void:
	cs.call_deferred("set_disabled", false)
	cs2.call_deferred("set_disabled", false)


func _on_Hitbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("berry"):
		return
	area.queue_free()
	anim_sprite.play("berry")
	cs.call_deferred("set_disabled", true)
	cs2.call_deferred("set_disabled", true)
	hitbox_collision.call_deferred("set_disabled", true)
	set_physics_process(false)
	var t := create_tween().set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_QUAD)
	var dur := (return_y - position.y) / return_speed
	t.tween_property(self, "position:y", return_y, dur)
	t.tween_callback(self, "stop_returning")
