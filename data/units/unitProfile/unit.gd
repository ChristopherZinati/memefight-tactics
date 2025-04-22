class_name Unit
extends CharacterBody2D

signal die

#assigned upon acquiring a unit
@export var unit_id: int

@export var battle: Battle
@export var stats: UnitStats #: set = set_stats
@export var anim: AnimationPlayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var energy_bar: ProgressBar = $EnergyBar
@onready var skin: AnimatedSprite2D = $AnimatedSprite2D
var unique_id: int

func _ready() -> void:
	stats.stats_changed.connect(_on_stats_changed)
	health_bar.max_value = stats.max_health
	health_bar.value = stats.health
	energy_bar.max_value = stats.max_energy
	
	if battle:
		$StateMachine.battle = battle
		$StateMachine/Pathfinding.battle = battle
	print("battle start stats:\n", "health: ", self.stats.health)



func set_stats(value: UnitStats) -> void:
	#stats=value.create_instance()
	stats=value
	if value == null:
		return
	if not is_node_ready():
		await ready
	
	#skin.region_rect.position = Vector2(stats.skin_coordinates) * Battle.CELL_SIZE


func _on_stats_changed(stat_name: String):
	match stat_name:
		"health":
			health_bar.value = stats.health
			if stats.health == 0:
				die.emit()
		"energy":
			energy_bar.value = stats.energy
