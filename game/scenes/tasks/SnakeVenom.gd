extends TaskScript

const Snake := preload("res://scenes/tasks/snake/Snake.tscn")

export(int) var min_y := 185
export(int) var max_y := 800


func _on_Snake_died() -> void:
	var s := Snake.instance()
	Variables.rng.randomize()
	s.position = Vector2(2090, Variables.rng.randf_range(min_y, max_y))
	s.connect("died", self, "_on_Snake_died")
	call_deferred("add_child", s)
