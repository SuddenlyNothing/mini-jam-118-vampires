extends Area2D

export(int) var speed := 500


func _ready() -> void:
	set_physics_process(false)
	$Saliva.play("drop")


func _physics_process(delta: float) -> void:
	position.y += speed * delta


func _on_Saliva_animation_finished() -> void:
	set_physics_process(true)
