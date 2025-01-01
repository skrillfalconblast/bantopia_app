extends VBoxContainer

signal message_rect_changed

@export var showcase_message_tscn: PackedScene
@export var log_message_tscn: PackedScene
@export var main_background: ColorRect

@onready var chat_scroll = get_parent()

# Colors
var bantopia_red = Color('#fd4556')
var bantopia_black = Color('#000000')

# Bulk  thread 
var mutex: Mutex
var thread: Thread

func _ready():
	# Maybe we get a httprequest node have have this thing run its own api call
	ChatSignals.message_received.connect(add_message)
	ChatSignals.load_messages.connect(add_messages)

	# Threading
	mutex = Mutex.new()
	
	thread = Thread.new()
	
	var number_of_messages = self.get_child_count()
	
	if number_of_messages > 0:
		for message in self.get_children():
			if (message.get_index() % 2) == 0:
				message.background_color.set_color(Color('#fd4556'))
				message.message_content.set("custom_colors/font_color", Color('#000000'))
			else:
				message.background_color.set_color(Color('#000000'))
				message.message_content.set("theme_override_colors/font_color", Color('#fd4556'))
		#self.scroll_to_bottom(chat_scroll)

# We default to showcase because they generally look better than log form messages
# If its a dump the last message will not conver the second last message to a log.
func add_message(message_content, is_showcase=true, is_dump=false):

	
	var new_message: Node
	
	if is_showcase:
		new_message = showcase_message_tscn.instantiate()
	else:
		new_message = log_message_tscn.instantiate()
		

	var number_of_messages = self.get_child_count()
	var main_background_color: Color
	
	self.add_child(new_message)
	new_message.set_content(message_content)
	main_background.color = main_background_color
	#self.scroll_to_bottom(chat_scroll)
	
	if (number_of_messages % 2) == 0:
		
		new_message.background_color.set_color(bantopia_red)
		new_message.message_content.set("custom_colors/font_color", bantopia_black)
		
		# Allows a seemless transition from bottom of message to the background
		# if it's ever visible.
		main_background_color = bantopia_red
		
		if !is_dump:
			var previous_message_showcase = self.get_child(-2)
			var previous_message_log = log_message_tscn.instantiate()
			
			previous_message_log.background_color.set_color(bantopia_black)
			previous_message_log.message_content.set("theme_override_colors/font_color", bantopia_red)
			previous_message_log.set_content(previous_message_showcase.message_content.text)
			
			previous_message_showcase.queue_free()
			self.add_child(previous_message_log)
			self.move_child(previous_message_log, -2)
		
	else:
		
		new_message.background_color.set_color(bantopia_black)
		new_message.message_content.set("theme_override_colors/font_color", bantopia_red)
		
		# See above
		main_background_color = bantopia_black
		
		if !is_dump:
			var previous_message_showcase = self.get_child(-2)
			var previous_message_log = log_message_tscn.instantiate()
			
			previous_message_log.background_color.set_color(bantopia_red)
			previous_message_log.message_content.set("custom_colors/font_color", bantopia_black)
			previous_message_log.set_content(previous_message_showcase.message_content.text)
			
			previous_message_showcase.queue_free()
			self.add_child(previous_message_log)
			self.move_child(previous_message_log, -2)
	
func add_messages(messages: Array):
	print('add_messages_ran')
	print(messages)
	thread.start(bulk_add_messages.bind(messages))
	
	
func bulk_add_messages(messages: Array):
	print(thread.is_alive())
	print(thread.is_alive())
	
	var number_of_messages = messages.size()
	
	var iteration = 0
	
	for message: Dictionary in messages:
		print(thread.is_alive())
		iteration += 1
		
		# the last message becomes the showcase while the others join the log
		if iteration != number_of_messages:
			self.call_thread_safe("add_message", message['message_content'], false, true) # false is_showcase, true is_dump
		else:
			self.call_thread_safe("add_message", message['message_content'], true, true) # true is_showcase, true is_dump
		
	ChatSignals.call_deferred("emit_signal", "loaded_messages")


func _exit_tree():
	# Wait until it exits.
	thread.wait_to_finish()


#func scroll_to_bottom(scroll_container):
	##await get_tree().process_frame
	#scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
