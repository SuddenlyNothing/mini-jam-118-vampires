extends Area2D

export(int) var steering := 10.0 setget set_steering

var move_t: SceneTreeTween
var queued_hit := false

onready var sprite := $Sprite
onready var swat_sfx := $SwatSFX
onready var hit_sfx := $HitSFX


func _physics_process(delta: float) -> void:
	move_clamp(lerp(position, get_global_mouse_position(),
			min(steering * delta, 1.0)))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click", false, true):
		if move_t and move_t.is_running():
			queued_hit = true
		else:
			attack()


func try_attack() -> void:
	if queued_hit:
		attack()


func attack() -> void:
	queued_hit = false
	steering = 3.0
	swat_sfx.play()
	move_t = create_tween()
	move_t.tween_property(sprite, "scale", Vector2.ONE * 0.75, 0.1)
	move_t.tween_callback(self, "kill_wasps")
	move_t.tween_property(sprite, "scale", Vector2.ONE * 1.5, 0.1)
	move_t.tween_callback(self, "set_steering", [5.0])
	move_t.tween_callback(self, "try_attack")


func set_steering(val: float) -> void:
	steering = val


func kill_wasps() -> void:
	for area in get_overlapping_areas():
		if not area.is_in_group("wasp"):
			continue
		if area.has_method("get_hit"):
			hit_sfx.play()
			area.get_hit()


func move_clamp(to: Vector2) -> void:
	position.x = clamp(to.x, 0, 1920)
	position.y = clamp(to.y, 0, 1080)
