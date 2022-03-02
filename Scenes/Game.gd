extends Node2D

var rng = RandomNumberGenerator.new()
var score = 0
var fire_spells = 5
var lightening_spells = 5
var ice_spells = 5

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_F:
			for i in rng.randi_range(2, 5):
				spawn_fireball()
		if event.scancode == KEY_SPACE:
			soft_reset()

func _ready():
	rng.randomize()
	$CanvasLayer/UI/TitleUI.visible = true
	$Player.visible = false
	$DeepgramInstance.initialize("6bcd9cacad1f0a0dc84cbda8e7ac0b3501eedf3b")

func _on_DeepgramInstance_message_received(message):
	var message_json = JSON.parse(message)
	if message_json.error == OK:
		if typeof(message_json.result) == TYPE_DICTIONARY:
			if message_json.result.has("is_final"):
				if message_json.result["is_final"] == true:
					var transcript = message_json.result["channel"]["alternatives"][0]["transcript"]
					print("Transcript received: " + transcript)
					$CanvasLayer/UI.update_transcript(transcript)
					for i in transcript.count("fire"):
						if fire_spells > 0 and $Player.visible:
							for j in rng.randi_range(2, 5):
								spawn_fireball()
							fire_spells -= 1
							$CanvasLayer/UI.update_fire_spells(fire_spells)
							$CanvasLayer/UI.fire_spell_should_blink = true

	else:
		print("Failed to parse Deepgram message!")

func _process(_delta):
	if !$Player.visible && !$CanvasLayer/UI/GameOverUI.visible && !$CanvasLayer/UI/TitleUI.visible:
		$CanvasLayer/UI.showGameOver(score)

	var ghosts = get_tree().get_nodes_in_group("Ghost")
	for ghost in ghosts:
		if $Player.visible:
			ghost.destination = $Player.position
		else:
			ghost.destination = ghost.position

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
	if $Player.visible:
		var ghost = load("res://Scenes/Ghost.tscn").instance()
		add_child(ghost)
	
		var random_angle = rng.randf_range(0.0, 2 * PI)
		var random_distance = rng.randi_range(100, 200)
		var spawn_position = $Player.position + Vector2(cos(random_angle), sin(random_angle)) * random_distance
		ghost.position = spawn_position
		ghost.destination = $Player.position

func _on_ScoreTimer_timeout():
	if $Player.visible:
		score += 1
		$CanvasLayer/UI.update_score(score)
	
		if fire_spells < 5:
			fire_spells += 1
			$CanvasLayer/UI.update_fire_spells(fire_spells)
			if fire_spells == 5:
				$CanvasLayer/UI.fire_spell_should_blink = false

func soft_reset():
	$CanvasLayer/UI/TitleUI.visible = false
	
	var ghosts = get_tree().get_nodes_in_group("Ghost")
	for ghost in ghosts:
		ghost.destroy()

	score = 0
	fire_spells = 5
	lightening_spells = 5
	ice_spells = 5
	
	$CanvasLayer/UI.update_score(score)
	$CanvasLayer/UI.update_fire_spells(fire_spells)
	$CanvasLayer/UI.fire_spell_should_blink = false

	$CanvasLayer/UI.hideGameOver()
	$Player.visible = true
