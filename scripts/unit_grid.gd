class_name UnitGrid
extends Node2D

signal unit_grid_changed

@export var size: Vector2i
@export var grid_type: String = "default"  # "battle_grid", "bench_grid", "item_grid"
@export var play_area: PlayArea
# Battle grid only
@export var pre_battle_size: Vector2i
@export var enemy_spawn_start: Vector2i = Vector2i(7, 0)
@export var enemy_spawn_size: Vector2i = Vector2i(3, 4)

@onready var astar = AStar2D.new()

var reserved_tiles = {}
# contains either null (empty tile) or the occupying unit
var units: Dictionary
var battle: Battle
var is_battle_started: bool = false


func _ready() -> void:
	for i in size.x:
		for j in size.y:
			units[Vector2i(i, j)] = null
	
	battle = get_node("/root/Run/CurrentView/Battle")
	if battle:
		battle.battle_started.connect(_on_battle_started)
		if grid_type == "battle_grid":
			setup_astar_grid(self, 1)
		
		#TODO:
		#fill bench with owned units
			#hint: their in the player stats resource
	else:
		print("Battle node not found")
		


func add_unit(tile: Vector2i, unit: Node) -> void:
	units[tile] = unit
	unit.tree_exited.connect(_on_unit_tree_exited.bind(unit, tile))
	unit_grid_changed.emit()


#func add_enemy(tile: Vector2i, enemy: Node) -> void:
	#pass
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
		pass
		#print("Start Dictionary:", units)


func fill_bench(owned_units):
	var dragger = get_node("/root/Run/CurrentView/Battle/UnitDragger")
	for key in owned_units:
		var drag_unit = owned_units[key].scene.instantiate()
		drag_unit.unique_id = key
		var tile = get_first_empty_tile()
		add_unit(tile, drag_unit)
		add_child(drag_unit)
		drag_unit.global_position = play_area.get_global_from_tile(tile) + -battle.HALF_CELL_SIZE
		dragger.setup_unit(drag_unit)


func remove_unit(tile: Vector2i) -> void:
	var unit := units[tile] as Node
	
	if not unit:
		return
	
	unit.tree_exited.disconnect(_on_unit_tree_exited)
	units[tile] = null
	unit_grid_changed.emit()


func is_tile_occupied(tile: Vector2i) -> bool:
	return units[tile] != null


func is_grid_full() -> bool:
	return units.keys().all(is_tile_occupied)


func get_first_empty_tile() -> Vector2i:
	if grid_type == "bench_grid":
		print("bench: " , units)
	for tile in units:
		if not is_tile_occupied(tile):
			print("Found empty tile: ", tile)

			return tile

	# no empty tile
	return Vector2i(-1, -1)


func get_first_empty_enemy_tile() -> Vector2i:
	for tile in units:
		if not is_tile_occupied(tile) and play_area.is_tile_in_enemy_pre_bounds(tile):
			return tile

	return Vector2i(-1,-1)


# clears <freed unit> in unit dictionary when moving units
func _on_unit_tree_exited(unit: Node, tile: Vector2i) -> void:
	if unit.is_queued_for_deletion():
		units[tile] = null
		unit_grid_changed.emit()



func setup_astar_grid(unit_grid, cell_size: int):
	astar.clear()
	var grid_width = unit_grid.size.x
	var grid_height = unit_grid.size.y

	for y in range(grid_height):
		for x in range(grid_width):
			var id = get_tile_id(x, y)
			position = Vector2(x * cell_size, y * cell_size)
			astar.add_point(id, position, true)  # Mark as walkable
	
	connect_astar_points()


func get_tile_id(x: int, y: int) -> int:
	return y * self.size.x + x


func connect_astar_points():
	var grid_width = self.size.x
	var grid_height = self.size.y

	for y in range(grid_height):
		for x in range(grid_width):
			var id = get_tile_id(x, y)

			# Connect to the four cardinal neighbors (up, down, left, right)
			var neighbors = [
				Vector2i(x, y - 1),  # Up
				Vector2i(x, y + 1),  # Down
				Vector2i(x - 1, y),  # Left
				Vector2i(x + 1, y)   # Right
			]

			for neighbor in neighbors:
				var nx = neighbor.x
				var ny = neighbor.y

				if nx >= 0 and ny >= 0 and nx < grid_width and ny < grid_height:
					var neighbor_id = get_tile_id(nx, ny)
					astar.connect_points(id, neighbor_id, false)


func get_entity_at_tile(target_tile: Vector2i):
	return units.get(target_tile, null)
