extends Control

export(String, FILE, "*.tscn") var death_return_scene
export(float) var max_shake := 30.0
export(Array, Array, String, MULTILINE) var dialog

var t: SceneTreeTween

onready var bar := $M/Bar
onready var shake_timer := $ShakeTimer
onready var shake_time: float = shake_timer.wait_time
onready var start_pos: Vector2 = bar.rect_position
onready var fade := $Fade
onready var boss_player := $Fade/BossPlayer


func _ready() -> void:
	Variables.connect("suspicion_updated", self, "set_suspicion")
	bar.value = Variables.suspicion / float(Variables.max_suspicion)
	set_process(false)


func _process(delta: float) -> void:
	bar.rect_position = Vector2(
		Variables.rng.randf_range(-max_shake, max_shake),
		Variables.rng.randf_range(-max_shake, max_shake)
	) * shake_timer.time_left / shake_time + start_pos


func set_suspicion() -> void:
	var new_value := Variables.suspicion / float(Variables.max_suspicion)
	if new_value > bar.value:
		shake_timer.start()
		set_process(true)
		if t:
			t.kill()
		t = create_tween().set_parallel(true)
		t.tween_property(bar.get_material(),"shader_param/hit_strength",
				0.0, 0.5).from(1.0)
		t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)\
				.tween_property(bar, "value", new_value, 0.5)
		if new_value >= 1:
			get_tree().paused = true
			fade.show()
			t.set_parallel(false)
			t.tween_property(fade, "modulate:a", 1.0, 1.0)
			t.tween_callback(boss_player, "read", [dialog[0]])
	else: # only happens when we increase the max suspicion or decrease suspicion
		if t:
			t.kill()
		t = create_tween()
		t.parallel().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)\
				.tween_property(bar, "value", new_value, 2)
		t.tween_callback(SceneHandler, "goto_scene", [death_return_scene])


func play_cutsene(ind: int) -> void:
	pass


func _on_ShakeTimer_timeout() -> void:
	set_process(false)
	bar.rect_position = start_pos


func _on_BossPlayer_dialog_finished() -> void:
	Variables.max_suspicion *= 2
