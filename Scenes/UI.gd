extends Control

signal pressed_play
signal pressed_retry
signal pressed_main_menu

var fire_spell_should_blink = false
var lightning_spell_should_blink = false
var ice_spell_should_blink = false

func update_score(score):
	$TopRowUI/HBoxContainer/Score.text = "SCORE: " + str(score)

func update_transcript(transcript):
	if transcript.length() > 0:
		$BottomUI/HBoxContainer/Transcript.text += " " + transcript
		if $BottomUI/HBoxContainer/Transcript.get_line_count() > 1:
			$BottomUI/HBoxContainer/Transcript.text = "TRANSCRIPT: " + transcript

func update_fire_spells(count):
	$TopRowUI/HBoxContainer/FireSpell.text[5] = str(count)

func update_lightning_spells(count):
	$TopRowUI/HBoxContainer/LightningSpell.text[10] = str(count)

func update_ice_spells(count):
	$TopRowUI/HBoxContainer/IceSpell.text[4] = str(count)

func _on_SpellBlinkTimer_timeout():
	if fire_spell_should_blink:
		if $TopRowUI/HBoxContainer/FireSpell.modulate.a == 0:
			$TopRowUI/HBoxContainer/FireSpell.modulate.a = 255
		else:
			$TopRowUI/HBoxContainer/FireSpell.modulate.a = 0
	else:
		$TopRowUI/HBoxContainer/FireSpell.modulate.a = 255

	if lightning_spell_should_blink:
		if $TopRowUI/HBoxContainer/LightningSpell.modulate.a == 0:
			$TopRowUI/HBoxContainer/LightningSpell.modulate.a = 255
		else:
			$TopRowUI/HBoxContainer/LightningSpell.modulate.a = 0
	else:
		$TopRowUI/HBoxContainer/LightningSpell.modulate.a = 255

	if ice_spell_should_blink:
		if $TopRowUI/HBoxContainer/IceSpell.modulate.a == 0:
			$TopRowUI/HBoxContainer/IceSpell.modulate.a = 255
		else:
			$TopRowUI/HBoxContainer/IceSpell.modulate.a = 0
	else:
		$TopRowUI/HBoxContainer/IceSpell.modulate.a = 255

func showGameOver(final_score):
	$GameOverUI/MarginContainer/CenterContainer/VBoxContainer/YourScore.text = "\n" + "YOUR SCORE: " + str(final_score) + "\n"
	$GameOverUI.visible = true

func hideGameOver():
	$GameOverUI.visible = false

func _on_ButtonPlay_pressed():
	emit_signal("pressed_play")

func _on_ButtonRetry_pressed():
	emit_signal("pressed_retry")

func _on_ButtonMainMenu_pressed():
	emit_signal("pressed_main_menu")
