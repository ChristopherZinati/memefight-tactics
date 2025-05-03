extends Node2D

@export var player_stats: PlayerStats = PlayerStats.new()
@onready var level_text = $PlayerStatsOverlay/TeamLeader/LevelText
@onready var xp_text = $PlayerStatsOverlay/TeamLeader/XpText
@onready var curr_text = $PlayerStatsOverlay/HoundCoinSprite/CurrencyText


func _ready() -> void:
	level_text.text = "level: " + str(player_stats.current_level)
	xp_text.text = "xp: " + str(player_stats.experience)
	curr_text.text = str(player_stats.gold)
	_refresh_stats()


func _refresh_stats():
		level_text.text = "level: " + str(player_stats.current_level)
		xp_text.text = "xp: " + str(player_stats.experience)
		curr_text.text = str(player_stats.gold)
		await get_tree().create_timer(1).timeout
		_refresh_stats()
