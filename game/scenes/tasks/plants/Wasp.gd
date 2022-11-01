class_name Wasp
extends Area2D

const BloodSplatter := preload("res://scenes/particles/BloodSplatter.tscn")

export(Vector2) var end_pos
export(float) var min_move_speed := 100.0
export(float) var max_move_speed := 400.0
export(float) var attack_rot := -126.0
export(float) var death_dur := 1.0

var move_speed: float
var t: SceneTreeTween
var dead := false

onready var anim_sprite := $AnimatedSprite
onready var collisions := [$CollisionShape2D, $Hitbox/CollisionShape2D]
onready var anim_player := $AnimationPlayer
onready var blood_position := $AnimatedSprite/BloodPosition


func _ready() -> void:
	Variables.rng.randomize()
	move_speed = Variables.rng.randf_range(min_move_speed, max_move_speed)
	anim_player.seek(anim_player.get_animation("hover").length * \
			Variables.rng.randf())
	if end_pos.x < position.x:
		scale.x *= -1


func _physics_process(delta: float) -> void:
	var move_amount := move_speed * delta
	if position.distance_to(end_pos) <= move_amount:
		queue_free()
	else:
		position += position.direction_to(end_pos) * move_amount


func get_hit() -> void:
	if dead:
		return
	z_index = -1
	dead = true
	set_physics_process(false)
	for c in collisions:
		c.call_deferred("set_disabled", true)
	if t:
		t.kill()
	anim_player.stop()
	t = create_tween().set_parallel()
	t.tween_property(self, "rotation",
			Variables.rng.randf_range(4 * PI, 10 * PI), death_dur)
	t.tween_property(self, "position:x", Variables.rng.randf_range(0, 1920),
			death_dur)
	var death_y := Variables.rng.randf_range(0, 1080)
	var up_y := min(death_y - 200.0, position.y - 200.0)
	t.tween_property(self, "scale", Vector2(), death_dur)
	t.tween_property(self, "position:y", up_y, death_dur / 2)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(self, "position:y", death_y, death_dur / 2)\
			.from(up_y).set_delay(death_dur / 2)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	t.chain().tween_callback(self, "queue_free")


func _on_Hitbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("hand"):
		return
	var bs := BloodSplatter.instance()
	area.add_child(bs)
	bs.global_position = blood_position.global_position
	if t:
		t.kill()
	t = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(anim_sprite, "rotation_degrees", attack_rot, 0.05)
	t.tween_callback(area, "get_hit")
	t.tween_property(anim_sprite, "rotation_degrees", 0.0, 0.2)
