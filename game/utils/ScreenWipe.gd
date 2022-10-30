extends ColorRect

signal faded_in
signal faded_out

onready var fade_in_t := $FadeIn
onready var fade_out_t := $FadeOut

var fade_duration := 0.8


# Fades in.
func fade_in() -> void:
	rect_scale = Vector2.ONE
	fade_in_t.interpolate_property(get_material(),
			"shader_param/progress", 0.74, 0.0, fade_duration,
			Tween.TRANS_SINE, Tween.EASE_OUT)
	fade_in_t.start()
	MusicPlayer.undim(fade_duration)
	yield(fade_in_t, "tween_all_completed")
	hide()
	emit_signal("faded_in")


# Fades out.
func fade_out() -> void:
	rect_scale = Vector2.ONE * -1
	show()
	fade_out_t.interpolate_property(get_material(),
			"shader_param/progress", 0.0, 0.74, fade_duration,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	fade_out_t.start()
	MusicPlayer.dim(fade_duration, -20)
	yield(fade_out_t, "tween_all_completed")
	emit_signal("faded_out")
