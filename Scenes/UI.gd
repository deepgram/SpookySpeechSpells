extends Control

var fire_spell_should_blink = false

func update_score(score):
	$TopRowUI/HBoxContainer/Score.text = "SCORE: " + str(score)

func update_transcript(transcript):
	if transcript.length() > 0:
		$BottomUI/HBoxContainer/Transcript.text += " " + transcript
		if $BottomUI/HBoxContainer/Transcript.get_line_count() > 1:
			$BottomUI/HBoxContainer/Transcript.text = "TRANSCRIPT: " + transcript

func update_fire_spells(count):
	$TopRowUI/HBoxContainer/FireSpell.text[5] = str(count)

func _on_SpellBlinkTimer_timeout():
	if fire_spell_should_blink:
		if $TopRowUI/HBoxContainer/FireSpell.modulate.a == 0:
			$TopRowUI/HBoxContainer/FireSpell.modulate.a = 255
		else:
			$TopRowUI/HBoxContainer/FireSpell.modulate.a = 0
	else:
		$TopRowUI/HBoxContainer/FireSpell.modulate.a = 255

func showGameOver(final_score):
	$GameOverUI/MarginContainer/CenterContainer/VBoxContainer/YourScore.text = "YOUR SCORE: " + str(final_score)
	$GameOverUI.visible = true

func hideGameOver():
	$GameOverUI.visible = false
