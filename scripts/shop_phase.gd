extends Control

@onready var abilities_cont : HBoxContainer = %AbilitiesHBox
@onready var buffs_cont : Node = %BuffsHBox

@onready var shopkeeper_text = $ShopPanel/RightsideVBox/RerollPanel/Panel/ShopKeeperTextBox
@onready var player_curr_text = $ShopPanel/RightsideVBox/RerollPanel/CurrentPlayerCurrency
@onready var shopkeeper : AnimatedSprite2D = $ShopPanel/RightsideVBox/ShopkeeperSprite

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
		var panel = abilities_cont.get_child(i)
		var item = ShopItems.get_random_ability()
		var item_name = item.name
		var item_data = item.item_data
		update_panel(panel, item_name, item_data)
	
	for i in range(4):
		var panel = buffs_cont.get_child(i)
		var item = ShopItems.get_random_buff()
		var item_name = item.name
		var item_data = item.item_data
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
		player_stats.lose_gold(price)
		if type == "abilities":
			return
		if type == "buffs":
			var new_buff = Buff.new()
			
			new_buff.name = item_name
			new_buff.description = item_data.description
			new_buff.stat = item_data.stat
			new_buff.amount = item_data.amount
			
			for key in player_stats.units:
				player_stats.units[key].apply_buff(new_buff)
			
		if type == "units":
			return
			#player_stats.add_unit()
			
		shopkeeper_text.text = "Thank you for buying!"
		player_curr_text.text = str(player_currency)
		
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
	events.exit_shop.emit()
	queue_free()


func _on_buy_xp_button_pressed() -> void:
	if player_currency >= 4:
		events.xp_purchased.emit(4)
	else:
		shopkeeper_text.text = "sorry, you don't have enough coin"
