extends Control

var units = {
	"Smart Contract Deploy": {
		"texture": preload("res://test_textures/CommonInv_Template.png"),
		"description": "boost attack efficacy by 20%",
		"price": 150,
		"type":"units"
	},
	"Mining Boost": {
		"texture": preload("res://test_textures/RareInv_Template.png"),
		"description": "meow",
		"price": 120,
		"type":"units"
	},
	"Airdrop Sniper": {
		"texture": preload("res://test_textures/UncommonInv_Template.png"),
		"description": "test lol",
		"price": 180,
		"type":"units"
	},
	"Flash Loan Attack": {
		"texture": preload("res://test_textures/UncommonInv_Template.png"),
		"description": "get a special interest rate on something idk",
		"price": 250,
		"type":"units"
	},
	"test1": {
		"texture": preload("res://test_textures/CommonInv_Template.png"),
		"description": "boost attack efficacy by 20%",
		"price": 150,
		"type":"units"
	},
	"test2": {
		"texture": preload("res://test_textures/RareInv_Template.png"),
		"description": "meow",
		"price": 120,
		"type":"units"
	},
	"test3": {
		"texture": preload("res://test_textures/UncommonInv_Template.png"),
		"description": "test lol",
		"price": 180,
		"type":"units"
	},
	"test4": {
		"texture": preload("res://test_textures/UncommonInv_Template.png"),
		"description": "get a special interest rate on something idk",
		"price": 250,
		"type":"units"
	}
}
var player_currency:= 500
var player_inventory = {
	"abilities":[],
	"buffs":[],
	"units":[]
}
# ^ for testing purposes ^

@onready var top_cont: HBoxContainer= %UnitHboxTop
@onready var bottom_cont: HBoxContainer = %UnitHboxBottom

@onready var shopkeeper_text = $RightsideVBox/RerollPanel/Panel/ShopKeeperTextBox
@onready var player_curr_text = $RightsideVBox/RerollPanel/CurrentPlayerCurrency
func _ready():
	randomize()
	populate_shop()
	shopkeeper_text.text = "welcome to the shop"
	player_curr_text.text = str(player_currency)
	
	
func populate_shop():
	var unit_keys = units.keys()
	unit_keys.shuffle()
	var selected_units = unit_keys.slice(0, 8)
	
	for i in range(4):
		var panel = top_cont.get_child(i)
		var item_name = selected_units[i]
		var item_data = units[item_name]
		update_panel(panel, item_name, item_data)
	
	for i in range(4):
		var panel = bottom_cont.get_child(i)
		var item_name = selected_units[i]
		var item_data = units[item_name]
		update_panel(panel, item_name, item_data)
	
func update_panel(panel: Panel, item_name: String, item_data: Dictionary):
	var image_rect = panel.get_node("UnitSprite") as Sprite2D
	image_rect.texture = item_data.texture
	image_rect.set_deferred("scale", Vector2(1.5,1.5)) # adjust this value to fit inside Hbox
	
	var desc_label = panel.get_node("UnitDesc") as RichTextLabel
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
		if type == "units":
			player_inventory.units.append(item_name)
			
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


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://map_assets/Map.tscn")
