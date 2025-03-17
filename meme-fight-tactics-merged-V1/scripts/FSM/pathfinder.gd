class_name Pathfinder
extends State


@export var battle: Battle
@export var unit_grid: UnitGrid
@export var movement_speed: float = 100.0
@onready var astar = AStar2D.new()
@export var play_area: PlayArea

var path: Array = []
var current_tile: Vector2i
var previous_tile: Vector2i
var target: Vector2i
var battle_started: bool
var pathing: bool

@onready var parent = get_parent().get_parent()
@onready var attack_range = parent.get_node("AttackRange")

func enter():
	battle = get_node("/root/Battle")
	
	if parent.is_in_group("enemies"):
		await battle.ready
	unit_grid = battle.get_node("/root/Battle/GameArea/BattleUnitGrid")  # Avoid crashes
	play_area = battle.get_node("/root/Battle/GameArea")

	if battle:
		battle.battle_started.connect(_on_battle_started)

	if battle_started:
		attack_range = parent.get_node("AttackRange")  # Adjust if needed
		if attack_range:
			attack_range.connect("area_entered", _on_attack_range_entered)
	
		pathing = true
	
		target = find_nearest_target()
		path = generate_path(current_tile, target)


func update(delta):
	if battle_started:
		if path.is_empty():
			target = find_nearest_target()
			path = generate_path(current_tile, target)
		if !path.is_empty():
			follow_path(delta)
	pass


func exit():
	pathing = false

	print(parent, "exiting pathing\n", unit_grid.units)
	attack_range = get_parent().find_child("AttackRange")
	if attack_range and attack_range.is_connected("area_entered", _on_attack_range_entered):
		attack_range.disconnect("area_entered", _on_attack_range_entered)


func _on_attack_range_entered(body):
	if battle_started:
		if valid_target(body):  
			state_transition.emit(self, "attacking")  # Change to attack state


#func _ready():
	#battle = get_node("/root/Battle")
	
	#if parent.is_in_group("enemies"):
		#await battle.ready
	#unit_grid = battle.get_node("/root/Battle/GameArea/BattleUnitGrid")  # Avoid crashes
	#play_area = battle.get_node("/root/Battle/GameArea")

	#if battle:
		#battle.battle_started.connect(_on_battle_started)


func _on_battle_started():
	battle_started = true

	setup_astar_grid(unit_grid, 1)
	
	current_tile = play_area.get_tile_from_global(parent.global_position)
	#if parent.is_in_group("units"):
		#print("current tile: ", current_tile, "pos: ", parent.global_position)
	target = find_nearest_target()
	
	path = generate_path(current_tile, target)

	print(parent, " current tile ", current_tile," path to target: ",path)
	return


func _physics_process(delta):
	if battle_started and pathing:
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
	
	var nearest_target = Vector2i(-1,-1)
	var shortest_distance = INF
	
	for tile in all_units:
		var unit = all_units[tile]
		if unit:
			if valid_target(unit):
				var distance = my_tile.distance_to(tile)
				if distance < shortest_distance:
					shortest_distance = distance
					nearest_target = tile
	return nearest_target


func valid_target(unit):
	# If this is attached to an enemy, find player units.
	# If this is attached to a player, find enemies.
	if parent.is_in_group("enemies"):
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
		#print(parent, " No path found!")
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


func follow_path(_delta):
	if path.size() > 0 and path[0] == Vector2(current_tile):
		path.pop_front()
		update_tile(current_tile)
	
	#if path.size() == 0:
		#parent.velocity = Vector2.ZERO  # Stop movement when there’s no path
		#return

	# Check if an adjacent enemy exists to stop movement
	var adjacent_target = find_nearest_adjacent_target(current_tile)
	if adjacent_target:
		update_tile(current_tile)
		path.clear()
		parent.velocity = Vector2.ZERO
		return

	var next_tile = path[0]
	var entity = get_entity_at_tile(next_tile)

	# If the next tile is blocked, recalculate path
	if entity and not valid_target(entity):
		#print(parent," is blocked by ", entity, " - finding a new path")
		target = find_nearest_target()
		
		path = generate_path(current_tile, target)
		return

	
	# Convert next tile to global position
	var next_pos = play_area.get_global_from_tile(next_tile)
	next_pos = (next_pos / 16).floor() * 16 + Vector2(-16, -16)

	# Move using physics-based movement
	var direction = (next_pos - parent.global_position).normalized()
	parent.velocity = direction * movement_speed
	parent.move_and_slide()  # Apply movement
	
	
	if attack_range and attack_range.get_overlapping_bodies():
		for body in attack_range.get_overlapping_bodies():
			if valid_target(body):  # Check if the unit is in range and a valid target
					# Transition to the "attacking" state
				state_transition.emit(self, "attacking")
				break  
	
	# Check if we reached the next tile
	if parent.global_position.distance_to(next_pos) < 2:
		path.pop_front()
		previous_tile = current_tile
		current_tile = next_tile
		update_tile(current_tile)
		#print(unit_grid.units)
		
		#if attack_range and attack_range.get_overlapping_bodies():
			#for body in attack_range.get_overlapping_bodies():
				#if valid_target(body):  # Check if the unit is in range and a valid target
					# Transition to the "attacking" state
					#state_transition.emit(self, "attacking")
					#break  # Transition to attacking state once we find a valid target



func get_entity_at_tile(target_tile: Vector2i):
	return unit_grid.units.get(target_tile, null)


func update_tile(tile: Vector2i):
	var me = parent
	unit_grid.remove_unit(previous_tile)
	unit_grid.add_entity(tile, me)
