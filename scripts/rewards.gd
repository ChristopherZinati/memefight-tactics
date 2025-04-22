class_name BattleReward
extends Control

const REWARD_BUTTON = preload("res://scenes/reward_button.tscn")
const gold_icon = preload("res://test_textures/HoundPiece_Icon.png")
const gold_text := "%s gold"


#@export var player_stats: PlayerStats

@onready var rewards: VBoxContainer = %Rewards
var gold_amount: int = 0
var battle_won: bool = false

func _ready() -> void:
	for node: Node in rewards.get_children():
		node.queue_free()
	
	# JUST FOR TESTING
	#player_stats.PlayerStats.new()
	#player_stats.gold_changed.connect(func(): print("gold: %s " % player_stats.gold))
	
	add_gold_reward(gold_amount)

func add_gold_reward(amount: int):
	var gold_reward = REWARD_BUTTON.instantiate() as RewardButton
	
	gold_reward.reward_icon = gold_icon
	gold_reward.reward_text = gold_text % amount
	gold_reward.pressed.connect(_on_reward_taken.bind(amount))
	rewards.add_child.call_deferred(gold_reward)


func _on_reward_taken(_amount: int):
	#player_stats.gold += amount
	
	get_node("/root/Run").player.gold += _amount



func _on_continue_button_pressed() -> void:
	get_parent().queue_free()
	events.continue_button_pressed.emit()
