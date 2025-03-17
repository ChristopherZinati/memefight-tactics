class_name Unit
extends CharacterBody2D

@export var battle: Battle
@export var stats: UnitStats : set = set_stats

@onready var skin: Sprite2D = $TestSprite


func _ready() -> void:
	if battle:
		$StateMachine/Pathfinding.battle = battle



func set_stats(value: UnitStats) -> void:
	stats=value
	
	if value == null:
		return
	
	if not is_node_ready():
		await ready
	
	skin.region_rect.position = Vector2(stats.skin_coordinates) * Battle.CELL_SIZE
