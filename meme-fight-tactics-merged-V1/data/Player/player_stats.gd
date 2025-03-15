class_name PlayerStats
extends Resource

@export var current_level: int = 1
var xp_threshold := 10 
@export var experience: int = 0
@export var gold: int = 0
@export var deployable_units: int = 1
@export var units: Array = []
#@export var items: Array = []


func level_up() -> void:
	self.current_level += 1
	self.deployable_units += 1

func gain_xp(amount: int) -> void:
	var gained_xp = experience + amount
	if gained_xp >= xp_threshold:
		gained_xp -= xp_threshold
		level_up()
		self.experience = gained_xp
	self.experience += amount


func gain_gold(amount: int) -> void:
	self.gold += amount
