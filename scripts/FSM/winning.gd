class_name Winning
extends State

@onready var owner_entity = get_parent().get_parent()

func enter():
	owner_entity.anim.speed_scale = 0.7
	owner_entity.anim.play("win")

func exit():
	pass


func update(_delta:float):
	pass
	

func flip():
	owner_entity.skin.flip_h = !owner_entity.skin.flip_h
