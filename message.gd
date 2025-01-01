extends Control

@export var message_content: Label
@export var background_color: ColorRect

@export var default_content: String = ''

func _ready():
	var screen_size = get_tree().root.get_node('Main').size
	self.custom_minimum_size = screen_size
	

func set_content(content):
	message_content.text = content
	
	
	
