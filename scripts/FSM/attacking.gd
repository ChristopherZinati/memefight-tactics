class_name AttackState
extends State

@onready var owner_entity = get_parent().get_parent()

var target = null

func enter():
	target = fsm.target
	owner_entity.anim.speed_scale = owner_entity.stats.attack_speed
	face_target()
	owner_entity.anim.play("attack")


func exit():
	target = null


func update(_delta):
	# target is dead find a new one
	if owner_entity.anim.speed_scale != owner_entity.stats.attack_speed:
		owner_entity.anim.speed_scale = owner_entity.stats.attack_speed

	if not is_instance_valid(target) or target.stats.health <= 0:
		#print("Target is invalid or dead, exiting attack state")
		target = null
		state_transition.emit(self, "pathfinding")
		return


func deal_damage():
	if target:
		target.stats.take_damage(owner_entity.stats.attack_damage)
	return


func face_target():
	if target == null:
		return
	if owner_entity.is_in_group("enemies"):
		var direction = owner_entity.global_position.x - target.global_position.x
		owner_entity.skin.flip_h = direction < 0  # Flip sprite
	else:
		var direction = target.global_position.x - owner_entity.global_position.x
		owner_entity.skin.flip_h = direction < 0  # Flip sprite
