class_name Encounter
extends Resource

enum Type {NOT_ASSIGNED, BATTLE, AB_SHOP, U_SHOP, SPECIAL_EVENT, BOSS_BATTLE}

@export var type: Type 
@export var row: int     				#horizontal index in the grid
@export var column: int  				#vertical index in the grid
@export var position: Vector2 			#the actual 2d postion
@export var next_encounters: Array[Encounter] = []
@export var selected := false

func _to_string() -> String:
	return "%s (%s)" % [column, Type.keys()[type][0]] 
