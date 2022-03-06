extends Area2D

export var speed = 220
var direction = Vector2(0, 0)

func _physics_process(delta):
	var velocity = direction.normalized() * speed
	
	rotation = velocity.angle()
	position += velocity * delta

func destroy():
	get_tree().queue_delete(self)

func _on_Icicle_area_entered(area):
	if area.is_in_group("Ghost"):
		area.destroy()
		destroy()
		
func _on_Timer_timeout():
	destroy()
