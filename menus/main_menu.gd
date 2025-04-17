extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass 


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/run.tscn") #to path of team leader selection screen

func _on_resume_game_pressed() -> void:
	pass # get_tree().change_scene_to_file(path) or however we decide to handle saved games

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/game_options.tscn")
	
func _on_exit_to_desktop_pressed() -> void:
	get_tree().quit()
