class_name Enemy
extends CharacterBody2D

@export var stats: EnemyStats : set = set_stats
@export var battle: Battle
@onready var skin: Sprite2D = $TestSprite
#@onready var health_bar: ProgressBar= $HealthBar


func _ready() -> void:
	if battle:
		$StateMachine/Pathfinding.battle = battle



func set_stats(value: EnemyStats) -> void:
	stats=value
	
	if value == null:
		return
	
	if not is_node_ready():
		await ready
	
	skin.region_rect.position = Vector2(stats.skin_coordinates) * Battle.CELL_SIZE
