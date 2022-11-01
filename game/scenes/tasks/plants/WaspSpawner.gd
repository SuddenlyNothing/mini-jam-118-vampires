extends Node2D

const Wasp := preload("res://scenes/tasks/plants/Wasp.tscn")

export(int) var num_wasps := 7
export(int) var left_x := -150
export(int) var right_x := 2070

var spawned := 0

onready var spawn_timer := $SpawnTimer


func _ready() -> void:
	start()


func start() -> void:
	spawn_timer.start()


func _on_SpawnTimer_timeout() -> void:
	spawned += 1
	spawn_wasp()
	if spawned >= num_wasps:
		spawn_timer.stop()


func spawn_wasp() -> void:
	Variables.rng.randomize()
	var w := Wasp.instance()
	if Variables.rng.randf() > 0.5:
		w.position.x = left_x
		w.end_pos.x = right_x
	else:
		w.position.x = right_x
		w.end_pos.x = left_x
	w.position.y = Variables.rng.randf_range(0, 1080)
	w.end_pos.y = Variables.rng.randf_range(0, 1080)
	w.connect("tree_exited", self, "spawn_wasp")
	call_deferred("add_child", w)
