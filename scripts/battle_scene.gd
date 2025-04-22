class_name Battle
extends Node2D

const CELL_SIZE := Vector2(32, 32)
const HALF_CELL_SIZE := Vector2(16, 16)
const QUARTER_CELL_SIZE := Vector2(8, 8)

signal battle_started


@export var unit_grid: UnitGrid
@export var play_area: PlayArea

#var total_entities: int
var total_enemies: int
var enemy_count: int = 0
var unit_count: int = 0
var units_dead: int = 0
var battling = false

func _ready() -> void:
	events.battle_entered.emit()


func _process(_delta: float) -> void:
	if battling:
		if enemy_count == 0 or unit_count == 0:
			
			var reward_scene = load("res://scenes/rewards.tscn")
			var reward_instance = reward_scene.instantiate()
			reward_instance.gold_amount = (total_enemies * 4) - units_dead
			if enemy_count == 0:
				reward_instance.battle_won = true
			else:
				reward_instance.battle_won = false
			self.add_child(reward_instance)
			battling = false
			events.battle_over.emit()



func start_battle():
	print("Battle starting!")
	battling = true
	for tile in unit_grid.units:
		var entity = unit_grid.get_entity_at_tile(tile)
		if entity:
			if entity.is_in_group("enemies"):
				enemy_count +=1
			else:
				unit_count += 1

	#total_entities = enemy_count + unit_count
	total_enemies = enemy_count
	battle_started.emit()




func _on_pre_battle_over() -> void:
	var units = unit_grid.units
	var i = 0
	for unit in units:
		var entity = unit_grid.units.get(unit)
		if entity:
			if entity.is_in_group("units"):
				if entity is Area2D:
					i+=1
					var new_unit_scene = _get_character_body_scene_for_unit(entity)
					if new_unit_scene:
						var new_unit = new_unit_scene.instantiate()
						new_unit.name = "Unit" +str(i)
						new_unit.unit_id = entity.unit_id
						new_unit.unique_id = entity.unique_id
						# update in grid
						unit_grid.remove_unit(unit)
						unit_grid.add_entity(unit, new_unit)
						# update in scene
						var owned_units = get_node("/root/Run").player.units
						for key in owned_units:
							if new_unit.unique_id == key:
								if owned_units[key].stats != null:
									new_unit.set_stats(owned_units[key].stats)
								else:
									new_unit.set_stats(new_unit.stats.create_instance())
							else: pass
						entity.get_parent().add_child(new_unit)
						entity.get_parent().remove_child(entity)
						# preserve its original position
						new_unit.global_position = play_area.get_global_from_tile(unit) + -HALF_CELL_SIZE
						

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
