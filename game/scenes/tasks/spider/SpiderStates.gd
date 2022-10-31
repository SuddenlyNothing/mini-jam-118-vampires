extends StateMachine

var entered_bite := false


func _ready() -> void:
	add_state("idle")
	add_state("wander")
	add_state("chase")
	add_state("escape_hole")
	add_state("bite")


# Contains state logic.
func _state_logic(delta: float) -> void:
	match state:
		states.idle:
			pass
		states.wander:
			parent.move_wander(delta)
		states.chase:
			parent.move_chase(delta)
		states.escape_hole:
			parent.move_escape(delta)
		states.bite:
			parent.move_bite(delta)


# Return value will be used to change state.
func _get_transition(delta: float):
	match state:
		states.idle:
			pass
		states.wander:
			pass
		states.chase:
			pass
		states.escape_hole:
			pass
		states.bite:
			pass
	return null


# Called on entering state.
# new_state is the state being entered.
# old_state is the state being exited.
func _enter_state(new_state: String, old_state) -> void:
	match new_state:
		states.idle:
			parent.play("idle")
			parent.start_state_change_timer()
		states.wander:
			parent.start_state_change_timer()
			parent.play("walk")
			parent.enter_wander()
		states.chase:
			parent.start_state_change_timer()
			parent.play("walk")
		states.escape_hole:
			parent.play("walk")
		states.bite:
			parent.state_change_timer.stop()
			parent.play("idle")
			parent.enter_bite()


# Called on exiting state.
# old_state is the state being exited.
# new_state is the state being entered.
func _exit_state(old_state, new_state: String) -> void:
	match old_state:
		states.idle:
			pass
		states.wander:
			pass
		states.chase:
			pass
		states.escape_hole:
			pass
		states.bite:
			pass


func set_state(new_state: String) -> void:
	if entered_bite:
		return
	if new_state == states.bite:
		entered_bite = true
	.set_state(new_state)
