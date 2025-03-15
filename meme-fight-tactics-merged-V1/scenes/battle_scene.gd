class_name Battle
extends Node2D

const CELL_SIZE := Vector2(32, 32)
const HALF_CELL_SIZE := Vector2(16, 16)
const QUARTER_CELL_SIZE := Vector2(8, 8)

signal battle_started

func start_battle():
	print("Battle starting!")
	battle_started.emit()

# next:
# get units + enemies to path towards each other,
# everyone fights (health, dmg, energy, etc)

#NOTE:
# see if oyu need to make sure that any enemy spawned is grouped with all types 'enemy'


func _on_pre_battle_over() -> void:
	start_battle()
