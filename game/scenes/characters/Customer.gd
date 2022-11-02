extends Node2D

signal clicked

const SpiderEggIcon := preload(
	"res://scenes/characters/ingredient_icons/SpiderEggIcon.tscn"
)
const SnakeVenomIcon := preload(
	"res://scenes/characters/ingredient_icons/SnakeVenomIcon.tscn"
)
const AlligatorSallivaIcon := preload(
	"res://scenes/characters/ingredient_icons/AlligatorSalivaIcon.tscn"
)
const CrabShellIcon := preload(
	"res://scenes/characters/ingredient_icons/CrabShellIcon.tscn"
)
const FruitIcon := preload(
	"res://scenes/characters/ingredient_icons/FruitsIcon.tscn"
)

export(String) var customer_name := "Steve"
export(int) var spider_eggs := 0
export(int) var snake_venom := 0
export(int) var alligator_saliva := 0
export(int) var hermit_crab_shell := 0
export(int) var fruit := 0

export(int) var screen_width := 1920
export(int) var start_offset := 50
#export(Vector2) var dialog_collision_padding := Vector2(18, 18)

var flipped := false
var t: SceneTreeTween

onready var dialog := $"%Dialog"
onready var icon_containers := [
	$Node2D/Dialog/M/V/H,
	$Node2D/Dialog/M/V/H2,
	$Node2D/Dialog/M/V/H3,
	$Node2D/Dialog/M/V/H4,
	$Node2D/Dialog/M/V/H5,
]
onready var sprite_select := $SpriteSelect
#onready var dialog_collision := $SpriteSelect/DialogCollision
onready var label := $"%Label"


func _ready() -> void:
	sprite_select.hover_priority = get_position_in_parent()
	label.text = customer_name
	for _i in spider_eggs:
		icon_containers[0].show()
		icon_containers[0].add_child(SpiderEggIcon.instance())
	
	for _i in snake_venom:
		icon_containers[1].show()
		icon_containers[1].add_child(SnakeVenomIcon.instance())
	
	for _i in alligator_saliva:
		icon_containers[2].show()
		icon_containers[2].add_child(AlligatorSallivaIcon.instance())
	
	for _i in hermit_crab_shell:
		icon_containers[3].show()
		icon_containers[3].add_child(CrabShellIcon.instance())
	
	for _i in fruit:
		icon_containers[4].show()
		icon_containers[4].add_child(FruitIcon.instance())


func _process(delta: float) -> void:
	if (position.x > screen_width / 2 + screen_width / 5 and not flipped) or \
			(position.x < screen_width / 2 - screen_width / 5 and flipped):
		flip()


func flip() -> void:
	flipped = not flipped
	if flipped:
		dialog.rect_position.x = -start_offset - dialog.rect_size.x
	else:
		dialog.rect_position.x = start_offset


func _on_SpriteSelect_hovered() -> void:
	if t:
		t.kill()
	dialog.show()
	if flipped:
		dialog.rect_position.x = -start_offset - dialog.rect_size.x
#	dialog_collision.shape.extents = dialog.rect_size / 2 + \
#			dialog_collision_padding
#	dialog_collision.position = dialog.rect_global_position + dialog.rect_size\
#			/ 2 - position
#	dialog_collision.call_deferred("set_disabled", false)
	t = create_tween()
	t.tween_property(dialog, "modulate:a", 1.0, 0.2)


func _on_SpriteSelect_unhovered() -> void:
	if t:
		t.kill()
#	dialog_collision.call_deferred("set_disabled", true)
	t = create_tween()
	t.tween_property(dialog, "modulate:a", 0.0, 0.1)
	t.tween_callback(dialog, "hide")


func _on_SpriteSelect_clicked() -> void:
	emit_signal("clicked")
	Variables.order = {
		"name": customer_name,
		"spider_eggs": spider_eggs,
		"snake_venom": snake_venom,
		"alligator_saliva": alligator_saliva,
		"hermit_crab_shell": hermit_crab_shell,
		"fruit": fruit
	}
