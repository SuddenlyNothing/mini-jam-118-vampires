extends TaskScript

onready var hand := $Hand
onready var alligator := $Alligator


func _ready() -> void:
	alligator.start()
	hand.start()
