extends Area2D

onready var anim_sprite := $AnimatedSprite


func _ready() -> void:
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(anim_sprite, "position:y", 0.0,
			Variables.rng.randf_range(0.5, 1.5))
	anim_sprite.flip_h = Variables.rng.randf() > 0.5
