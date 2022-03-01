extends Node2D

var rng = RandomNumberGenerator.new()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_F:
			for i in rng.randi_range(2, 5):
				spawn_fireball()

func _ready():
	rng.randomize()

func _process(delta):
	var ghosts = get_tree().get_nodes_in_group("Ghost")
	for ghost in ghosts:
		ghost.destination = $Player.position

	if $Torch1/TorchLight.lit and $Torch2/TorchLight.lit and $Torch3/TorchLight.lit and $Torch4/TorchLight.lit:
		for ghost in ghosts:
			ghost.destroy()
		$Torch1/TorchLight.extinguish()
		$Torch2/TorchLight.extinguish()
		$Torch3/TorchLight.extinguish()
		$Torch4/TorchLight.extinguish()

func spawn_fireball():
	var fireball = load("res://Scenes/Fireball.tscn").instance()
	add_child(fireball)
	
	var random_angle = rng.randf_range(0.0, 2 * PI)
	fireball.direction = Vector2(cos(random_angle), sin(random_angle))
	fireball.rotation = fireball.direction.angle()
	fireball.position = $Player.position


func _on_GhostSpawnTimer_timeout():
	var ghost = load("res://Scenes/Ghost.tscn").instance()
	add_child(ghost)
	
	var random_angle = rng.randf_range(0.0, 2 * PI)
	var random_distance = rng.randi_range(100, 200)
	var spawn_position = $Player.position + Vector2(cos(random_angle), sin(random_angle)) * random_distance
	ghost.position = spawn_position
	ghost.destination = $Player.position

