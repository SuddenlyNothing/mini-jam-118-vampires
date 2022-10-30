extends CPUParticles2D

onready var timer := $Timer

func _ready() -> void:
	emitting = true
	timer.start(lifetime * 2)


func _on_Timer_timeout() -> void:
	queue_free()
