class_name Map
extends Node2D

const SCROLL_SPEED := 15
const MAP_ENCOUNTER = preload("res://map_assets/map_encounter.tscn")
const MAP_LINE = preload("res://map_assets/map_line.tscn")

@onready var map_generator: MapGenerator = $MapGenerator
@onready var lines: Node2D = %lines
@onready var encounters: Node2D = $"%encounters"
@onready var visuals: Node2D = $visuals
@onready var camera_2d: Camera2D = $Camera2D

var map_data: Array[Array]
var columns_traversed: int
var last_encounter: Encounter
var camera_edge_x: float
var camera_edge_y: float

func _ready() -> void:
	var absolute_path = OS.get_user_data_dir() + "/saved_map_state.json"
	print("Saved state path: ", absolute_path)
	camera_edge_x = map_generator.x_dist * (map_generator.map_width)
	camera_edge_y = map_generator.y_dist * (map_generator.floors)
	if _load_map_state():
		free_children(encounters)
		free_children(lines)
		create_map()
	else:
		print("failed to load saved map state, generating new")
		generate_new_map()
	
func _input(event: InputEvent) -> void:
	var MOVE_SPEED := 10
	if Input.is_action_pressed("ui_right"):
		camera_2d.position.x += MOVE_SPEED
	if Input.is_action_pressed("ui_left"):
		camera_2d.position.x -= MOVE_SPEED
	if Input.is_action_pressed("ui_down"):
		camera_2d.position.y += MOVE_SPEED
	if Input.is_action_pressed("ui_up"):
		camera_2d.position.y -= MOVE_SPEED
		
	camera_2d.position.x = clamp(camera_2d.position.x, camera_edge_x, 0)
	camera_2d.position.y = clamp(camera_2d.position.y, 0, camera_edge_y)
	
	
func generate_new_map() -> void:
	columns_traversed = 0
	map_data = map_generator._generate_map()
	create_map()
	

func create_map() -> void:
	for current_floor: Array in map_data:
		for encounter: Encounter in current_floor:
			_spawn_encounter(encounter)
		
	var middle := floori(MapGenerator.floors * 0.5)
	_spawn_encounter(map_data[middle][MapGenerator.map_width-1])
	
	var map_width_pixels := MapGenerator.x_dist * (MapGenerator.map_width - 1)
	visuals.position.x = (get_viewport_rect().size.x - map_width_pixels) / 2
	visuals.position.y = get_viewport_rect().size.y / 2
	
	lock_past_encounters()
	
func unlock_column(which_column: int = columns_traversed) -> void:
	for map_encounter: MapEncounter in encounters.get_children():
		if map_encounter.encounter.column == which_column:
			map_encounter.available = true 
			

func unlock_next_encounters() -> void:
	for map_encounter in encounters.get_children() as Array[MapEncounter]:
		# Unlock encounters only in the next column relative to the last selected encounter.
		if map_encounter.encounter.column == last_encounter.column + 1:
			map_encounter.available = true


func lock_past_encounters() -> void:
	for map_encounter in encounters.get_children() as Array[MapEncounter]:
		if map_encounter.encounter.column < columns_traversed:
			map_encounter.available = false
			# Optionally, update its visuals to reflect that it's locked

func show_map() -> void:
	show()
	Camera2D.enabled = true


func hide_map() -> void:
	hide()
	camera_2d.enabled = false

func _spawn_encounter(encounter: Encounter) -> void:
	var new_map_encounter := MAP_ENCOUNTER.instantiate() as MapEncounter
	encounters.add_child(new_map_encounter)
	new_map_encounter.encounter = encounter
	new_map_encounter.selected.connect(_on_map_encounter_selected)
	_connect_lines(encounter)
	
	if encounter.selected: # and encounter.column < columns_traversed:
		new_map_encounter.show_selected()
		new_map_encounter.available = false 


func _connect_lines(encounter: Encounter) -> void:
	if encounter.next_encounters.is_empty():
		return
	
	for next: Encounter in encounter.next_encounters:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(encounter.position)
		new_map_line.add_point(next.position)
		lines.add_child(new_map_line)


func _on_map_encounter_selected(encounter: Encounter) -> void:
	# Lock all encounters in columns <= selected encounter's column (except the one just selected)
	for map_encounter in encounters.get_children() as Array[MapEncounter]:
		if map_encounter.encounter.column <= encounter.column and map_encounter != encounter:
			map_encounter.available = false
			
	last_encounter = encounter
	# Update progress: if the player has selected an encounter, then the next column is the one to unlock.
	columns_traversed = max(columns_traversed, encounter.column + 1)
	
	unlock_next_encounters()
	_save_map_state()


func _save_map_state() -> void:
	var save_data = {
		"columns_traversed": columns_traversed,
		"map_data": []
	}
	for row in map_data:
		var row_data = []
		for encounter in row:
			var encounter_data = {
				"row": encounter.row,
				"column": encounter.column,
				"position": [encounter.position.x, encounter.position.y],
				"type": int(encounter.type),
				"selected": encounter.selected,
				"next_encounters": []
			}
			for next_enc in encounter.next_encounters:
				encounter_data["next_encounters"].append({
					"row": next_enc.row,
					"column": next_enc.column
				})
			row_data.append(encounter_data)
		save_data["map_data"].append(row_data)
	
	var map_state_path = "user://saved_map_state.json"
	var file = FileAccess.open(map_state_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print(save_data)
		print("file saved")
	else:
		print("ERROR: file not found")


func _load_map_state() -> bool:
	var map_state_path = "user://saved_map_state.json"
	if not FileAccess.file_exists(map_state_path):
		print("No saved map state found!")
		return false
	
	var file = FileAccess.open(map_state_path, FileAccess.READ)
	var data_text = file.get_as_text()
	file.close()
	
	var parse_result = JSON.parse_string(data_text)
	var error_code = parse_result.get("error", 0)
	if error_code != 0:
		print("Error parsing saved map state! Error code: ", error_code)
		return false
	
	var loaded_data: Dictionary
	if parse_result.has("result"):
		loaded_data = parse_result["result"]
	else:
		loaded_data = parse_result
	
	# Check if the saved map_data is empty
	if not loaded_data.has("map_data") or loaded_data["map_data"].is_empty():
		print("Saved map state is empty!")
		return false
	
	# Restore progress (columns_traversed)
	if loaded_data.has("columns_traversed"):
		columns_traversed = loaded_data["columns_traversed"]
	else:
		columns_traversed = 0
	
	# Rebuild map_data from loaded data
	map_data.clear()
	for row_data in loaded_data["map_data"]:
		var row = []
		for encounter_data in row_data:
			var encounter = Encounter.new()
			encounter.row = encounter_data["row"]
			encounter.column = encounter_data["column"]
			encounter.position = Vector2(encounter_data.get("position", [0,0])[0], encounter_data.get("position", [0,0])[1])
			encounter.type = encounter_data["type"]
			encounter.selected = encounter_data["selected"]
			# Initialize next_encounters as an empty array; we'll restore them next.
			encounter.next_encounters = [] as Array[Encounter]
			row.append(encounter)
		map_data.append(row)
	
	# Second pass: restore next_encounters based on saved row and column indices
	for i in range(map_data.size()):
		for j in range(map_data[i].size()):
			var encounter = map_data[i][j]
			var saved_next = loaded_data["map_data"][i][j]["next_encounters"]
			for next_enc_data in saved_next:
				var next_encounter = map_data[next_enc_data["row"]][next_enc_data["column"]]
				encounter.next_encounters.append(next_encounter)
	
	print("Map state loaded!")
	return true


func free_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
