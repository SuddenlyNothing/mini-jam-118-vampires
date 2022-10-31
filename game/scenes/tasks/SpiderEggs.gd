extends TaskScript

const Web := preload("res://scenes/tasks/spider/Web.tscn")

var prep_web

onready var web := $Web
onready var hand := $Hand


func _ready() -> void:
	var w := Web.instance()
	w.player = hand
	add_child(w)
	w.prepare_enter(web.get_hole_pos())
	prep_web = w


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and web.is_hand_inside:
		web.exit()
		prep_web.enter()
		web = prep_web
		prep_web = null
		var w := Web.instance()
		w.player = hand
		add_child(w)
		w.prepare_enter(web.get_hole_pos())
		prep_web = w
