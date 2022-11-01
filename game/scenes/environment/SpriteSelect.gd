extends Area2D

signal clicked
signal hovered
signal unhovered

export(String, FILE, "*.tscn") var next_scene := ""

var is_mouse_inside := false
var t: SceneTreeTween
var higher_prios := {}
var max_prio := -1
var hovered := false setget set_hovered

onready var sprite := $Sprite
onready var hover_priority := get_position_in_parent()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and is_mouse_inside:
		emit_signal("clicked")
		if next_scene:
			SceneHandler.goto_scene(next_scene)


func check_change_hover() -> void:
	if hovered:
		if not is_mouse_inside or max_prio > hover_priority:
			set_hovered(false)
	else:
		if is_mouse_inside and max_prio < hover_priority:
			set_hovered(true)


func set_hovered(val: bool) -> void:
	hovered = val
	if val:
		emit_signal("hovered")
		if t:
			t.kill()
		t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		t.tween_property(get_material(), "shader_param/line_scale", 2.0, 0.3)
	else:
		emit_signal("unhovered")
		if t:
			t.kill()
		t = create_tween()
		t.tween_property(get_material(), "shader_param/line_scale", 0.0, 0.1)


func group_hover_changed(prio: int, is_mouse_inside: bool) -> void:
	if prio <= hover_priority:
		return
	if is_mouse_inside:
		higher_prios[prio] = true
		max_prio = max(max_prio, prio)
	else:
		higher_prios.erase(prio)
		max_prio = -1
		for i in higher_prios:
			if i > max_prio:
				max_prio = i
	check_change_hover()


func _on_SpriteSelect_mouse_entered() -> void:
	is_mouse_inside = true
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "sprite_select",
			"group_hover_changed", hover_priority, is_mouse_inside)
	check_change_hover()


func _on_SpriteSelect_mouse_exited() -> void:
	is_mouse_inside = false
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "sprite_select",
			"group_hover_changed", hover_priority, is_mouse_inside)
	check_change_hover()
