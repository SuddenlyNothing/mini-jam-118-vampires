extends Sprite

const Crab := preload("res://scenes/tasks/crab/Crab.tscn")

export(Vector2) var screen := Vector2(1920, 1080)
export(int) var total_crabs := 10
export(int) var margin := 200

var current_crabs := 0

onready var spawn_interval := $SpawnInterval


func _ready() -> void:
	start()


func start() -> void:
	current_crabs += 1
	spawn_interval.start()


func get_outside_pos(cross_pos: Vector2, travel_dir: Vector2) -> Vector2:
	var x_dir_dist := screen.x - cross_pos.x if travel_dir.x > 0 \
			else cross_pos.x
	var y_dir_dist := screen.y - cross_pos.y if travel_dir.y > 0 \
			else cross_pos.y
	var x_dist = abs((x_dir_dist + margin)\
			/ travel_dir.x)
	var y_dist = abs((y_dir_dist + margin)\
			/ travel_dir.y)
	var travel_dist := min(x_dist, y_dist)
	return travel_dir * travel_dist + cross_pos


func spawn_crab(guarantee_shell: bool = false) -> void:
	Variables.rng.randomize()
	var c := Crab.instance()
	var cross_pos := Vector2(
		Variables.rng.randf_range(0, screen.x),
		Variables.rng.randf_range(0, screen.y)
	)
	var travel_dir := Vector2.RIGHT.rotated(Variables.rng.randf() * 2 * PI)
	c.position = get_outside_pos(cross_pos, travel_dir)
	c.end_pos = get_outside_pos(cross_pos, -travel_dir)
	c.guarantee_shell = guarantee_shell
	c.connect("tree_exited", self, "spawn_crab")
	call_deferred("add_child", c)


func _on_SpawnInterval_timeout() -> void:
	current_crabs += 1
	spawn_crab(current_crabs == total_crabs / 2)
	if current_crabs >= total_crabs:
		spawn_interval.stop()
