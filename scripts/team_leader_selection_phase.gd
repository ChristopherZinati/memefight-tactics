extends Control

@onready var leaders_cont : HBoxContainer = $Panel/PanelContainer/HBoxContainer


func _ready() -> void:
	randomize()
	populate()
	


func populate() -> void:
	for i in range(3):
		var card = leaders_cont.get_child(i)
		var leader = ShopItems.get_random_leader()
		var leader_name = leader.name
		var leader_data = leader.item_data
		update_card(card, leader_name, leader_data)


func update_card(card: TextureButton, item_name: String, item_data: Dictionary) -> void:
	var leader_sprite = card.get_node("Sprite2D") as Sprite2D
	leader_sprite.texture = item_data.texture
	leader_sprite.set_deferred("scale", Vector2(1.5,1.5))
	
	var desc_label = card.get_node("leader_desc") as RichTextLabel
	
	desc_label.bbcode_enabled = true
	desc_label.bbcode_text = "[b]" + item_name + "[/b]\n" + item_data.description# + "\n[b]Special Ability:[/b] " + item_data.special_ability
	
	var add_button = card as TextureButton
	add_button.set_meta("item_name", item_name)
	add_button.set_meta("item_data", item_data)
	
	add_button.pressed.connect(func(): _on_add_button_pressed(add_button))


func _on_add_button_pressed(add_button: TextureButton) -> void:
	#var item_name = add_button.get_meta("item_name") as String
	var item_data = add_button.get_meta("item_data") as Dictionary
	var leader = OwnedUnit.new()
	leader.scene = item_data.scene
	events.team_leader_selected.emit(leader)
	 


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")

	
