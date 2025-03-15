class_name Draggable
extends Area2D
@onready var drag_and_drop: DragAndDrop = $DragAndDrop
@onready var rag_doll_drag: RagDollDrag = $RagDollDrag

#work on stats and maybe use another collisionshape to detect range 
#then maybe use that range for the pathfinder
func _ready() -> void:
	add_to_group("draggable")
	if not Engine.is_editor_hint():
		drag_and_drop.drag_started.connect(_on_drag_started)
		drag_and_drop.drag_canceled.connect(_on_drag_canceled)

func reset_after_dragging(starting_position: Vector2) -> void:
	rag_doll_drag.enabled = false
	global_position = starting_position


func _on_drag_started() -> void:
	rag_doll_drag.enabled = true


func _on_drag_canceled(starting_position: Vector2) -> void:
	reset_after_dragging(starting_position)


func _on_mouse_entered() -> void:
	if drag_and_drop.dragging:
		return

func _on_mouse_exited() -> void:
	if drag_and_drop.dragging:
		return
