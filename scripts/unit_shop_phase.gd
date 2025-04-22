extends Control

@onready var top_cont: HBoxContainer= %UnitHboxTop
@onready var bottom_cont: HBoxContainer = %UnitHboxBottom

@onready var shopkeeper_text = $RightsideVBox/RerollPanel/Panel/ShopKeeperTextBox
@onready var player_curr_text = $RightsideVBox/RerollPanel/CurrentPlayerCurrency
@onready var shopkeeper : AnimatedSprite2D = $RightsideVBox/ShopkeeperSprite

@export var player_stats: PlayerStats = PlayerStats.new() #should get overidden by the injected playerstats instance from run.gd
var player_currency: int

func _ready():
	randomize()
	populate_shop()
	shopkeeper.play("default")
	shopkeeper_text.text = "welcome to the shop"
	player_currency = player_stats.gold
	player_curr_text.text = str(player_currency)
	
func populate_shop():
	for i in range(4):
		var panel = top_cont.get_child(i)
		var item = ShopItems.get_random_unit()
		var item_name = item.name
		var item_data = item.item_data
		update_panel(panel, item_name, item_data)
	
	for i in range(4):
		var panel = bottom_cont.get_child(i)
		var item = ShopItems.get_random_unit()
		var item_name = item.name
		var item_data = item.item_data
		update_panel(panel, item_name, item_data)
	
func update_panel(panel: Panel, item_name: String, item_data: Dictionary):
	var image_rect = panel.get_node("UnitSprite") as Sprite2D
	image_rect.texture = item_data.texture
	image_rect.set_deferred("scale", Vector2(1,1)) # adjust this value to fit inside Hbox
	
	var desc_label = panel.get_node("UnitDesc") as RichTextLabel
	desc_label.clear()
	desc_label.append_text("[b]" + item_name + "[/b]\n" + item_data.description)
	
	var buy_button = panel.get_node("BuyButton") as Button
	buy_button.text = str(item_data.price)
	
	buy_button.set_meta("item_name", item_name)
	buy_button.set_meta("item_data", item_data)
	
	buy_button.pressed.connect(func(): _on_buy_button_pressed(buy_button))


func _on_buy_button_pressed(buy_button: Button) -> void:
	#var item_name = buy_button.get_meta("item_name") as String
	var item_data = buy_button.get_meta("item_data") as Dictionary
	var type = item_data.type
	var price = item_data.price
	
	if player_currency >= price:
		player_currency -= price
		player_stats.lose_gold(price)
		#player_inventory.append(item_name)
		if type == "unit":
			var new_unit = OwnedUnit.new()
			
			new_unit.scene = item_data.scene
			print(item_data.scene)
			player_stats.add_unit(new_unit)
			
			player_curr_text.text = str(player_currency)
			shopkeeper_text.text = "A fine purchase."
	else:
		print("insufficient funds")
		shopkeeper_text.text = "sorry, you don't have enough coin"

func _on_reroll_button_pressed() -> void:
	if player_currency >= 2: #or whatever we set the reroll price to
		populate_shop()
		player_currency -= 2
		player_curr_text.text = str(player_currency)
	else:
		print("insufficient funds")
		shopkeeper_text.text = "find more coin, then i'll get new stuff"
		return


func _on_exit_button_pressed() -> void:
	events.exit_shop.emit()
	queue_free()
	#get_tree().change_scene_to_file("res://map_assets/Map.tscn")
