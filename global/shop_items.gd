extends Node

var abilities = {
	"1": {
		"texture": preload("res://test_textures/CommonInv_Template.png"),
		"description": "for future development",
		"price": 0,
		"type":"abilities"
	},
	"2": {
		"texture": preload("res://test_textures/CommonInv_Template.png"),
		"description": "for future development",
		"price": 0,
		"type":"abilities"
	},
	"3": {
		"texture": preload("res://test_textures/CommonInv_Template.png"),
		"description": "for future development",
		"price": 0,
		"type":"abilities"
	},
	"4": {
		"texture": preload("res://test_textures/CommonInv_Template.png"),
		"description": "for future development",
		"price": 0,
		"type":"abilities"
	}
}

var buffs = {
	"HEAL UNITS": {
		"texture": preload("res://test_textures/CommonInv_Template.png"),
		"description": "Heal 10 hp",
		"price": 50,
		"type":"buffs",
		"stat": "health",
		"amount": 10
	},
	"Attack Up": {
		"texture": preload("res://test_textures/RareInv_Template.png"),
		"description": "+2 attacks damage.",
		"price": 90,
		"type":"buffs",
		"stat": "attack_damage",
		"amount": 2
	},
		"Giant Shield": {
		"texture": preload("res://test_textures/UncommonInv_Template.png"),
		"description": "+10 Max HP",
		"price": 130,
		"type":"buffs",
		"stat": "max_health",
		"amount": 10
	},
		"Quick Attack": {
		"texture": preload("res://test_textures/UncommonInv_Template.png"),
		"description": "+1% attaack speed",
		"price": 90,
		"type":"buffs",
		"stat": "attack_speed",
		"amount": 0.1
	},
}

var leaders = {
	"testUnit": {
		"scene": preload("res://scenes/drag_testUnit.tscn"),
		"texture": preload("res://art/TestSprite_Idle.png"),
		"description": "PICK ME"
	}
}

var units = {
	"weak dog": {
		"scene": preload("res://scenes/drag_weak_dog.tscn"),
		"texture":preload("res://art/WeakDog-0.png"),
		"description":"a weak type from the dog faction. mostly bark, hardly bites.",
		"price":100,
		"type":"unit"
	}
}


func _ready() -> void:
	randomize()

func get_random_buff() -> Dictionary:
	var buff_keys = buffs.keys()
	buff_keys.shuffle()
	var selected_buff = buff_keys[0]
	return {
		"name":selected_buff,
		"item_data":buffs[selected_buff]
	}
	
func get_random_ability() -> Dictionary:
	var ability_keys = abilities.keys()
	ability_keys.shuffle()
	var selected_ability = ability_keys[0]
	return {
		"name":selected_ability,
		"item_data":abilities[selected_ability]
	}

func get_random_unit() -> Dictionary:
	var unit_keys = units.keys()
	unit_keys.shuffle()
	var selected_unit = unit_keys[0]
	return{
		"name":selected_unit,
		"item_data":units[selected_unit]
	}
	
func get_random_leader() -> Dictionary:
	var leader_keys = leaders.keys()
	leader_keys.shuffle()
	var selected_leader = leader_keys[0]
	return {
		"name": selected_leader,
		"item_data": leaders[selected_leader]
	}
