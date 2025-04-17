class_name Run
extends Node

const choose_leader := null #preload the choose leader scene
const battle_scene := preload("res://scenes/battle_scene.tscn")
const basic_shop := preload("res://menus/shop_phase.tscn")
const unit_shop := preload("res://menus/unit_shop_phase.tscn")

@onready var map: Node2D = $Map
@onready var current_view: Node = $CurrentView

var player: PlayerStats

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
	events.battle_over.connect(_on_battle_over)
	events.continue_button_pressed.connect(_on_continue_button_pressed)


func _on_team_leader_selected(leader: Node):
	player = PlayerStats.new()
	
	leader.unit_id = 0
	player.add_unit(leader)
	#print(player.units)
	events.leader_selection_exited.emit()


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
	get_node("CurrentView").add_child(b_shop)
func load_unit_shop():
	var u_shop = unit_shop.instantiate()
	get_node("CurrentView").add_child(u_shop)


func _on_unit_death(entity: Unit):
	for unit in player.units:
		if unit.unit_id == entity.unit_id:
			player.units.erase(unit)
			break


func _on_battle_over():
	player.battles_won += 1
	player.gain_xp(2)


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
