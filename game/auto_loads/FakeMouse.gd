extends Area2D

var sensitivity := 500.0

onready var sprite := $Sprite
onready var vp := get_viewport().size


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	sprite.show()
	var mouse_pos := get_global_mouse_position()
	position.x = clamp(mouse_pos.x, 0, vp.x)
	position.y = clamp(mouse_pos.y, 0, vp.y)


func _process(delta: float) -> void:
	var input := Input.get_vector("left", "right", "up", "down")
	if input:
		get_tree().get_frame()
		var ev := InputEventMouseMotion.new()
		ev.relative = input
		ev.position = position
		position += input * sensitivity * delta
		get_tree().input_event(ev)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		sprite.hide()
	if event.is_action_pressed("click"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			position = get_global_mouse_position()
			sprite.show()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouse:
			event.position = position
		if event is InputEventMouseMotion:
			position.x = clamp(position.x + event.relative.x, 0, vp.x)
			position.y = clamp(position.y + event.relative.y, 0, vp.y)
