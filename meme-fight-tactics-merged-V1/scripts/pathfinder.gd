class_name Pathfinder
extends Node2D


@export var battle: Battle
@export var unit_grid: UnitGrid
@export var movement_speed: float = 100.0
@onready var astar = AStar2D.new()
@export var play_area: PlayArea

var path: Array = []
var current_tile: Vector2i
var previous_tile: Vector2i
var target: Vector2i
var battle_started = false

func _ready():
	battle = get_node("/root/Battle")
	
	await battle.ready
	unit_grid = battle.get_node("/root/Battle/GameArea/BattleUnitGrid")  # Avoid crashes
	play_area = battle.get_node("/root/Battle/GameArea")

	if battle:
		battle.battle_started.connect(_on_battle_started)


func _on_battle_started():
	battle_started = true

	setup_astar_grid(unit_grid, 1)
	
	current_tile = play_area.get_tile_from_global(global_position)
	
	target = find_nearest_target()
	
	path = generate_path(current_tile, target)

	print(get_parent(), " path to target: ",path)
	return


func _physics_process(delta):
	if battle_started:

		#if target is alive and (me)not fighting:
			#follow path
		#if target is alive and figthing:
			#kill it
		#if target is not alive:
			#target = find_nearest_target()
			#path = generate_path(current_tile, target)
		
		follow_path(delta)


func setup_astar_grid(unit_grid, cell_size: int):
	astar.clear()
	var grid_width = unit_grid.size.x
	var grid_height = unit_grid.size.y

	for y in range(grid_height):
		for x in range(grid_width):
			var id = get_tile_id(x, y)
			var position = Vector2(x * cell_size, y * cell_size)
			astar.add_point(id, position, true)  # Mark as walkable
			#print("Added AStar point:", x, y, "ID:", id)  # Debugging
	
	connect_astar_points()


func get_tile_id(x: int, y: int) -> int:
	return y * unit_grid.size.x + x


func connect_astar_points():
	var grid_width = unit_grid.size.x
	var grid_height = unit_grid.size.y

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


func find_nearest_target():
	var all_units = unit_grid.units
	var my_tile = current_tile
	
	var nearest_target = null
	var shortest_distance = INF
	
	for tile in all_units:
		var unit = all_units[tile]
		if unit:
			if valid_target(unit):
				var distance = my_tile.distance_to(tile)
				if distance < shortest_distance:
					shortest_distance = distance
					nearest_target = tile
	#print("my tile is: ", my_tile, "nearest unit is: ", nearest_target)
	return nearest_target


func valid_target(unit):
	# If this is attached to an enemy, find player units.
	# If this is attached to a player, find enemies.
	if get_parent().is_in_group("enemies"):
		return unit.is_in_group("units")
	else:
		return unit.is_in_group("enemies")


func generate_path(current_tile: Vector2i, target_tile: Vector2i) -> Array:
	path.clear()
	if not astar.has_point(get_tile_id(current_tile.x, current_tile.y)):
		print("Error: Start tile not found in AStar!")
		return []

	if not astar.has_point(get_tile_id(target_tile.x, target_tile.y)):
		print("Error: Target tile not found in AStar!")
		return []

	var disabled_tiles = []
	for tile in unit_grid.units.keys():
		var entity = get_entity_at_tile(tile)
		if entity and not valid_target(entity):  # If occupied and not a valid target
			var tile_id = get_tile_id(tile.x, tile.y)
			if astar.has_point(tile_id):
				astar.set_point_disabled(tile_id, true)  # Disable it
				disabled_tiles.append(tile_id)

	# Convert Vector2i tiles to AStar node IDs
	var start_id = get_tile_id(current_tile.x, current_tile.y)
	var target_id = get_tile_id(target_tile.x, target_tile.y)

	# Get path from AStar
	var path_ids = astar.get_id_path(start_id, target_id)

	# Re-enable the tiles after pathfinding
	for tile_id in disabled_tiles:
		astar.set_point_disabled(tile_id, false)

	if path_ids.is_empty():
		print("No path found!")
		return []

	# Convert path IDs to global positions
	var path_positions = []
	for id in path_ids:
		path_positions.append(astar.get_point_position(id))

	return path_positions


