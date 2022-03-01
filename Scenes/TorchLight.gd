extends Area2D

var lit = false

func _ready():
	$AnimatedSprite.set_animation("unlit")

func light():
	if lit == false:
		lit = true
		$AnimatedSprite.set_animation("lit")
		$Timer.start()

func extinguish():
	lit = false
	$AnimatedSprite.set_animation("unlit")

func _on_Timer_timeout():
	extinguish()
