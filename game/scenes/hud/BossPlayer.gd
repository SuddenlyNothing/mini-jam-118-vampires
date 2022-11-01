extends DialogPlayer

enum Emotions {
	NEUTRAL,
	ANGRY,
	PREDATORY,
}

export(Array, String, "neutral", "angry") var expression

onready var boss := $Boss


func read_next() -> void:
	while not is_instance_valid(boss):
		yield(get_tree(), "idle_frame")
	if d_ind == -1:
		if t:
			t.kill()
			.read_next()
			boss.position.x = 0.0
		else:
			t = create_tween().set_ease(Tween.EASE_OUT)\
					.set_trans(Tween.TRANS_BACK)
			if expression.size() > d_ind + 1:
				boss.play(expression[d_ind + 1])
			t.tween_property(boss, "position:x", 0.0, 1.0).from(865.0)
			t.tween_callback(self, "super_read_next")
	else:
		.read_next()
		if d_ind >= dialogs.size():
			return
		if expression.size() > d_ind:
			boss.play(expression[d_ind])


func super_read_next() -> void:
	.read_next()
