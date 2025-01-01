extends Node

func get_margin_top():
	var screen_size = DisplayServer.screen_get_size()
	var safe_area = DisplayServer.get_display_safe_area()
	
	var top: int = 0
	top = safe_area.position.y
	
	if top < (screen_size.y / 24):
		top = screen_size.y / 24
	
	return top

func get_margin_bottom():
	var screen_size = DisplayServer.screen_get_size()
	var safe_area = DisplayServer.get_display_safe_area()
	
	var ratio: int = 18 # MARGIC NUMBER
	
	match OS.get_name():
		"Android":
			var bottom: int = 0
			bottom = screen_size.y / ratio # Behaviour on Android where the safe area doesn't include the keyboard
			return bottom
		"iOS":
			var bottom: int = 0
			bottom = screen_size.y - safe_area.end.y
			
			if bottom < (screen_size.y / ratio):
				bottom = screen_size.y / ratio
		
			return bottom
		_:
			var bottom: int = 0
			bottom = screen_size.y - safe_area.end.y
			
			if bottom < (screen_size.y / ratio):
				bottom = screen_size.y / ratio
		
			return bottom
