extends Node2D

const Berry := preload("res://scenes/tasks/plants/Berry.tscn")

export(int) var min_x := 200
export(int) var max_x := 1720
export(int) var num_berries := 2
export(int) var min_dist := 100

var spawned_positions := {}


func _ready() -> void:
	start()


func start() -> void:
	for _i in num_berries:
		spawn_berry()


func spawn_berry() -> void:
	var b := Berry.instance()
	Variables.rng.randomize()
	var start_x := Variables.rng.randf_range(min_x, max_x)
	while is_too_close(start_x):
		start_x = Variables.rng.randf_range(min_x, max_x)
	b.position.x = start_x
	b.connect("tree_exited", self, "berry_exited", [start_x])
	spawned_positions[start_x] = 1
	call_deferred("add_child", b)


func is_too_close(x: float) -> bool:
	for x_pos in spawned_positions:
		if abs(x_pos - x) <= min_dist:
			return true
	return false


func berry_exited(start_x: float) -> void:
	spawn_berry()
	spawned_positions.erase(start_x)
