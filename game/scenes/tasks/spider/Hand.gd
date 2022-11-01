class_name Hand
extends Area2D

const BloodSplatter := preload("res://scenes/particles/BloodSplatter.tscn")

export(float) var max_shake := 150.0

var speed := 500

var flash_t: SceneTreeTween

onready var shake_timer := $ShakeTimer
onready var sprite := $Sprite
onready var shake_time: float = shake_timer.wait_time
onready var collision := $CollisionPolygon2D
onready var i_timer := $ITimer
onready var i_flash_interval := $IFlashInterval


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	sprite.offset = Vector2(
		Variables.rng.randf_range(-max_shake, max_shake) * \
				shake_timer.time_left / shake_time,
		Variables.rng.randf_range(-max_shake, max_shake) * \
				shake_timer.time_left / shake_time
	)


func _physics_process(delta: float) -> void:
	move(delta)


func move(delta: float) -> void:
	var move_amount := speed * delta
	if move_amount >= get_local_mouse_position().length():
		set_clamped_pos(get_global_mouse_position())
	else:
		set_clamped_pos(position + \
				get_local_mouse_position().normalized() * move_amount)


func set_clamped_pos(new_pos: Vector2) -> void:
	position.x = clamp(new_pos.x, 0, 1920)
	position.y = clamp(new_pos.y, 0, 1080)


func get_bit() -> void:
	set_process(true)
	shake_timer.start()
	i_timer.start()
	i_flash_interval.start()
	set_collision_layer_bit(0, false)
	create_tween().tween_property(sprite.get_material(),
			"shader_param/hit_strength", 0.0, 1).from(1.0)
	var bs := BloodSplatter.instance()
	add_child(bs)


func _on_ShakeTimer_timeout() -> void:
	set_process(false)
	sprite.offset = Vector2()


func _on_ITimer_timeout() -> void:
	set_collision_layer_bit(0, true)
	sprite.show()
	i_flash_interval.stop()


func _on_IFlashInterval_timeout() -> void:
	sprite.visible = not sprite.visible
