extends KinematicBody2D

export var speed = 200
var velocity = Vector2(0, 0)

func _physics_process(_delta):
	if Input.is_key_pressed(KEY_W):
		velocity.y = -speed
	elif Input.is_key_pressed(KEY_S):
		velocity.y = speed
	else:
		velocity.y = 0

	if Input.is_key_pressed(KEY_A):
		velocity.x = - speed
	elif Input.is_key_pressed(KEY_D):
		velocity.x = speed
	else:
		velocity.x = 0

	var _returned_velocity = move_and_slide(velocity, Vector2(0, 0), false, 4, 0, false)

func destroy():
	get_tree().queue_delete(self)
