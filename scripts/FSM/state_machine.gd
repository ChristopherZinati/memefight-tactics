class_name FSM
extends Node

var states: Dictionary = {}
var current_state: State

@export var initial_state: State
@export var attack_range: Area2D
@export var battle: Battle

var target = null

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition.connect(change_state)
			child.fsm = self
		
	if initial_state:
		initial_state.enter()
		current_state = initial_state
	
	
	get_parent().die.connect(_on_die_signal)
	
	#debug
	#battle = get_node("/root/Battle")

	battle = get_node("/root/Run/CurrentView/Battle")

	if get_parent().is_in_group("enemies"):
		await battle.ready
	
	if battle:
		events.battle_over.connect(_on_battle_over)


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


func _on_die_signal():
	force_state_change("death")


func _on_battle_over():
	force_state_change("winning")


func force_state_change(state: String):
	var new_state = states.get(state.to_lower())
	
	if !new_state:
		return
		
	if current_state:
		var exit_callable = Callable(current_state, "exit")
		exit_callable.call_deferred()
	
	new_state.enter()
	current_state = new_state


func set_target(new_target):
	target = new_target
