extends Node

func _ready() -> void:
	events.leader_selection_exited.connect(_on_leader_selection_exited)
	
func _on_leader_selection_exited():
	get_child(0).queue_free()
	events.has_no_view.emit()