func find_nearest_adjacent_target(tile: Vector2i) -> Node:
	var adjacent_tiles = [
		Vector2i(tile.x, tile.y - 1),  # Up
		Vector2i(tile.x, tile.y + 1),  # Down
		Vector2i(tile.x - 1, tile.y),  # Left
		Vector2i(tile.x + 1, tile.y)   # Right
	]

	for adj_tile in adjacent_tiles:
		var entity = get_entity_at_tile(adj_tile)
		if entity and valid_target(entity):
			return entity  # Return the nearest valid enemy

	return null  # No valid targets found nearby


func follow_path(delta):

	if path.size() > 0 and path[0] == Vector2(current_tile):
		path.pop_front()
		update_tile(current_tile)
	if path.size() == 0:
		return

	#var adjacent_entity = find_nearest_adjacent_target(current_tile)

	#if adjacent_entity:
		#print("i ", get_parent(), " am at ", current_tile,". im going to clear my path")
		#path.clear()
		#update_tile(current_tile)

		#return

	#var next_tile = path[0]  # Get the next tile in the path
	#var next_pos = play_area.get_global_from_tile(next_tile)
	#next_pos += Vector2(-16,-16)

	#var entity = get_entity_at_tile(next_tile)

	var adjacent_target = find_nearest_adjacent_target(current_tile)

	if adjacent_target:
		update_tile(current_tile)
		path.clear()
		return
		#print("Entity at tile: ", next_tile, " is ", valid_target(entity))
		#if not valid_target(entity):
			# stop moving
			#print("this is not executing ")
			#print("im ", get_parent(), "target is valid")
			#return
		#else: #found entity but its not valid target
			#print(get_parent()," is blocked by ", adjacent_entity, " - finding a new path")
			#target = find_nearest_target()
			#path = generate_path(current_tile, target)
	#else:
		  # Remove the reached tile
	
	var next_tile = path[0]  # Get the next tile in the path
	
	var entity = get_entity_at_tile(next_tile)
	if entity:
		if not valid_target(entity):
			print(get_parent()," is blocked by ", entity, " - finding a new path")
			target = find_nearest_target()
			path = generate_path(current_tile, target)
			return
		
	
	var next_pos = play_area.get_global_from_tile(next_tile)
	#next_pos += Vector2(-16,-16)
	#next_pos = (next_pos / 32).floor() * 32
	next_pos = (next_pos / 16).floor() * 16 + Vector2(-16, -16)
	get_parent().global_position = get_parent().global_position.move_toward(next_pos, movement_speed * delta)
	#if get_parent().global_position.distance_to(next_pos) < movement_speed * delta:
		#get_parent().global_position = next_pos
	print(get_parent(), " moving to ", next_tile, 
	" global pos should be ", next_pos, 
	" but is ", get_parent().global_position)
		
	if get_parent().global_position.distance_to(next_pos) < 2:
		print(get_parent(), " chan removing ", path[0])
		path.pop_front()  # Remove the reached tile
		previous_tile = current_tile
		current_tile = next_tile
		update_tile(current_tile)
		print(get_parent(), " current: ", current_tile)
		print(unit_grid.units)
		print(get_parent(), " global: ",play_area.get_tile_from_global(get_parent().global_position))


func get_entity_at_tile(target_tile: Vector2i):
	return unit_grid.units.get(target_tile, null)


func update_tile(tile: Vector2i):
	var me = get_parent()
	unit_grid.remove_unit(previous_tile)
	unit_grid.add_entity(tile, me)


func _on_timer_timeout() -> void:
	if battle_started:
		path = generate_path(current_tile, target)
		if path.is_empty():
			pass
	pass # Replace with function body.
