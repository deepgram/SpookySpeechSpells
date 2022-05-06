extends Node2D

var rng = RandomNumberGenerator.new()
var score = 0
var fire_spells = 5
var lightning_spells = 5
var ice_spells = 5

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_F:
			for i in rng.randi_range(4, 8):
				spawn_fireball()
		if event.scancode == KEY_L:
			for i in rng.randi_range(2, 5):
				spawn_lightningball()
		if event.scancode == KEY_I:
			for i in rng.randi_range(2, 5):
				spawn_icicle()

func _ready():
	rng.randomize()
	$CanvasLayer/UI/TitleUI.visible = true
	$Player.visible = false
	$DeepgramInstance.initialize("INSERT_YOUR_API_KEY")

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
							for j in rng.randi_range(4, 8):
								spawn_fireball()
							fire_spells -= 1
							$CanvasLayer/UI.update_fire_spells(fire_spells)
							$CanvasLayer/UI.fire_spell_should_blink = true
					for i in transcript.count("lightning"):
						if lightning_spells > 0 and $Player.visible:
							for j in rng.randi_range(2, 5):
								spawn_lightningball()
							lightning_spells -= 1
							$CanvasLayer/UI.update_lightning_spells(lightning_spells)
							$CanvasLayer/UI.lightning_spell_should_blink = true
					for i in transcript.count("ice"):
						if ice_spells > 0 and $Player.visible:
							for j in rng.randi_range(2, 5):
								spawn_icicle()
							ice_spells -= 1
							$CanvasLayer/UI.update_ice_spells(ice_spells)
							$CanvasLayer/UI.ice_spell_should_blink = true
													
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

func spawn_lightningball():
	var lightningball = load("res://Scenes/Lightningball.tscn").instance()
	add_child(lightningball)
	
	var random_angle = rng.randf_range(PI / 4.0, 3.0 * PI / 4.0)
	if rng.randf() > 0.5:
		random_angle = rng.randf_range(5.0 * PI / 4.0, 7.0 * PI / 4.0)
	lightningball.direction = Vector2(cos(random_angle), sin(random_angle))
	lightningball.rotation = lightningball.direction.angle()
	lightningball.position = $Player.position

func spawn_icicle():
	var icicle = load("res://Scenes/Icicle.tscn").instance()
	add_child(icicle)
	
	var random_angle = rng.randf_range(- PI / 4.0, PI / 4.0)
	if rng.randf() > 0.5:
		random_angle = rng.randf_range(3.0 * PI / 4.0, 5.0 * PI / 4.0)
	icicle.direction = Vector2(cos(random_angle), sin(random_angle))
	icicle.rotation = icicle.direction.angle()
	icicle.position = $Player.position
	
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

		if lightning_spells < 5:
			lightning_spells += 1
			$CanvasLayer/UI.update_lightning_spells(lightning_spells)
			if lightning_spells == 5:
				$CanvasLayer/UI.lightning_spell_should_blink = false

		if ice_spells < 5:
			ice_spells += 1
			$CanvasLayer/UI.update_ice_spells(ice_spells)
			if ice_spells == 5:
				$CanvasLayer/UI.ice_spell_should_blink = false

func soft_reset():
	$CanvasLayer/UI/TitleUI.visible = false
	common_reset()
	$Player.visible = true

func hard_reset():
	$CanvasLayer/UI/TitleUI.visible = true
	common_reset()
	$Player.visible = false

func common_reset():
	var ghosts = get_tree().get_nodes_in_group("Ghost")
	for ghost in ghosts:
		ghost.destroy()

	score = 0
	fire_spells = 5
	lightning_spells = 5
	ice_spells = 5
	
	$CanvasLayer/UI.update_score(score)
	
	$CanvasLayer/UI.update_fire_spells(fire_spells)
	$CanvasLayer/UI.fire_spell_should_blink = false
	$CanvasLayer/UI.update_lightning_spells(lightning_spells)
	$CanvasLayer/UI.lightning_spell_should_blink = false
	$CanvasLayer/UI.update_ice_spells(ice_spells)
	$CanvasLayer/UI.ice_spell_should_blink = false
	
	$CanvasLayer/UI.hideGameOver()

func _on_UI_pressed_play():
	soft_reset()

func _on_UI_pressed_main_menu():
	hard_reset()

func _on_UI_pressed_retry():
	soft_reset()
