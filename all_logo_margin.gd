extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	var margin_top = GlobalFunctions.get_margin_top()
	
	add_theme_constant_override("margin_top", margin_top)
