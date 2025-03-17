class_name AttackState
extends State

func enter():
	print(get_parent().get_parent(),"starting to attack")
	pass

func exit():
	print("stopped attacking")
	pass

func update(delta):
	#print(get_parent().get_parent(), "attacking")
	pass
