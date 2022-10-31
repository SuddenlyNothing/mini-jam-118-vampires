extends AudioStreamPlayer


func _ready() -> void:
	Variables.rng.randomize()
	play(stream.get_length() * Variables.rng.randf())
