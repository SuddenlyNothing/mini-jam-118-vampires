extends Node

signal order_updated

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

var rng := RandomNumberGenerator.new()


func set_order(val: Dictionary) -> void:
	order = val
	emit_signal("order_updated")
