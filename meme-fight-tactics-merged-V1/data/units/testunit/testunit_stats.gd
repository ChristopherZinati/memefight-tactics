class_name UnitStats
extends Resource

enum Rarity {COMMON, RARE, LEGENDARY}

@export var name: String
@export_category("ShopData")
@export var rarity: Rarity
@export var gold_cost:= 1

@export_category("Visuals")
@export var skin_coordinates: Vector2i

@export_category("Stats")
@export var max_health := 1
@export var max_energy := 1
@export var max_atk_speed := 1.5
#@export var ability: Ability = null

signal stats_changed
var health: int : set = set_health
var energy: int : set = set_energy


func set_health(value: int) -> void:
	health = clampi(value,0, max_health)
	stats_changed.emit()
	


func set_energy(value: int) -> void:
	energy = clampi(value, 0, max_energy)
	stats_changed.emit()


func take_damage(damage: int) -> void:
	self.health -= damage


func heal(amount: int) -> void:
	self.health += amount


func create_instance() -> Resource:
	var instance: UnitStats = self.duplicate()
	instance.health = max_health
	instance.energy = max_energy
	instance.atk_speed = max_atk_speed
	return instance
