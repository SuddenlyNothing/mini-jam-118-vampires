extends Node

var music: Dictionary = {}
var num_lowers: int = 0
var current: String = ""
var paused := false
var pause_pos := 0.0
var dim_t: SceneTreeTween


func _ready() -> void:
	for i in get_children():
		music[i.name.to_lower()] = i


func play(song: String) -> void:
	song = song.to_lower()
	if song == current and not paused:
		return
	paused = false
	stop_all()
	music[song].play()
	current = song


func pause() -> void:
	paused = true
	pause_pos = music[current].get_playback_position()
	music[current].stop()


func unpause() -> void:
	if not paused:
		return
	paused = false
	music[current].play(pause_pos)


func stop_all() -> void:
	for child in get_children():
		child.stop()
	current = ""


func lower_volume() -> void:
	if num_lowers == 0:
		for child in get_children():
			child.volume_db -= 5
	num_lowers += 1


func increase_volume() -> void:
	if num_lowers == 1:
		for child in get_children():
			child.volume_db += 5
	num_lowers -= 1


func dim(dur: float, to: float = -80.0) -> void:
	if dim_t:
		dim_t.kill()
	dim_t = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	for child in get_children():
		dim_t.tween_property(child, "volume_db", to, dur)


func undim(dur: float) -> void:
	if dim_t:
		dim_t.kill()
	dim_t = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	for child in get_children():
		dim_t.tween_property(child, "volume_db", 0.0, dur)
