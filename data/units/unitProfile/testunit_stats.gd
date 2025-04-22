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
@export var max_health: int
@export var max_energy: int
@export var attack_speed: float
@export var attack_damage: int
@export var block: int
#@export var ability: Ability = null

signal stats_changed
var health: int : set = set_health
var energy: int : set = set_energy

func set_health(value: int) -> void:
	health = clampi(value,0, max_health)
	stats_changed.emit("health")
	


func set_energy(value: int) -> void:
	energy = clampi(value, 0, max_energy)
	stats_changed.emit("energy")


func take_damage(damage: int) -> void:
	set_health(health - damage)


func heal(amount: int) -> void:
	set_health(health + amount)


func set_attack_speed(value: float):
	attack_speed += value


func create_instance() -> Resource:
	var instance: UnitStats = self.duplicate(true)
	instance.health = max_health
	instance.energy = max_energy
	instance.attack_speed = attack_speed
	instance.attack_damage = attack_damage
	return instance
