class_name Run
extends Node

const choose_leader := null #preload the choose leader scene
const battle_scene := preload("res://scenes/battle_scene.tscn")
const basic_shop := preload("res://scenes/shop_phase.tscn")
const unit_shop := preload("res://scenes/unit_shop_phase.tscn")
const pause_menu := preload("res://menus/pause_menu.tscn")
const stats_overlay := preload("res://menus/player_stats_overlay.tscn")

@onready var map: Node2D = $Map
@onready var current_view: Node = $CurrentView

var player: PlayerStats 
var pause: Control = null
var stats_ovr: Node2D = null

func _ready() -> void:
	map.visible = false
	events.team_leader_selected.connect(_on_team_leader_selected)
	events.has_no_view.connect(_on_has_no_view)
	events.battle_entered.connect(_on_battle_entered)
	events.map_node_chosen.connect(_on_map_node_chosen)
	events.unit_died.connect(_on_unit_death)
	events.battle_lost.connect(_on_battle_lost)
	events.shop_item_purchased.connect(_on_shop_item_purchased)
	events.xp_purchased.connect(_on_xp_purchased)
	events.exit_shop.connect(_on_shop_exited)
	events.battle_over.connect(_on_battle_over)
	events.continue_button_pressed.connect(_on_continue_button_pressed)
	
	process_mode = Node.PROCESS_MODE_ALWAYS #for pause menu

func _on_team_leader_selected(leader: OwnedUnit):
	player = PlayerStats.new()
	
	player.add_unit(leader)
	#print(player.units)
	
	events.leader_selection_exited.emit()
	var overlay = stats_overlay.instantiate()
	overlay.player_stats = player
	add_child(overlay)


func _on_has_no_view():
	map.visible = true


func _on_battle_entered():
	var bench = get_node("CurrentView/Battle/Bench/BenchUnitGrid")
	bench.fill_bench(player.units)


func _on_map_node_chosen(type):
	var map_node_actions = {
		"battle": load_battle,
		"basic_shop": load_basic_shop,
		"unit_shop": load_unit_shop
	}
	if map_node_actions.has(type):
		map.visible = false
		map_node_actions[type].call()
	else:
		print("unknown node type: %s" % type)


func load_battle():
	var battle = battle_scene.instantiate()
	
	if player.current_level < 3:
		battle.get_node("EnemySpawner").max_enemies = 3
		
	get_node("CurrentView").add_child(battle)
func load_basic_shop():
	var b_shop = basic_shop.instantiate()
	b_shop.player_stats = player
	get_node("CurrentView").add_child(b_shop)
func load_unit_shop():
	var u_shop = unit_shop.instantiate()
	u_shop.player_stats = player 
	get_node("CurrentView").add_child(u_shop)


func _on_unit_death(entity: Unit):
	for key in player.units:
		if key == entity.unique_id:
			player.units.erase(key)
			break


func _on_battle_over():
	player.battles_won += 1
	player.gain_xp(2)
	

	var remaining_units = get_node("/root/Run/CurrentView/Battle/GameArea/BattleUnitGrid").get_children()
	for unit in remaining_units:
		var unique_id = unit.unique_id
		if player.units.has(unique_id):
			player.units[unique_id].stats = unit.stats
			print("battle over stats:\n", "health: ", player.units[unique_id].stats.health)
		else:
			print("Warning: No matching profile for unit with id: ", unique_id)

func _on_continue_button_pressed():
	map.visible = true


func _on_battle_lost():
	#TODO change this to a game over screen 
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")


func _on_shop_item_purchased(item):
	if item is Buff:
		for unit in player.units:
			unit.apply_buff(item)
	elif item is DraggableUnit:
		var duplicate_units := 0
		for unit in player.units:
			if unit.unit_id == item.unit_id:
				duplicate_units += 1

		if duplicate_units == 3:
			events.upgrade_unit.emit(item.unit_id)


func _on_xp_purchased(amount: int):
	player.gain_xp(amount)


func _on_shop_exited():
	map.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		if get_tree().paused:
			_resume_game()
		else:
			_pause_game()
	
	if event.is_action_pressed("toggle_stats_overlay"):
		if stats_ovr and stats_ovr.is_inside_tree():
			_hide_stats()
		else:
			if player:
				_show_stats()

	
func _pause_game() -> void:
	get_tree().paused = true
	pause = pause_menu.instantiate()
	add_child(pause)
	pause.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause.connect("resume", self._resume_game)
	pause.connect("exit_to_map", self._on_return_to_map) 
	pause.connect("exit_to_main_menu", self._quit_to_menu)


func _resume_game() -> void:
	get_tree().paused = false
	if pause and pause.is_inside_tree():
		pause.queue_free()
		pause = null

func _quit_to_menu() -> void:
	_resume_game()
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")

		
func _on_return_to_map() -> void:
	_resume_game()
	map.visible = true
	for child in current_view.get_children():
		child.queue_free()


func _show_stats() -> void:
	stats_ovr = stats_overlay.instantiate()
	stats_ovr.player_stats = player
	add_child(stats_ovr)


func _hide_stats() -> void:
	if stats_ovr and stats_ovr.is_inside_tree():
		stats_ovr.queue_free()
		stats_ovr = null
