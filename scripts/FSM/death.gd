class_name Death
extends State

@export var unit_grid: UnitGrid
@onready var owner_entity = get_parent().get_parent()


func enter():
	unit_grid = fsm.battle.get_node("GameArea/BattleUnitGrid")

	print(owner_entity, " is dying")
	if owner_entity.is_in_group("leader"):
		events.battle_lost.emit()
	
	var units = unit_grid.units
	for key in units:
		if units[key] == owner_entity:
			unit_grid.remove_unit(key)
	
	if owner_entity.is_in_group("enemies"):
		fsm.battle.enemy_count -= 1
	elif owner_entity.is_in_group("units"):
		events.unit_died.emit(owner_entity)
		fsm.battle.unit_count -= 1
	fsm.battle.units_dead += 1
	if owner_entity.is_inside_tree():
		owner_entity.get_parent().remove_child(owner_entity)
		owner_entity.queue_free()
	


func exit():
	pass


func update(_delta:float):
	pass
	
