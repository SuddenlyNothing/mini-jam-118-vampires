class_name TaskScript
extends Node

export(String, FILE, "*.tscn") var task_scene

var exited := false


func _unhandled_input(event: InputEvent) -> void:
	if exited:
		return
	if event.is_action_pressed("exit", false, true):
		exited = true
		SceneHandler.goto_scene(task_scene)
