extends Node2D

var t: SceneTreeTween

onready var c := $Node2D/Control
onready var sprite_select := $SpriteSelect


func _ready() -> void:
	sprite_select.hover_priority = get_position_in_parent()


func _on_SpriteSelect_hovered() -> void:
	if t:
		t.kill()
	t = create_tween()
	t.tween_property(c, "modulate:a", 1.0, 0.2)
	c.show()


func _on_SpriteSelect_unhovered() -> void:
	if t:
		t.kill()
	t = create_tween()
	t.tween_property(c, "modulate:a", 0.0, 0.2)
	t.tween_callback(c, "hide")
