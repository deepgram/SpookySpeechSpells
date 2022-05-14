extends Control

signal pressed_back

func destroy():
	get_tree().queue_delete(self)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_B:
			$MarginContainer/CenterContainer/VBoxContainer/CenterContainer/ButtonBack.emit_signal("pressed")

func _on_ButtonBack_pressed():
	emit_signal("pressed_back")
	destroy()
