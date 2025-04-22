class_name PlayerStats
extends Resource

@export var current_level: int = 1
var xp_threshold := 10 
@export var experience: int = 0
@export var gold: int = 10000
@export var deployable_units: int = 1
#var units: Array[OwnedUnit] = []
var units := {} # Dictionary: { id: OwnedUnit }
var next_unit_id := 0
var items: Array = []
var buffs: Array[Buff] = []
var battles_won: int = 0

func level_up() -> void:
	current_level += 1
	deployable_units += 1
	xp_threshold += 10


func gain_xp(amount: int) -> void:
	var gained_xp = experience + amount
	if gained_xp >= xp_threshold:
		gained_xp -= xp_threshold
		level_up()
		experience = gained_xp
	experience += amount

func gain_gold(amount: int) -> void:
	gold += amount

func lose_gold(amount: int) -> void:
	gold -= amount

func add_unit(unit: OwnedUnit) -> void:
	units[next_unit_id] = unit
	next_unit_id += 1
	print(units)


func add_buff(buff: Buff):
	buffs.append(buff)
