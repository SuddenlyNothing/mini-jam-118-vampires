extends AnimatedSprite

signal stopped_biting
signal bit

const Saliva := preload("res://scenes/tasks/alligator/Saliva.tscn")

export(float) var min_attempt_time := 0.5
export(float) var max_attempt_time := 4.0

onready var attempt_close_timer := $AttemptCloseTimer
onready var spawn_positions := $SpawnPos.get_children()
onready var saliva_interval := $SalivaInterval
onready var fake_timer := $FakeTimer


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
	else:
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
		emit_signal("stopped_biting")
		Variables.rng.randomize()
		attempt_close_timer.start(Variables.rng.randf_range(
				min_attempt_time, max_attempt_time))


func _on_Alligator_frame_changed() -> void:
	if animation == "close":
		match frame:
			1:
				emit_signal("bit")


func _on_FakeTimer_timeout() -> void:
	saliva_interval.start()
	Variables.rng.randomize()
	attempt_close_timer.start(Variables.rng.randf_range(
			min_attempt_time, max_attempt_time))
