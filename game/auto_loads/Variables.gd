extends Node

signal order_updated
signal materials_updated

# Used for input remapping and control displays
var user_keys := PoolStringArray([
	"pause",
	"click",
	"exit",
	"continue",
	"up",
	"left",
	"down",
	"right",
])

# Used for formatting strings to display the correct key.
var input_format := {}

# Fulfil orders using this
var order := {} setget set_order

var materials := {
	"spider_eggs": 0,
	"snake_venom": 0,
	"alligator_saliva": 0,
	"hermit_crab_shell": 0,
	"fruit": 0,
}

var rng := RandomNumberGenerator.new()


func set_order(val: Dictionary) -> void:
	order = val
	emit_signal("order_updated")


func add_material(mat: String, amount: int = 1) -> void:
	materials[mat] = min(materials[mat] + amount, 20)
	emit_signal("materials_updated")
