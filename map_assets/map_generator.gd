class_name MapGenerator
extends Node

const x_dist := 64
const y_dist := 48
const placement_randomness := 6
const floors := 4
const map_width := 8
const paths := 4

const BATTLE_weight := 4.0
const AB_SHOP_weight := 6.0
const U_SHOP_weight := 5.5
const SPECIAL_EVENT_weight := 2.0
const BOSS_weight := 1.0

var random_encounter_type_weights = {
	Encounter.Type.BATTLE : 0.0,
	Encounter.Type.AB_SHOP : 0.0,
	Encounter.Type.U_SHOP : 0.0,
	Encounter.Type.SPECIAL_EVENT : 0.0,
	Encounter.Type.BOSS_BATTLE : 0.0
}
var random_encounter_type_total_weight := 0
var map_data: Array[Array]

func _generate_map() -> Array[Array]:
	# Assign the grid to the member variable.
	map_data = _generate_initial_grid()
	var starting_points = _get_random_starting_points()
	
	# For each starting point (which is a row index), build horizontal paths.
	for starting_row in starting_points:
		var current_i := starting_row as int
		# Loop through columns from 0 to map_width - 2 (so that j+1 is valid)
		for j in range(map_width - 1):
			current_i = _setup_connection(j, current_i)
	
	_setup_boss_encounter()
	_setup_random_encounter_weights()
	_setup_encounter_types()
		
	return map_data
	

func _generate_initial_grid() -> Array[Array]:
	var result: Array[Array] = []
	# Create a grid of floors (rows) x map_width (columns)
	for i in range(floors):
		var adjacent_encounters: Array[Encounter] = []
		for j in range(map_width):
			var current_encounter = Encounter.new()
			var offset := Vector2(randf(), randf()) * placement_randomness
			var grid_height = (floors - 1) * y_dist
			var vertical_offset = grid_height / 2
			current_encounter.position = Vector2(j * x_dist, i * y_dist) + offset - Vector2(0, vertical_offset)
			current_encounter.row = i
			current_encounter.column = j
			current_encounter.next_encounters = [] as Array[Encounter]
			
			# Adjust x-position for the last column if needed.
			if j == map_width - 1:
				current_encounter.position.x = (j + 1) * x_dist
			
			adjacent_encounters.append(current_encounter)
		result.append(adjacent_encounters)
	return result


func _get_random_starting_points() -> Array[int]:
	var y_coordinates: Array[int]
	var unique_points: int = 0
	
	# Continue until you get at least 2 unique starting points.
	while unique_points < 2:
		unique_points = 0 
		y_coordinates = []
		for i in range(paths):
			var starting_point := randi_range(0, floors - 1)
			if not y_coordinates.has(starting_point):
				unique_points += 1
			y_coordinates.append(starting_point)
			
	return y_coordinates


func _setup_connection(j: int, i: int) -> int:
	var next_encounter: Encounter = null
	var current_encounter := map_data[i][j] as Encounter
	
	# Keep selecting a candidate encounter until it doesn't cross an existing path.
	while not next_encounter or _would_cross_existing_path(i, j, next_encounter):
		var random_row := clampi(randi_range(i - 1, i + 1), 0, floors - 1)
		next_encounter = map_data[random_row][j+1]
		
	current_encounter.next_encounters.append(next_encounter)
	return next_encounter.row


func _would_cross_existing_path(i: int, j: int, encounter: Encounter) -> bool:
	var top_neighbor: Encounter = null
	var bottom_neighbor: Encounter = null
	
	if i > 0:
		top_neighbor = map_data[i-1][j]
	if i < floors - 1:  # Check row index, not j.
		bottom_neighbor = map_data[i+1][j]
		
	for previous_encounter in map_data[i][j].next_encounters:
		if (previous_encounter.row < i and encounter.row > i) or (previous_encounter.row > i and encounter.row < i):
			return true  # A crossing path is detected
	
	# For horizontal paths, ensure the connection doesn't cross with neighbors.
	if bottom_neighbor and encounter.row > i:
		for next_encounter: Encounter in bottom_neighbor.next_encounters:
			if next_encounter.row > encounter.row:
				return true
	
	if top_neighbor and encounter.row < i:
		for next_encounter: Encounter in top_neighbor.next_encounters:
			if next_encounter.row < encounter.row:
				return true
	
	return false


