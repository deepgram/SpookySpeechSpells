extends Control

signal pressed_retry
signal pressed_main_menu

func destroy():
	get_tree().queue_delete(self)

func set_score(score):
	$MarginContainer/CenterContainer/VBoxContainer/YourScore.text = "YOUR SCORE: " + str(score)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_R:
			$MarginContainer/CenterContainer/VBoxContainer/CenterRetry/ButtonRetry.emit_signal("pressed")
		if event.scancode == KEY_M:
			$MarginContainer/CenterContainer/VBoxContainer/CenterMainMenu/ButtonMainMenu.emit_signal("pressed")

func _on_ButtonRetry_pressed():
	emit_signal("pressed_retry")
	destroy()

func _on_ButtonMainMenu_pressed():
	emit_signal("pressed_main_menu")
	destroy()
