class_name Unit
extends Area2D

@export var stats: UnitStats : set = set_stats

@onready var skin: Sprite2D = $TestSprite
@onready var health_bar: ProgressBar= $HealthBar
@onready var energy_bar: ProgressBar= $EnergyBar
@onready var drag_and_drop: DragAndDrop = $DragAndDrop
@onready var rag_doll_drag: RagDollDrag = $RagDollDrag

#work on stats and maybe use another collisionshape to detect range 
#then maybe use that range for the pathfinder
func _ready() -> void:
	if not Engine.is_editor_hint():
		drag_and_drop.drag_started.connect(_on_drag_started)
		drag_and_drop.drag_canceled.connect(_on_drag_canceled)



func set_stats(value: UnitStats) -> void:
	stats=value
	
	if value == null:
		return
	
	if not is_node_ready():
		await ready
	
	skin.region_rect.position = Vector2(stats.skin_coordinates) * Battle.CELL_SIZE

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
	
