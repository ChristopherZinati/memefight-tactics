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
	camera_edge_x = map_generator.x_dist * (map_generator.map_width)
	camera_edge_y = map_generator.y_dist * (map_generator.floors)
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
			if encounter.next_encounters.size() > 0:
				_spawn_encounter(encounter)
		
	var middle := floori(MapGenerator.floors * 0.5)
	_spawn_encounter(map_data[middle][MapGenerator.map_width-1])
	
	var map_width_pixels := MapGenerator.x_dist * (MapGenerator.map_width - 1)
	visuals.position.x = (get_viewport_rect().size.x - map_width_pixels) / 2
	visuals.position.y = get_viewport_rect().size.y / 2
	
	
func unlock_column(which_column: int = columns_traversed) -> void:
	for map_encounter: MapEncounter in encounters.get_children():
		if map_encounter.encounter.column == which_column:
			map_encounter.available = true 
			

func unlock_next_encounters() -> void:
	for map_encounter in encounters.get_children() as Array[MapEncounter]:
		if last_encounter.next_encounters.has(map_encounter.encounter):
			map_encounter.available = true

			if map_encounter.encounter.next_encounters.size() > 1:
				for next_encounter in map_encounter.encounter.next_encounters:
					# Unlock any additional paths at the branching point
					for extra_map_encounter in encounters.get_children():
						if extra_map_encounter.encounter == next_encounter:
							extra_map_encounter.available = true


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
	
	if encounter.selected and encounter.column < columns_traversed:
		new_map_encounter.show_selected()


func _connect_lines(encounter: Encounter) -> void:
	if encounter.next_encounters.is_empty():
		return
	
	for next: Encounter in encounter.next_encounters:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(encounter.position)
		new_map_line.add_point(next.position)
		lines.add_child(new_map_line)


func _on_map_encounter_selected(encounter: Encounter) -> void:
	for map_encounter in encounters.get_children() as Array[Encounter]:
		if map_encounter.encounter.column == encounter.column and map_encounter != encounter:
			map_encounter.available = false
			
	last_encounter = encounter
	columns_traversed += 1
	_save_map_state()
	unlock_next_encounters()


func _save_map_state():
	var save_data = {
		"map_data" : []
	}
	for row in map_data:
		var row_data = []
		for encounter in row:
			var encounter_data = {
				"row": encounter.row,
				"column": encounter.column,
				"postition": [encounter.position.x, encounter.position.y],
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
	
	var map_state_path = "res://data/Player/saved_map_state.json"
	var file = FileAccess.open(map_state_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print(save_data)
		print("file saved")
	else:
		print("ERROR: file not found")
		
