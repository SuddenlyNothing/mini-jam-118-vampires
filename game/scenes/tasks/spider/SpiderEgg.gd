extends Area2D

onready var collision := $CollisionShape2D


func start() -> void:
	collision.call_deferred("set_disabled", false)


func stop() -> void:
	collision.call_deferred("set_disabled", true)


func _on_SpiderEgg_area_entered(area: Area2D) -> void:
	if not area.is_in_group("hand"):
		return
	Variables.add_material("spider_eggs")
	queue_free()
