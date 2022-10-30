extends Node

# Used for input remapping and control displays
var user_keys := PoolStringArray([
	"pause",
	"click",
	"continue",
	"up",
	"left",
	"down",
	"right",
])

# Used for formatting strings to display the correct key.
var input_format := {}

# Fulfil orders using this
var task := {}

var rng := RandomNumberGenerator.new()
