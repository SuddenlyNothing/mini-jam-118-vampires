extends BackBufferCopy

const Spider := preload("res://scenes/tasks/spider/Spider.tscn")
const SpiderEggs := preload("res://scenes/tasks/spider/SpiderEgg.tscn")

export(bool) var use_pre_hole_pos := false
export(Vector2) var pre_hole_pos := Vector2()
export(float) var duration := 1.0
export(int) var min_spiders := 3
export(int) var max_spiders := 9
export(int) var max_eggs := 2

var is_hand_inside := false
var spiders := []
var eggs := []
var player: Node2D

onready var web := $Web
onready var hole := $Web/Hole
onready var hole_collision := $Web/Hole/CollisionShape2D


func _ready() -> void:
	Variables.rng.randomize()
#	hole.position = Vector2(Variables.rng.randi_range(0, 1920),
#			Variables.rng.randi_range(0, 1080))
	if use_pre_hole_pos:
		hole.position = pre_hole_pos
	else:
		hole.position = Vector2(Variables.rng.randi_range(-960, 960),
				Variables.rng.randi_range(-540, 540))


func get_hole_pos() -> Vector2:
	return hole.position


func prepare_enter(hole_pos: Vector2) -> void:
	web.position = Vector2(960, 540) + hole_pos
	modulate = Color("#ccc")
	hole.get_material().set_shader_param("show_amount", 0.0)
	web.scale = Vector2.ONE * 0.5
	hole_collision.call_deferred("set_disabled", true)
	spawn_objcts(hole_pos)


func spawn_objcts(hole_pos: Vector2) -> void:
	Variables.rng.randomize()
	for _i in Variables.rng.randi_range(min_spiders, max_spiders):
		var s := Spider.instance()
		var new_pos := Vector2(Variables.rng.randf_range(-960, 960),
				Variables.rng.randf_range(-540, 540))
		while new_pos.distance_to(hole_pos) <= 500 or \
				new_pos.distance_to(hole.position) <= 230:
			new_pos = Vector2(Variables.rng.randf_range(-960, 960),
				Variables.rng.randf_range(-540, 540))
		s.position = new_pos
		web.call_deferred("add_child", s)
		spiders.append(s)
	for _i in Variables.rng.randi_range(0, max_eggs):
		var s := SpiderEggs.instance()
		var new_pos := Vector2(Variables.rng.randf_range(-960, 960),
				Variables.rng.randf_range(-540, 540))
		while new_pos.distance_to(hole_pos) <= 500 or \
				new_pos.distance_to(hole.position) <= 230:
			new_pos = Vector2(Variables.rng.randf_range(-960, 960),
				Variables.rng.randf_range(-540, 540))
		s.position = new_pos
		web.call_deferred("add_child", s)
		eggs.append(s)


func enter() -> void:
	z_index = -10
	var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
	t.tween_property(web, "scale", Vector2.ONE, duration - duration / 2)
	t.tween_property(web, "position", Vector2(960, 540),
			duration - duration / 5)
	t.tween_property(self, "modulate", Color.white, duration)
	t.tween_property(hole.get_material(), "shader_param/show_amount",
			1.0, duration)
	t.chain().tween_callback(hole_collision, "set_disabled", [false])
	t.set_parallel(true)
	for spider in spiders:
		t.tween_callback(spider, "start", [player])
	for egg in eggs:
		t.tween_callback(egg, "start")


func exit() -> void:
	z_index = -5
	web.position += hole.position
	web.offset = -hole.position
	var hp: Vector2 = hole.position
	for child in web.get_children():
		child.position -= hp
	for spider in spiders:
		if is_instance_valid(spider):
			spider.stop()
	for egg in eggs:
		if is_instance_valid(egg):
			egg.stop()
	var t := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_IN)
	t.tween_property(web, "scale", Vector2.ONE * 15, duration)
	t.chain().tween_callback(self, "queue_free")


func _on_Area2D_area_entered(area: Area2D) -> void:
	if not area.is_in_group("hand"):
		return
	is_hand_inside = true
	hole.get_material().set_shader_param("normal_color", Color("#b3c3c7"))


func _on_Area2D_area_exited(area: Area2D) -> void:
	if not area.is_in_group("hand"):
		return
	is_hand_inside = false
	hole.get_material().set_shader_param("normal_color", Color('#889497'))
