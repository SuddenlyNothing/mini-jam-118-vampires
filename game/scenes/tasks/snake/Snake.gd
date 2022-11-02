extends Area2D

signal died

const BloodSplatter := preload("res://scenes/particles/BloodSplatter.tscn")

export(int) var health := 7
export(int) var speed := 300
export(int) var retreat_speed := 800
export(int) var attack_speed := 2000
export(int) var min_x := 1100
export(int) var max_x := 1800
export(int) var min_y := 185
export(int) var max_y := 800
export(float) var attack_x := 426.0
export(float) var min_attack_wait := 1.5
export(float) var max_attack_wait := 4.0
export(float) var dead_y := 1300.0
export(int) var fall_speed := 1000
export(float) var max_shake := 40.0

var move_t: SceneTreeTween
var hand: Area2D
var died := false

onready var head := $Head
onready var body := $Head/Body
onready var attack_timer := $AttackTimer
onready var straight_collision := $StraightCollision
onready var crooked_collision := $CrookedCollision
onready var hitbox := $Hitbox
onready var blood_pos := $BloodPosition
onready var shake_timer := $ShakeTimer
onready var shake_time: float = shake_timer.wait_time
onready var attack_sfx := $AttackSFX
onready var bit_sfx := $BitSFX
onready var death_sfx := $DeathSFX
onready var hiss_sfx := $HissSFX


func _ready() -> void:
	start()
	set_process(false)


func _process(delta: float) -> void:
	head.position = Vector2(
		Variables.rng.randf_range(-max_shake, max_shake),
		Variables.rng.randf_range(-max_shake, max_shake)
	) * shake_timer.time_left / shake_time


func start() -> void:
	move_to_rand_pos()
	Variables.rng.randomize()
	attack_timer.start(Variables.rng.randf_range(min_attack_wait,
			max_attack_wait))


func move_to_rand_pos() -> void:
	if move_t:
		move_t.kill()
	move_t = create_tween().set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_QUAD)
	Variables.rng.randomize()
	if Variables.rng.randf() > 0.8:
		if head.animation != "open" and not hiss_sfx.playing:
			hiss_sfx.play()
		head.play("open")
	else:
		head.play("close")
	var new_pos := Vector2(Variables.rng.randf_range(min_x, max_x),
			Variables.rng.randf_range(min_y, max_y))
	var dur := position.distance_to(new_pos) / speed
	move_t.tween_property(self, "position",
			new_pos, dur)
	move_t.parallel().tween_property(self, "rotation_degrees",
			Variables.rng.randf_range(-10, 10), dur)
	move_t.tween_callback(self, "move_to_rand_pos")


func attack() -> void:
	if move_t:
		move_t.kill()
	attack_sfx.play()
	hiss_sfx.stop()
	head.play("open")
	body.play("straight")
	straight_collision.call_deferred("set_disabled", false)
	crooked_collision.call_deferred("set_disabled", true)
	move_t = create_tween()
	move_t.tween_property(self, "rotation_degrees", 0.0, 0.1)
	move_t.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)\
			.tween_property(self, "position:x", attack_x,
			(position.x - attack_x) / float(attack_speed))
	move_t.tween_callback(head, "play", ["close"])
	move_t.tween_interval(0.05)
	move_t.tween_callback(self, "bite")
	move_t.tween_interval(0.2)
	var end_point := (min_x + max_x) / 2.0
	var dur := abs(attack_x - end_point) / retreat_speed
	move_t.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)\
			.tween_property(self, "position:x", end_point, dur)
	move_t.tween_callback(body, "play", ["crooked"])
	Variables.rng.randomize()
	move_t.tween_callback(straight_collision, "call_deferred",
			["set_disabled", true])
	move_t.tween_callback(crooked_collision, "call_deferred",
			["set_disabled", false])
	move_t.tween_callback(attack_timer, "start",
			[Variables.rng.randf_range(min_attack_wait, max_attack_wait)])
	move_t.tween_callback(self, "move_to_rand_pos")


func bite() -> void:
	if hand:
		var bs := BloodSplatter.instance()
		hand.add_child(bs)
		bs.global_position = blood_pos.global_position
		hand.get_hit()
		z_index = 1
		bit_sfx.play()


func get_hit() -> void:
	if died:
		return
	health -= 1
	z_index = 0
	create_tween().tween_property(head.get_material(),
			"shader_param/hit_strength", 0.0, 0.5).from(1.0)
	set_process(true)
	shake_timer.start()
	if health <= 0:
		death_sfx.play()
		died = true
		if move_t:
			move_t.kill()
		attack_timer.stop()
		head.play("dead")
		attack_sfx.stop()
		hiss_sfx.stop()
		move_t = create_tween().set_ease(Tween.EASE_IN)\
				.set_trans(Tween.TRANS_BACK)
		move_t.tween_property(self, "position:y", dead_y,
				(dead_y - position.y) / fall_speed)
		move_t.tween_callback(self, "die")


func die() -> void:
	Variables.add_material("snake_venom", 3)
	emit_signal("died")
	queue_free()


func _on_AttackTimer_timeout() -> void:
	attack()


func _on_Hitbox_area_entered(area: Area2D) -> void:
	if not area.has_method("get_hit") or area == self:
		return
	hand = area


func _on_Hitbox_area_exited(area: Area2D) -> void:
	if not area.has_method("get_hit") or area == self:
		return
	hand = null


func _on_ShakeTimer_timeout() -> void:
	set_process(false)
	head.position = Vector2()