func _setup_boss_encounter()-> void:
	var middle :=floori(floors * 0.5)
	var boss_encounter := map_data[middle][map_width - 1] as Encounter
	
	for  i in floors:
		var current_encounter = map_data[i][map_width - 2] as Encounter
		if current_encounter.next_encounters:
			current_encounter.next_encounters = [] as Array[Encounter]
			current_encounter.next_encounters.append(boss_encounter)
			
	boss_encounter.type = Encounter.Type.BOSS_BATTLE
	
func _setup_random_encounter_weights()-> void:
	random_encounter_type_weights[Encounter.Type.BATTLE] = BATTLE_weight
	random_encounter_type_weights[Encounter.Type.AB_SHOP] = BATTLE_weight + AB_SHOP_weight
	random_encounter_type_weights[Encounter.Type.U_SHOP] = BATTLE_weight + AB_SHOP_weight + U_SHOP_weight
	random_encounter_type_weights[Encounter.Type.SPECIAL_EVENT] = BATTLE_weight + AB_SHOP_weight + U_SHOP_weight + SPECIAL_EVENT_weight
	#random_encounter_type_weights[Encounter.Type.BOSS_BATTLE] = BATTLE_weight + AB_SHOP_weight + U_SHOP_weight + SPECIAL_EVENT_weight + BOSS_weight
	
	random_encounter_type_total_weight = random_encounter_type_weights[Encounter.Type.SPECIAL_EVENT]
	

func _setup_encounter_types() -> void:
	for encounter: Encounter in map_data[0]:
		if encounter.next_encounters.size() > 0:
			encounter.type = Encounter.Type.BATTLE
	
	#always a shop before a boss battle
	for i in range(floors):
		var encounter := map_data[i][map_width - 2] as Encounter
		if encounter.next_encounters.size() > 0:
			var randint = randf_range(0.0, 1.0)
			if randint > 0.6:
				encounter.type = Encounter.Type.AB_SHOP
			else:
				encounter.type = Encounter.Type.U_SHOP
	
	for current_row in map_data:
		for encounter: Encounter in current_row:
			for next_encounter: Encounter in encounter.next_encounters:
				if next_encounter.type == Encounter.Type.NOT_ASSIGNED:
					_set_encounter_randomly(next_encounter)


func _set_encounter_randomly(encounter_to_set: Encounter) -> void:
	var shop_left_of_row2 := true
	var consecutive_shops := false
	var consecutive_special_events := false
	var shop_on_row_15 := true
	
	var type_candidate: Encounter.Type
	
	while shop_left_of_row2 or consecutive_shops or consecutive_special_events or shop_on_row_15:
		type_candidate = _get_random_encounter_by_weight()
		
		var is_ab_shop := type_candidate == Encounter.Type.AB_SHOP
		var has_ab_shop_parent := _encounter_has_parent_of_type(encounter_to_set, Encounter.Type.AB_SHOP)
	
		var is_u_shop := type_candidate == Encounter.Type.U_SHOP
		var has_u_shop_parent := _encounter_has_parent_of_type(encounter_to_set, Encounter.Type.U_SHOP)
		
		shop_left_of_row2 = (is_ab_shop or is_u_shop) and encounter_to_set.row < 1
		consecutive_shops = (is_ab_shop or is_u_shop) and (has_ab_shop_parent or has_u_shop_parent)
		shop_on_row_15 = (is_ab_shop or is_u_shop) and encounter_to_set.row == 14
	
	encounter_to_set.type = type_candidate
	
func _encounter_has_parent_of_type(encounter: Encounter, type: Encounter.Type) -> bool:
	var parents: Array[Encounter] = []
	
	if encounter.row > 0 and encounter.column > 0:
		var parent_candidate := map_data[encounter.row - 1][encounter.column -1] as Encounter
		if parent_candidate.next_encounters.has(encounter):
			parents.append(parent_candidate)
	
	#parent above
	if encounter.row < floors-1:
		var parent_candidate := map_data[encounter.row][encounter.column -1] as Encounter
		if parent_candidate.next_encounters.has(encounter):
			parents.append(parent_candidate)
			
	#parent below
	if encounter.row > 0:
		var parent_candidate := map_data[encounter.row][encounter.column -1] as Encounter
		if parent_candidate.next_encounters.has(encounter):
			parents.append(parent_candidate)
	
	for parent: Encounter in parents:
		if parent.type == type:
			return true
	
	return false


func _get_random_encounter_by_weight() -> Encounter.Type:
	var roll := randf_range(0.0, random_encounter_type_total_weight)
	
	for type: Encounter.Type in random_encounter_type_weights:
		if random_encounter_type_weights[type] > roll:
			return type
			
	return Encounter.Type.BOSS_BATTLE
	
