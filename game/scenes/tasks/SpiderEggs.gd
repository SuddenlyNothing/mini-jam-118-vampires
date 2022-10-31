extends TaskScript

const Web := preload("res://scenes/tasks/spider/Web.tscn")
const SpiderAmbiance := preload("res://scenes/tasks/spider/SpiderAmbiance.tscn")

export(int) var max_ambiance := 1

var prep_web
var ambiance := []

onready var web := $Web
onready var hand := $Hand


func _ready() -> void:
	var w := Web.instance()
	w.player = hand
	add_child(w)
	w.prepare_enter(web.get_hole_pos())
	prep_web = w
	Variables.rng.randomize()


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
		add_spider_ambiance()


func add_spider_ambiance() -> void:
	for a in ambiance:
		a.volume_db = min(a.volume_db + 1, 0)
	if ambiance.size() >= max_ambiance:
		return
	var sa := SpiderAmbiance.instance()
	ambiance.append(sa)
	add_child(sa)
