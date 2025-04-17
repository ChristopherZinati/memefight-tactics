extends Control


#for testing purposes
var team_leaders = {
	"Diamond Hands": {
		"texture": preload("res://art/doge-(blurry).png"),
		"description": "Never sells, even in a crash. Unshakable conviction.",
		"special_ability": "Market Resilience - Immune to panic sell effects.",
		"type": "leader"
	},
	"Paper Hands": {
		"texture": preload("res://art/doge-(blurry).png"),
		"description": "Folds at the first sign of a dip. Nervous but quick to exit.",
		"special_ability": "Exit Strategy - Gains bonus funds when selling at a small loss.",
		"type": "leader"
	},
	"Elon Pumper": {
		"texture": preload("res://art/TestSprite.png"),
		"description": "One tweet can send prices soaring or crashing.",
		"special_ability": "Musk Effect - Randomly pumps or dumps an asset.",
		"type": "leader"
	},
	"Roaring Kitty": {
		"texture": preload("res://art/doge-(blurry).png"),
		"description": "Deep research, high conviction. The face of meme stock movements.",
		"special_ability": "HODL Mentality - Gains power the longer an asset is held.",
		"type": "leader"
	},
	"The Whale": {
		"texture": preload("res://art/doge-(blurry).png"),
		"description": "Moves markets with massive buys and sells.",
		"special_ability": "Liquidity Shock - Can force a market crash or rally.",
		"type": "leader"
	},
	"Rug Pull Dev": {
		"texture": preload("res://art/doge-(blurry).png"),
		"description": "Promises the moon, then vanishes overnight.",
		"special_ability": "Exit Scam - Steals funds from opponents when used correctly.",
		"type": "leader"
	},
	"HODLer": {
		"texture": preload("res://art/doge-(blurry).png"),
		"description": "Buys and never sells, no matter what.",
		"special_ability": "Diamond Fortitude - Buffs team defense against market swings.",
		"type": "leader"
	},
	"FOMO Trader": {
		"texture": preload("res://art/doge-(blurry).png"),
		"description": "Buys high, sells low. Always chasing the next big thing.",
		"special_ability": "Impulse Buy - Gains a random asset every turn.",
		"type": "leader"
	},
	"The Fed": {
		"texture": preload("res://art/doge-(blurry).png"),
		"description": "Prints money endlessly, manipulating the market.",
		"special_ability": "Infinite QE - Can artificially inflate asset prices.",
		"type": "leader"
	}
}
var player_inventory = {
	"abilities":[],
	"buffs":[],
	"units":[],
	"leader":[]
}
@onready var leaders_cont : HBoxContainer = $Panel/PanelContainer/HBoxContainer


func _ready() -> void:
	randomize()
	populate()
	


func populate() -> void:
	var leader_keys = team_leaders.keys()
	leader_keys.shuffle()
	var selected_leaders = leader_keys.slice(0, 3)
	
	for i in range(3):
		var card = leaders_cont.get_child(i)
		var item_name = selected_leaders[i]
		var item_data = team_leaders[item_name]
		update_card(card, item_name, item_data)


func update_card(card: TextureButton, item_name: String, item_data: Dictionary) -> void:
	var leader_sprite = card.get_node("Sprite2D") as Sprite2D
	leader_sprite.texture = item_data.texture
	leader_sprite.set_deferred("scale", Vector2(1.5,1.5))
	
	var desc_label = card.get_node("leader_desc") as RichTextLabel
	
	desc_label.bbcode_enabled = true
	desc_label.bbcode_text = "[b]" + item_name + "[/b]\n" + item_data.description + "\n[b]Special Ability:[/b] " + item_data.special_ability
	
	var add_button = card as TextureButton
	add_button.set_meta("item_name", item_name)
	add_button.set_meta("item_data", item_data)
	
	add_button.pressed.connect(func(): _on_add_button_pressed(add_button))


func _on_add_button_pressed(add_button: TextureButton) -> void:
	var item_name = add_button.get_meta("item_name") as String
	var item_data = add_button.get_meta("item_data") as Dictionary
	player_inventory.leader.append(item_name)
	
	#print(player_inventory)
	 


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")

func _on_team_leader_pressed() -> void:
	var leader_scene = preload("res://scenes/drag_testUnit.tscn")
	#var leader = leader_scene.instantiate()
	events.team_leader_selected.emit(leader_scene)
	
