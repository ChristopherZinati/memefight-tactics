extends Control

signal exit_to_main_menu
signal exit_to_map
signal resume

func _on_resume_pressed() -> void:
	emit_signal("resume")


func _on_return_to_map_pressed() -> void:
	emit_signal("exit_to_map")


func _on_exit_to_menu_pressed() -> void:
	emit_signal("exit_to_main_menu")
