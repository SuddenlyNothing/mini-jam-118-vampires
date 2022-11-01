extends Hand

onready var grab_timer := $GrabTimer


func _on_CrabHand_area_entered(area: Area2D) -> void:
	if not area.is_in_group("crab"):
		return
	area.grab_shell()
	collision.call_deferred("set_disabled", true)
	grab_timer.start()
	sprite.play("shell")


func _on_GrabTimer_timeout() -> void:
	collision.call_deferred("set_disabled", false)
	sprite.play("default")
	Variables.add_material("hermit_crab_shell")
