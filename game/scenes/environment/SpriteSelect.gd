extends Area2D

signal clicked

export(String, FILE, "*.tscn") var next_scene := ""

var is_mouse_inside := false
var t: SceneTreeTween

onready var sprite := $Sprite


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and is_mouse_inside:
		emit_signal("clicked")
		if next_scene:
			SceneHandler.goto_scene(next_scene)


func _on_SpriteSelect_mouse_entered() -> void:
	if t:
		t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(sprite.get_material(), "shader_param/line_scale", 4.0, 0.3)
	is_mouse_inside = true


func _on_SpriteSelect_mouse_exited() -> void:
	if t:
		t.kill()
	t = create_tween()
	t.tween_property(sprite.get_material(), "shader_param/line_scale", 0.0, 0.1)
	is_mouse_inside = false
