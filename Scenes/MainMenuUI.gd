extends Control

signal pressed_play
signal pressed_controls
signal pressed_instructions

func destroy():
	get_tree().queue_delete(self)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_P:
			$MarginContainer/CenterContainer/VBoxContainer/CenterPlay/ButtonPlay.emit_signal("pressed")
		if event.scancode == KEY_C:
			$MarginContainer/CenterContainer/VBoxContainer/CenterPlay/ButtonControls.emit_signal("pressed")
		if event.scancode == KEY_I:
			$MarginContainer/CenterContainer/VBoxContainer/CenterPlay/ButtonInstructions.emit_signal("pressed")

func _on_ButtonPlay_pressed():
	emit_signal("pressed_play")
	destroy()

func _on_ButtonControls_pressed():
	emit_signal("pressed_controls")
	destroy()

func _on_ButtonInstructions_pressed():
	emit_signal("pressed_instructions")
	destroy()
