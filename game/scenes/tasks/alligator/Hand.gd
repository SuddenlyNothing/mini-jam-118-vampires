extends Sprite

const BloodSplatter := preload("res://scenes/particles/BloodSplatter.tscn")

export(int) var hand_speed := 5
export(int) var hand_bit_threshold := 700
export(int) var max_fill_level := -90
export(int) var min_fill_level := 2
export(float) var fill_increment := 0.1

var current_fill: float = 0.0
var fill_t: SceneTreeTween

onready var start_y: float = position.y
onready var fill := $Fill


func _ready() -> void:
	set_process(false)


func start() -> void:
	set_process(true)


func _process(delta: float) -> void:
	position.x = lerp(position.x,
			clamp(get_global_mouse_position().x, 0.0, 1920),
			min(delta * hand_speed, 1))


func set_fill_level(percent: float) -> void:
	var y: float = lerp(min_fill_level, max_fill_level, percent)
	var new_poly: PoolVector2Array
	for i in fill.polygon.size():
		var new_pos: Vector2 = fill.polygon[i]
		match i:
			3:
				new_pos.y = y + 3
			4:
				new_pos.y = y
		new_poly.push_back(new_pos)
	fill.set_polygon(new_poly)


func increment_fill_level() -> void:
	if fill_t:
		fill_t.kill()
	fill_t = create_tween()
	fill_t.tween_method(self, "set_fill_level", current_fill,
			min(current_fill + fill_increment, 1), 0.1)
	current_fill += fill_increment
	if current_fill >= 1:
		current_fill = 0
		var t := create_tween()
		set_process(false)
		t.tween_property(self, "position:x", -50.0, 0.1)
		t.tween_callback(self, "set_fill_level", [0])
		t.tween_property(self, "position:x", position.x, 0.1)
		t.tween_callback(self, "set_process", [true])


func _on_Alligator_bit() -> void:
	if position.x > hand_bit_threshold:
		position.y = 570
		z_index = -10
		var bs := BloodSplatter.instance()
		bs.position = position
		bs.z_index = z_index
		get_parent().add_child(bs)
		bs = BloodSplatter.instance()
		bs.position = Vector2(hand_bit_threshold, position.y)
		bs.z_index = z_index
		get_parent().add_child(bs)
		set_process(false)


func _on_Alligator_stopped_biting() -> void:
	position.y = start_y
	z_index = 0
	set_process(true)


func _on_Area2D_area_entered(area: Area2D) -> void:
	area.queue_free()
	increment_fill_level()