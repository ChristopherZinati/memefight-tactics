class_name Enemy
extends CharacterBody2D

signal die

@export var stats: EnemyStats : set = set_stats
@export var battle: Battle
@export var anim: AnimationPlayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var energy_bar: ProgressBar = $EnergyBar
@onready var skin: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	stats.stats_changed.connect(_on_stats_changed)
	health_bar.max_value = stats.max_health
	energy_bar.max_value = stats.max_energy
	if battle:
		$StateMachine.battle = battle
		$StateMachine/Pathfinding.battle = battle



func set_stats(value: EnemyStats) -> void:
	stats=value.create_instance()
	
	if value == null:
		return
	
	if not is_node_ready():
		await ready
	
	#skin.region_rect.position = Vector2(stats.skin_coordinates) * Battle.CELL_SIZE


func _on_stats_changed(stat_name: String):
	match stat_name:
		"health":
			if stats.health == 0:
				die.emit()
			else:
				health_bar.value = stats.health
		"energy":
			energy_bar.value = stats.energy
