class_name FSM
extends Node

var states: Dictionary = {}
var current_state: State

@export var initial_state: State
@export var attack_range: Area2D

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition.connect(change_state)
		
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.update(delta)


func change_state(old_state: State, new_state_name: String):
	if old_state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		print("Error: No new state found from state name ", new_state_name)
		return
	
	if current_state:
		current_state.exit()
	
	new_state.enter()
	
	current_state = new_state
