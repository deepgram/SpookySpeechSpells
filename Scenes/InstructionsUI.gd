extends Control

signal pressed_back

var rng = RandomNumberGenerator.new()

func destroy():
	get_tree().queue_delete(self)

func _ready():
	rng.randomize()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_B:
			$MarginContainer/CenterContainer/VBoxContainer/CenterContainer/ButtonBack.emit_signal("pressed")

func _on_ButtonBack_pressed():
	emit_signal("pressed_back")
	destroy()

func _on_Timer_timeout():
	cast_spell()
	spawn_ghost()

func cast_spell():
	var spell_type = rng.randi_range(0, 2)
	for i in rng.randi_range(3, 5):
		var spell
		if spell_type == 0:
			spell = load("res://Scenes/Fireball.tscn").instance()
		elif spell_type == 1:
			spell = load("res://Scenes/Icicle.tscn").instance()
		elif spell_type == 2:
			spell = load("res://Scenes/Lightningball.tscn").instance()
		add_child(spell)
	
		var random_angle = rng.randf_range(0.0, 2 * PI)
		spell.direction = Vector2(cos(random_angle), sin(random_angle))
		spell.rotation = spell.direction.angle()
		spell.position = $Sprite.position
		spell.speed = spell.speed / 2.0
		spell.get_node("Timer").start(0.5)

# TODO:
# these ghosts won't behave correctly since the parent
# node (Game.tscn) will control logic surrounding all ghosts
# the solution here is to factor out which elements are common
# to Game.tscn and the UI scenes (map + HUD) - this will have
# the side-effect that the GameOverUI wouldn't include the final
# state of the game in the background, unless I organize scenes
# a bit differently
func spawn_ghost():	
	var ghost = load("res://Scenes/Ghost.tscn").instance()
	add_child(ghost)
	
	var random_angle = rng.randf_range(0.0, 2 * PI)
	var random_distance = rng.randi_range(40, 75)
	var spawn_position = $Sprite.position + Vector2(cos(random_angle), sin(random_angle)) * random_distance
	ghost.position = spawn_position
	ghost.destination = spawn_position
