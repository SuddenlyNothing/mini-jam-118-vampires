extends Wasp

export(float) var min_s := 0.2
export(float) var max_s := 0.6


func _ready() -> void:
	var s := Variables.rng.randf_range(min_s, max_s)
	scale = Vector2.ONE * s
	modulate = lerp(Color.black, Color("35443b"), (s - min_s) / (max_s - min_s))
	if end_pos.x < position.x:
		scale.x *= -1
