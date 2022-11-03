extends SpriteSelect

var materials := {
	"spider_eggs": 0,
	"snake_venom": 0,
	"alligator_saliva": 0,
	"hermit_crab_shell": 0,
	"fruit": 0,
}

onready var label := $Node2D/Label
onready var add_ingredient := $AddIngredient
onready var pour := $Pour
onready var grind := $Grind
onready var block := $Block
onready var anim_player := $AnimationPlayer


func set_hovered(val: bool) -> void:
	.set_hovered(val)
	if val:
		t.parallel().tween_property(label, "modulate:a", 1.0, 0.5)
	else:
		t.parallel().tween_property(label, "modulate:a", 0.0, 0.2)


func _on_Area2D_area_entered(area: Area2D) -> void:
	if not area.is_in_group("material"):
		return
	add_ingredient.play()
	Variables.add_material(area.material_type, -1)
	area.queue_free()


func _on_PotionCreation_clicked() -> void:
	block.show()
	anim_player.play("RESET")
	anim_player.play("brew")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	block.hide()
