extends Node2D

const Shell := preload("res://scenes/materials/Shell.tscn")
const SpiderEgg := preload("res://scenes/materials/SpiderEgg.tscn")
const SnakeVenom := preload("res://scenes/materials/SnakeVenom.tscn")
const AlligatorSaliva := preload("res://scenes/materials/AlligatorSaliva.tscn")
const Fruit := preload("res://scenes/materials/Fruit.tscn")


func _ready() -> void:
	MusicPlayer.play("level")
	for i in Variables.material_positions:
		var mat
		match i[0]:
			"spider_eggs":
				mat = SpiderEgg.instance()
			"snake_venom":
				mat = SnakeVenom.instance()
			"alligator_saliva":
				mat = AlligatorSaliva.instance()
			"hermit_crab_shell":
				mat = Shell.instance()
			"fruit":
				mat = Fruit.instance()
		mat.position = i[1]
		mat.new = i[2]
		call_deferred("add_child", mat)


func _on_Tasks_pressed() -> void:
	Variables.material_positions = []
	for n in get_tree().get_nodes_in_group("material"):
		Variables.material_positions.append([n.material_type,
				Vector2(n.position.x, max(n.position.y, n.stable_y)), false])
