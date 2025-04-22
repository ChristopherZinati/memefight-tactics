class_name DraggableUnit
extends Area2D


@onready var skin: Sprite2D = $TestSprite
@onready var health_bar: ProgressBar= $HealthBar
@onready var energy_bar: ProgressBar= $EnergyBar
@onready var drag_and_drop: DragAndDrop = $DragAndDrop
@onready var rag_doll_drag: RagDollDrag = $RagDollDrag

#assign upon acquiring unit
@export var unit_id: int

var unique_id: int

func _ready() -> void:
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
	
