class_name EnemySpawner
extends Node


var min_enemies: int = 1
var max_enemies: int = 6

@export var battle: Battle
@export var game_area: PlayArea
@export var battle_grid: UnitGrid
@export var enemy_scenes: Array[PackedScene]

func _ready():
	spawn_enemies()


func spawn_enemies() -> void:
	var area := game_area
	
	var enemy_count = randi_range(min_enemies, max_enemies)
	
	for i in range(enemy_count):
		var enemy_scene = enemy_scenes.pick_random()
		var new_enemy = enemy_scene.instantiate()
		new_enemy.add_to_group("enemies")
		new_enemy.name = "Enemy" +str(i+1)
		new_enemy.battle = battle
		var tile := area.unit_grid.get_first_empty_enemy_tile()
		area.unit_grid.add_child(new_enemy)
		#area.unit_grid.add_enemy(tile, new_enemy)
		area.unit_grid.add_entity(tile, new_enemy)
		new_enemy.global_position = area.get_global_from_tile(tile) - Battle.HALF_CELL_SIZE
