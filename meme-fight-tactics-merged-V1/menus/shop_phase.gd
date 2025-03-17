extends Control

# For testing purposes, abilities, buffs, and player data will be loaded from a separate location
var abilities = {
	"Smart Contract Deploy": {
		"texture": preload("res://test_textures/CommonInv_Template.png"),
		"description": "boost attack efficacy by 20%",
		"price": 150,
		"type":"abilities"
	},
	"Mining Boost": {
		"texture": preload("res://test_textures/RareInv_Template.png"),
		"description": "meow",
		"price": 120,
		"type":"abilities"
	},
	"Airdrop Sniper": {
		"texture": preload("res://test_textures/UncommonInv_Template.png"),
		"description": "test lol",
		"price": 180,
		"type":"abilities"
	},
	"Flash Loan Attack": {
		"texture": preload("res://test_textures/UncommonInv_Template.png"),
		"description": "get a special interest rate on something idk",
		"price": 250,
		"type":"abilities"
	}
}

var buffs = {
	"HODL Power": {
		"texture": preload("res://test_textures/UncommonInv_Template.png"),
		"description": "Increase resilience against market dips.",
		"price": 90,
		"type":"buffs"
	},
	"Decentralized Shield": {
		"texture": preload("res://test_textures/UncommonInv_Template.png"),
		"description": "Defend against centralized attacks and hacks.",
		"price": 130,
		"type":"buffs"
	},
	"Whale Detection": {
		"texture": preload("res://test_textures/UncommonInv_Template.png"),
		"description": "Detect whale movements before price surges.",
		"price": 200,
		"type":"buffs"
	},
	"Cold Wallet Security": {
		"texture": preload("res://test_textures/RareInv_Template.png"),
		"description": "Boost protection from hacks and rug pulls.",
		"price": 160,
		"type":"buffs"
	}
}

var player_currency:= 500
var player_inventory = {
	"abilities":[],
	"buffs":[]
}
# ^ for testing purposes ^


@onready var abilities_cont : HBoxContainer = %AbilitiesHBox
@onready var buffs_cont : Node = %BuffsHBox

@onready var shopkeeper_text = $ShopPanel/RightsideVBox/RerollPanel/Panel/ShopKeeperTextBox
@onready var player_curr_text = $ShopPanel/RightsideVBox/RerollPanel/CurrentPlayerCurrency
func _ready():
	randomize()
	populate_shop()
	shopkeeper_text.text = "welcome to the shop"
	player_curr_text.text = str(player_currency)
	
func populate_shop():
	var ability_keys = abilities.keys()
	ability_keys.shuffle()
	var selected_abilities = ability_keys.slice(0, 4)
	
	var buff_keys = buffs.keys()
	buff_keys.shuffle()
	var selected_buffs = buff_keys.slice(0, 4)
	
	for i in range(4):
		var panel = abilities_cont.get_child(i)
		var item_name = selected_abilities[i]
		var item_data = abilities[item_name]
		update_panel(panel, item_name, item_data)
	
	for i in range(4):
		var panel = buffs_cont.get_child(i)
		var item_name = selected_buffs[i]
		var item_data = buffs[item_name]
		update_panel(panel, item_name, item_data)
		
	
func update_panel(panel: Panel, item_name: String, item_data: Dictionary):
	var image_rect = panel.get_node("AbilityImage") as Sprite2D
	image_rect.texture = item_data.texture
	image_rect.set_deferred("scale", Vector2(1.5,1.5)) # adjust this value to fit inside Hbox
	
	var desc_label = panel.get_node("AbilityDesc") as RichTextLabel
	desc_label.clear()
	desc_label.append_text("[b]" + item_name + "[/b]\n" + item_data.description)
	
	var buy_button = panel.get_node("BuyButton") as Button
	buy_button.text = str(item_data.price)
	
	buy_button.set_meta("item_name", item_name)
	buy_button.set_meta("item_data", item_data)
	
	buy_button.pressed.connect(func(): _on_buy_button_pressed(buy_button))


func _on_buy_button_pressed(buy_button: Button) -> void:
	var item_name = buy_button.get_meta("item_name") as String
	var item_data = buy_button.get_meta("item_data") as Dictionary
	var type = item_data.type
	var price = item_data.price
	
	if player_currency >= price:
		player_currency -= price
		#player_inventory.append(item_name)
		if type == "abilities":
			player_inventory.abilities.append(item_name)
		if type == "buffs":
			player_inventory.buffs.append(item_name)
			
		shopkeeper_text.text = "Thank you for buying!"
		player_curr_text.text = str(player_currency)
		
		#for testing 
		print("Purchased ", item_name, " for ", price, " curr, remaining:", player_currency)
		print("inventory: abilities: ", player_inventory.abilities, " buffs: ", player_inventory.buffs)
	
	else:
		print("insufficient funds")
		shopkeeper_text.text = "sorry, you don't have enough coin"

func _on_reroll_button_pressed() -> void:
	if player_currency >= 150: #or whatever we set the reroll price to
		populate_shop()
		player_currency -= 150
		player_curr_text.text = str(player_currency)
	else:
		print("insufficient funds")
		shopkeeper_text.text = "find more coin, then i'll get new stuff"
		return
