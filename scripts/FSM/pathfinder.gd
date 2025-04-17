class_name Pathfinder
extends State


@export var battle: Battle
@export var unit_grid: UnitGrid
@export var movement_speed: float = 60.0
@export var play_area: PlayArea

var path: Array = []
var current_tile: Vector2i
var previous_tile: Vector2i
var target: Vector2i
var battle_started: bool
var target_entity = null

@onready var owner_entity = get_parent().get_parent()

func _ready() -> void:
	#debug battle scene
	#battle = get_node("/root/Battle")
	
	battle = get_node("/root/Run/CurrentView/Battle")

	if owner_entity.is_in_group("enemies"):
		await battle.ready
	unit_grid = battle.get_node("GameArea/BattleUnitGrid")  # Avoid crashes
	play_area = battle.get_node("GameArea")

	if battle:
		battle.battle_started.connect(_on_battle_started)

func enter():
	if battle_started:
		owner_entity.anim.play("idle")
		target = find_nearest_target()
		path = generate_path(target)
	
		if target:
			fsm.target = target

# will need to set up moving animation 
# in either enter or update

func update(delta):
	if battle_started:
		follow_path(delta)
		


func exit():
	#stop moving animation
	fsm.target = target_entity
	path.clear()
	pass


func _on_battle_started():
	battle_started = true

	
	current_tile = play_area.get_tile_from_global(owner_entity.global_position)
	
	target = find_nearest_target()
	
	path = generate_path(target)

	#print(owner_entity, " current tile ", current_tile," path to target: ",path)
	return


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
	# if this is attached to an enemy, find player units
	# if this is attached to a player, find enemies
	if owner_entity.is_in_group("enemies"):
		return unit.is_in_group("units")
	else:
		return unit.is_in_group("enemies")


func generate_path(target_tile: Vector2i) -> Array:
	path.clear()
	if not unit_grid.astar.has_point(unit_grid.get_tile_id(current_tile.x, current_tile.y)):
		print("Error: Start tile not found in AStar!")
		return []

	if not unit_grid.astar.has_point(unit_grid.get_tile_id(target_tile.x, target_tile.y)):
		print("Error: Target tile not found in AStar!")
		return []

	var disabled_tiles = []
	for tile in unit_grid.units.keys():
		var entity = get_entity_at_tile(tile)
		if entity and not valid_target(entity):  # if occupied and not a valid target
			var tile_id = unit_grid.get_tile_id(tile.x, tile.y)
			if unit_grid.astar.has_point(tile_id):
				unit_grid.astar.set_point_disabled(tile_id, true)  # Disable it
				disabled_tiles.append(tile_id)

	# convert Vector2i tiles to AStar node IDs
	var start_id = unit_grid.get_tile_id(current_tile.x, current_tile.y)
	var target_id = unit_grid.get_tile_id(target_tile.x, target_tile.y)

	# get path from AStar
	var path_ids = unit_grid.astar.get_id_path(start_id, target_id)

	# reenable the tiles after pathfinding
	for tile_id in disabled_tiles:
		unit_grid.astar.set_point_disabled(tile_id, false)

	if path_ids.is_empty():
		#print(owner_entity, " No path found!")
		return []

	# convert path IDs to global positions
	var path_positions = []
	for id in path_ids:
		path_positions.append(unit_grid.astar.get_point_position(id))

	return path_positions


func follow_path(_delta):
	if path.is_empty():
		path = generate_path(target)
		if !path:
			target = find_nearest_target()
			if !target: #new
				return
			path = generate_path(target)
		return

	if path[0] == Vector2(current_tile):
		path.pop_front()
		update_tile(current_tile)
		if path.is_empty():
			return

	var next_tile = path[0]

	# check if path is blocked
	var entity = get_entity_at_tile(next_tile)
	if entity and not valid_target(entity):  
		target = find_nearest_target()
		path = generate_path(target)
		return

	# tile position to global position
	var next_pos = play_area.get_global_from_tile(next_tile)
	next_pos = (next_pos / 16).floor() * 16 + Vector2(-16, -16)

	if next_tile in unit_grid.reserved_tiles:
		if unit_grid.reserved_tiles[next_tile] != self:
			target = find_nearest_target()
			path = generate_path(target)
			return
	else:
		unit_grid.reserved_tiles[next_tile] = self

	# check for targets in range
	if fsm.attack_range and fsm.attack_range.get_overlapping_bodies():
		for body in fsm.attack_range.get_overlapping_bodies():
			if valid_target(body):  
				unit_grid.reserved_tiles.erase(next_tile)
				update_tile(current_tile)
				path.clear()
				target_entity = body
				state_transition.emit(self, "attacking")
				return  

	# move towards the next tile
	var direction = (next_pos - owner_entity.global_position).normalized()
	owner_entity.velocity = direction * movement_speed
	owner_entity.move_and_slide()

	# check if we reached the next tile
	if owner_entity.global_position.distance_to(next_pos) < 2:
		path.pop_front()
		unit_grid.reserved_tiles.erase(next_tile)
		previous_tile = current_tile
		current_tile = next_tile
		update_tile(current_tile)


func get_entity_at_tile(target_tile: Vector2i):
	return unit_grid.units.get(target_tile, null)


func update_tile(tile: Vector2i):
	unit_grid.remove_unit(previous_tile)
	unit_grid.add_entity(tile, owner_entity)


# we might need this if problems arise
#func _on_attack_range_body_entered(body: Node) -> void:
		#if valid_target(body):  
			#unit_grid.reserved_tiles.erase(next_tile)
			#update_tile(current_tile)
			#path.clear()
			#state_transition.emit(self, "attacking")
			#return
