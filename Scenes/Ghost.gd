extends Area2D

export var speed = 10
var destination = Vector2(320, 240)

func _physics_process(delta):
	var velocity = (destination - position).normalized() * speed
	position += velocity * delta

	if velocity.x < 0 and scale.x > 0:
		scale.x *= -1
	elif velocity.x > 0 and scale.x < 0:
		scale.x *= -1

func destroy():
	get_tree().queue_delete(self)
