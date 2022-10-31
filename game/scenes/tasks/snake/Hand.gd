extends Area2D

const BloodSplatter := preload("res://scenes/particles/BloodSplatter.tscn")

export(float) var start_x := 419.0
export(float) var end_x := 1650.0
export(float) var attack_dur := 0.3
export(float) var hand_speed := 3.0

var hit := false

onready var hand_knife := $HandKnife
onready var hitbox_collision := $Hitbox/CollisionShape2D
onready var blood_pos := $BloodPosition

var move_t: SceneTreeTween


func _process(delta: float) -> void:
	position.y = clamp(lerp(position.y, get_global_mouse_position().y,
			min(hand_speed * delta, 1.0)), 103, 923)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click", false, true):
		if not move_t or not move_t.is_running():
			attack()


func attack() -> void:
	set_process(false)
	hit = false
	hitbox_collision.call_deferred("set_disabled", false)
	move_t = create_tween().set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_QUAD)
	move_t.tween_property(hand_knife, "position:y", 26.0, attack_dur / 2)
	move_t.parallel().tween_property(hand_knife, "rotation_degrees", 8.0,
			attack_dur / 2)
	move_t.set_ease(Tween.EASE_IN).parallel()\
			.tween_property(self, "position:x", end_x, attack_dur)
	move_t.tween_callback(hitbox_collision, "call_deferred",
			["set_disabled", true])
	move_t.set_ease(Tween.EASE_IN_OUT).tween_interval(attack_dur / 5)
	move_t.tween_property(self, "position:x", start_x, attack_dur * 3)
	move_t.parallel().tween_property(hand_knife, "position:y", 0.0,
			attack_dur / 2)
	move_t.parallel().tween_property(hand_knife, "rotation_degrees", 0.0,
			attack_dur / 2)
	move_t.tween_callback(self, "set_process", [true])


func get_hit() -> void:
	z_index = 0


func _on_Hitbox_area_entered(area: Area2D) -> void:
	if hit:
		return
	if area.has_method("get_hit"):
		var bs := BloodSplatter.instance()
		bs.z_index = 10
		bs.position = blood_pos.global_position
		bs.modulate = Color.lightgreen
		get_parent().add_child(bs)
		hit = true
		area.get_hit()
		z_index = 1
