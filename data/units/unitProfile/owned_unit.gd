class_name OwnedUnit
extends Resource

var scene: PackedScene
var stats: UnitStats

func apply_buff(buff: Buff):
	var stat_value = stats.get(buff.stat)
	if stat_value:
		stats.set(buff.stat, stat_value + buff.amount)
	else:
		print("Error: Stat not found")
