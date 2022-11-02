extends AnimatedSprite

signal stopped_biting
signal bit

const Saliva := preload("res://scenes/tasks/alligator/Saliva.tscn")

export(float) var min_attempt_time := 0.5
export(float) var max_attempt_time := 4.0

var t: SceneTreeTween

onready var attempt_close_timer := $AttemptCloseTimer
onready var spawn_positions := $SpawnPos.get_children()
onready var saliva_interval := $SalivaInterval
onready var fake_timer := $FakeTimer
onready var tilt_timer := $TiltTimer
onready var tilt_time: float = tilt_timer.wait_time
onready var start_y := position.y
onready var fake_sfx := $FakeSFX
onready var hint_sfx := $HintSFX
onready var bite_no_harm_sfx := $BiteNoHarmSFX


func start() -> void:
	Variables.rng.randomize()
	attempt_close_timer.start(Variables.rng.randf_range(min_attempt_time,
			max_attempt_time))
	saliva_interval.start()


func _on_AttemptCloseTimer_timeout() -> void:
	Variables.rng.randomize()
	if Variables.rng.randf() > 0.5:
		play("close")
		saliva_interval.stop()
		hint_sfx.play()
	else:
		fake_sfx.play()
		fake_timer.start(1 / frames.get_animation_speed("close") / 1.25)
		saliva_interval.stop()


func _on_SalivaInterval_timeout() -> void:
	var s := Saliva.instance()
	s.position = spawn_positions[Variables.rng.randi_range(0,
			spawn_positions.size() - 1)].global_position
	get_parent().call_deferred("add_child", s)


func _on_Alligator_animation_finished() -> void:
	if animation == "close":
		play("open")
		saliva_interval.start()
		tilt_timer.start()
		emit_signal("stopped_biting")
		Variables.rng.randomize()
		attempt_close_timer.start(Variables.rng.randf_range(
				min_attempt_time, max_attempt_time))


func _on_Alligator_frame_changed() -> void:
	if animation == "close":
		match frame:
			1:
				bite_no_harm_sfx.play()
				if t:
					t.kill()
				position.y = start_y
				rotation = 0
				tilt_timer.stop()
				emit_signal("bit")


func _on_FakeTimer_timeout() -> void:
	saliva_interval.start()
	Variables.rng.randomize()
	attempt_close_timer.start(Variables.rng.randf_range(
			min_attempt_time, max_attempt_time))


func _on_TiltTimer_timeout() -> void:
	if t:
		t.kill()
	t = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_SINE)
	t.tween_property(self, "rotation_degrees", Variables.rng.randf_range(-2, 2),
			tilt_time)
	t.tween_property(self, "position:y",
			start_y + Variables.rng.randf_range(-30, 30), tilt_time)
