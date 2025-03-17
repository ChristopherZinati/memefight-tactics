class_name Battle
extends Node2D

const CELL_SIZE := Vector2(32, 32)
const HALF_CELL_SIZE := Vector2(16, 16)
const QUARTER_CELL_SIZE := Vector2(8, 8)

signal battle_started

@export var unit_grid: UnitGrid
@export var play_area: PlayArea

func start_battle():
	print("Battle starting!")
	battle_started.emit()


func _on_pre_battle_over() -> void:
	var units = unit_grid.units
	for unit in units:
		var entity = unit_grid.units.get(unit)
		if entity:
			if entity.is_in_group("units"):
				if entity is Area2D:
					#unit_grid.remove_unit(unit)
					var new_unit_scene = _get_character_body_scene_for_unit(entity)
					if new_unit_scene:
						var new_unit = new_unit_scene.instantiate()
						#print(unit, "pos: ")#unit_grid.remove_unit(unit)
						unit_grid.remove_unit(unit)
	
						unit_grid.add_entity(unit, new_unit)
						entity.get_parent().add_child(new_unit)
						entity.get_parent().remove_child(entity)
						new_unit.global_position = play_area.get_global_from_tile(unit) + -HALF_CELL_SIZE # Preserve the original position


	start_battle()


func _get_character_body_scene_for_unit(unit: Area2D) -> PackedScene:
	var base_name = unit.scene_file_path.get_file().replace("drag_", "")
	
	var scene_path = "res://scenes/" + base_name
	
	var new_scene = load(scene_path)
	if new_scene:
		return new_scene
	else:
		print("cant find unit scene for ", unit)
		return null
