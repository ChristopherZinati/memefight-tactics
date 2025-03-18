class_name MapEncounter
extends Area2D

signal selected(encounter: Encounter)
const icons := {
	Encounter.Type.NOT_ASSIGNED: [null, Vector2.ONE],
	Encounter.Type.BATTLE:[preload("res://map_assets/map_icons/battle.png"), Vector2.ONE],
	Encounter.Type.AB_SHOP:[preload("res://map_assets/map_icons/abilities and buffs shop.png"), Vector2.ONE],
	Encounter.Type.U_SHOP:[preload("res://map_assets/map_icons/unit shop.png"), Vector2.ONE],
	Encounter.Type.SPECIAL_EVENT:[preload("res://map_assets/map_icons/special event.png"), Vector2.ONE],
	Encounter.Type.BOSS_BATTLE:[preload("res://map_assets/map_icons/Boss v1.png"), Vector2(1.25, 1.25)],
}

var scene_paths := {
	Encounter.Type.NOT_ASSIGNED : "",
	Encounter.Type.BATTLE: "battle.path",
	Encounter.Type.AB_SHOP: "res://menus/shop_phase.tscn",
	Encounter.Type.U_SHOP: "res://menus/unit_shop_phase.tscn",
	Encounter.Type.SPECIAL_EVENT: "res://menus/unit_shop_phase.tscn",
	Encounter.Type.BOSS_BATTLE: "boss_battle.path"
}

	
@onready var sprite_2d: Sprite2D = $Visuals/Sprite2D
@onready var line_2d: Line2D = $Visuals/Line2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
	
var available := false : set = set_available
var encounter: Encounter : set = set_encounter

func _ready() -> void:
	await get_tree().create_timer(3).timeout
	available = true
	
func set_available(new_value: bool) -> void:
	available = new_value
	
	if available:
		animation_player.play("highlight")
	elif not encounter.selected:
		animation_player.play("RESET")
		
		
func set_encounter(new_data: Encounter) -> void:
	encounter = new_data
	position = encounter.position
	sprite_2d.texture = icons[encounter.type][0]
	sprite_2d.scale = icons[encounter.type][1]


func show_selected() -> void:
	line_2d.modulate = Color.WHITE


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not available:
		return
	
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			encounter.selected = true
			animation_player.play("select")


func _on_map_encounter_selected() -> void:
	selected.emit(encounter)
	
	if encounter.type in scene_paths:
		get_tree().change_scene_to_file(scene_paths[encounter.type])
