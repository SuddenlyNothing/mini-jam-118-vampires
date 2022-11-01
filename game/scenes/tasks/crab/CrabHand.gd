extends Hand

export(float) var rot_speed := 3


func move(delta: float) -> void:
	var move_amount := speed * delta
	if move_amount >= get_local_mouse_position().length():
		set_clamped_pos(get_global_mouse_position())
	else:
		var dir := get_local_mouse_position().normalized()
		face(dir, delta)
		set_clamped_pos(position + dir * move_amount)


func face(dir: Vector2, delta: float) -> void:
	sprite.rotation = lerp_angle(sprite.rotation,
			dir.angle() + PI / 2, rot_speed * delta)
