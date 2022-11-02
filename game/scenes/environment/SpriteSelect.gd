class_name SpriteSelect
extends Area2D

signal clicked
signal hovered
signal unhovered

export(String, FILE, "*.tscn") var next_scene := ""
export(bool) var pickable := false
export(int) var min_x := 200
export(int) var max_x := 1720
export(int) var min_y := 0
export(int) var max_y := 1050
export(int) var stable_y := 810
export(float) var fall_speed := 1200.0
export(bool) var new := false

var is_mouse_inside := false
var t: SceneTreeTween
var higher_prios := {}
var max_prio := -1
var hovered := false setget set_hovered
var mouse_offset := Vector2()
var holding := false
var disabled := false setget set_disabled
var move_t: SceneTreeTween

onready var hover_priority := get_position_in_parent()
onready var start_y := position.y


func _ready() -> void:
	set_process(false)
	if new:
		get_material().set_shader_param("line_scale", 5.0)


func _process(delta: float) -> void:
	position.y = clamp(get_global_mouse_position().y - mouse_offset.y,
			min_y, max_y)
	position.x = clamp(get_global_mouse_position().x - mouse_offset.x,
			min_x, max_x)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click", false, true) and hovered:
		if pickable:
			if move_t:
				move_t.kill()
			mouse_offset = get_local_mouse_position()
			set_process(true)
			holding = true
			get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,
					"sprite_select", "set_disabled", true)
		emit_signal("clicked")
		if next_scene:
			SceneHandler.goto_scene(next_scene)
	elif event.is_action_released("click", true) and pickable:
		set_process(false)
		if position.y < stable_y:
			if move_t:
				move_t.kill()
			move_t = create_tween().set_ease(Tween.EASE_OUT)\
					.set_trans(Tween.TRANS_BOUNCE)
			var dur := (start_y - position.y) / fall_speed + 0.6
			move_t.tween_property(self, "position:y", start_y, dur)
		else:
			start_y = position.y
		holding = false
		get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,
					"sprite_select", "set_disabled", false)
		if not is_mouse_inside:
			get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,
				"sprite_select", "group_hover_changed",
				hover_priority, is_mouse_inside)
			check_change_hover()


func check_change_hover() -> void:
	if hovered:
		if not is_mouse_inside or max_prio > hover_priority or\
				(disabled and not holding):
			set_hovered(false)
	else:
		if is_mouse_inside and max_prio < hover_priority and not disabled:
			set_hovered(true)


func set_hovered(val: bool) -> void:
	hovered = val
	if val:
		if new:
			new = false
			modulate = Color.white
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


func set_disabled(val: bool) -> void:
	disabled = val
	check_change_hover()


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
	if not holding:
		get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,
				"sprite_select", "group_hover_changed",
				hover_priority, is_mouse_inside)
		check_change_hover()


func _on_SpriteSelect_tree_exiting() -> void:
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME,
			"sprite_select", "group_hover_changed",
			hover_priority, false)
