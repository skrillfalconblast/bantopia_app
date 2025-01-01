extends MarginContainer


func _on_gui_input(event):
	print('hello')
	if (event is InputEventScreenTouch) or (event is InputEventMouseButton):
		print('signal emitted')
		LoadManager.launch_screen_pressed.emit()
