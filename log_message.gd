extends MarginContainer

@export var message_content: Label
@export var background_color: ColorRect

@export var default_content: String = ''

func set_content(content):
	message_content.text = content
	
