extends Control

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

export(int) var min_separation := 4
export(int) var max_separation := -48
export(float) var max_icons := 20.0

onready var icon_containers := [$M/V/H, $M/V/H2, $M/V/H3, $M/V/H4, $M/V/H5]
onready var customer_name := $"%Label"


func _ready() -> void:
	icon_containers[0].hide()
	update_order()
	Variables.connect("order_updated", self, "update_order")


func update_order() -> void:
	if Variables.order.empty():
		return
	customer_name.text = Variables.order.name
	for container in icon_containers:
		for child in container.get_children():
			child.queue_free()
	
	icon_containers[0].hide()
	icon_containers[0].set("custom_constants/separation",
			lerp(min_separation, max_separation,
			Variables.order.spider_eggs / max_icons))
	for _i in Variables.order.spider_eggs:
		icon_containers[0].show()
		icon_containers[0].add_child(SpiderEggIcon.instance())
	
	icon_containers[1].hide()
	icon_containers[1].set("custom_constants/separation",
			lerp(min_separation, max_separation,
			Variables.order.snake_venom / max_icons))
	for _i in Variables.order.snake_venom:
		icon_containers[1].show()
		icon_containers[1].add_child(SnakeVenomIcon.instance())
	
	icon_containers[2].hide()
	icon_containers[2].set("custom_constants/separation",
			lerp(min_separation, max_separation,
			Variables.order.alligator_saliva / max_icons))
	for _i in Variables.order.alligator_saliva:
		icon_containers[2].show()
		icon_containers[2].add_child(AlligatorSallivaIcon.instance())
	
	icon_containers[3].hide()
	icon_containers[3].set("custom_constants/separation",
			lerp(min_separation, max_separation,
			Variables.order.hermit_crab_shell / max_icons))
	for _i in Variables.order.hermit_crab_shell:
		icon_containers[3].show()
		icon_containers[3].add_child(CrabShellIcon.instance())
	
	icon_containers[4].hide()
	icon_containers[4].set("custom_constants/separation",
			lerp(min_separation, max_separation,
			Variables.order.fruit / max_icons))
	for _i in Variables.order.fruit:
		icon_containers[4].show()
		icon_containers[4].add_child(FruitIcon.instance())
