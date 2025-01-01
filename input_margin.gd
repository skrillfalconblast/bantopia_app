extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	var margin_bottom = GlobalFunctions.get_margin_bottom()
	
	add_theme_constant_override("margin_bottom", margin_bottom)
