class_name UnitGrid
extends Node2D

signal unit_grid_changed

@export var size: Vector2i
@export var pre_battle_size: Vector2i
@export var enemy_spawn_start: Vector2i = Vector2i(7, 0)
@export var enemy_spawn_size: Vector2i = Vector2i(3, 4)
@export var grid_type: String = "default"  # "battle_grid", "bench_grid", "item_grid"
@export var play_area: PlayArea

# contains either null (empty tile) or the occupying unit
var units: Dictionary
var battle: Battle
var is_battle_started: bool = false


func _ready() -> void:
	for i in size.x:
		for j in size.y:
			units[Vector2i(i, j)] = null
	#print("Initialized Units:", units)
	
	battle = get_node("/root/Battle")
	if battle:
		battle.battle_started.connect(_on_battle_started)
	else:
		print("Battle node not found")
		


func add_unit(tile: Vector2i, unit: Node) -> void:
	pass
	#if not is_battle_started and !is_within_pre_battle_area(tile):
		#return

	#units[tile] = unit
	#unit.tree_exited.connect(_on_unit_tree_exited.bind(unit, tile))
	#unit_grid_changed.emit()


func add_enemy(tile: Vector2i, enemy: Node) -> void:
	pass
	#units[tile] = enemy
	#enemy.tree_exited.connect(_on_unit_tree_exited.bind(enemy, tile))
	#unit_grid_changed.emit()


func add_entity(tile: Vector2i, entity: Node) -> void:
	if not is_battle_started and entity.is_in_group("units"):
		if !is_within_pre_battle_area(tile):
			return
	if not entity.is_connected("tree_exited", Callable(self, "_on_unit_tree_exited")):
		entity.tree_exited.connect(_on_unit_tree_exited.bind(entity, tile))

	units[tile] = entity
	unit_grid_changed.emit()


func is_within_pre_battle_area(tile: Vector2i) -> bool:
	return tile.x < pre_battle_size.x and tile.y < pre_battle_size.y


func _on_battle_started():
	is_battle_started = true
	
	if grid_type == "battle_grid":
		print("Start Dictionary:", units)



func remove_unit(tile: Vector2i) -> void:
	var unit := units[tile] as Node
	
	if not unit:
		return
	
	unit.tree_exited.disconnect(_on_unit_tree_exited)
	units[tile] = null
	#print("Units after removal:", units)
	unit_grid_changed.emit()


func is_tile_occupied(tile: Vector2i) -> bool:
	return units[tile] != null


func is_grid_full() -> bool:
	return units.keys().all(is_tile_occupied)


func get_first_empty_tile() -> Vector2i:
	for tile in units:
		if not is_tile_occupied(tile):
			return tile

	# no empty tile
	return Vector2i(-1, -1)


func get_first_empty_enemy_tile() -> Vector2i:
	for tile in units:
		if not is_tile_occupied(tile) and play_area.is_tile_in_enemy_pre_bounds(tile):
			return tile

	return Vector2i(-1,-1)


func get_all_units() -> Array:
	var unit_array: Array = []
	for entity in units.values():
		if entity is Unit or entity is Enemy:
			unit_array.append(entity)

	return unit_array


# clears <freed unit> in unit dictionary when moving units
func _on_unit_tree_exited(unit: Node, tile: Vector2i) -> void:
	if unit.is_queued_for_deletion():
		units[tile] = null
		unit_grid_changed.emit()
