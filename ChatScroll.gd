extends ScrollContainer

# Add some useful signals here

@onready var scroll_bar = self.get_v_scroll_bar()

var end_point: int
var start_point: int
var dragging: bool

var max_scroll_length: int = 0

func _ready():
	scroll_bar.changed.connect(handle_scroll_bar_changed)
	
func handle_scroll_bar_changed():
	if max_scroll_length != scroll_bar.max_value:
		max_scroll_length = scroll_bar.max_value
		self.scroll_vertical = scroll_bar.max_value

func _on_gui_input(event):
	if (event is InputEventScreenTouch) or (event is InputEventMouseButton):
		print('chat scroll was clicked')
		ChatSignals.chat_scroll_clicked.emit()
		if !event.pressed:
			self.dragging = false
	if event is InputEventScreenDrag:
		self.dragging = true


# Fix this up, because its not working
#func _process(delta):
	#if !dragging:
		#end_point = self.scroll_bar.value
		#if start_point:
			#self.scroll_bar.value =- end_point
			#start_point = self.scroll_bar.value
		#else:
			#start_point = end_point
