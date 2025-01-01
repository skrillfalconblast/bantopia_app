extends TextEdit

@export var main_scene: Control

@export var input_margin: MarginContainer

@export var double_tap_timer: Timer

@onready var base_margin_bottom = input_margin.get_theme_constant("margin_bottom")

# Monitors 
@export var displacement_monitor: Label
@export var velocity_monitor: Label
@export var force_monitor: Label


# To detect double taps
var taps: int = 0

# True when the input is in focus, false when it's not in focus
var shouldKeyboardBeVisible: bool = false

# False means the screen needs to be raised, vice versa.,
var screenRaised: bool = false

# ------------- Drag functionality variables ----------------
# True when the user is dragging in input
var dragging: bool = false

# Used to set original position
var original_position_y_set: bool = false

# Used for resetting the y position after drag is released
var original_position_y: float 

# Physics
var displacement: float
var velocity: float
var force: float
var spring_constant: float = 2
var dampening: float = 0.9
var flung: bool = false # Used to tell if the input has been thrown.
var teleported: bool = true # Used to prevent the velocity reacting when the input position is moved non-continuously

var last_pos_y: float
var flung_velocity: float

var keyboard_height: float

var count: int

func _ready():
	ChatSignals.chat_scroll_clicked.connect(clicked_out)
	
func _process(delta):
	# Check's when the keyboard is visible and when the screen hasn't been moved up.
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		keyboard_height = DisplayServer.virtual_keyboard_get_height()
		var main_scene_y = main_scene.position.y
		print('main_Scene_y: ', + main_scene_y)
		print('Screen get size: ', + DisplayServer.screen_get_size().y)
		print('Safe Area: ', + DisplayServer.get_display_safe_area().end.y)
		print('keyboard height: ', + keyboard_height)
		# If the should be visible keyboard the screen is moved up, vice versa.
		if shouldKeyboardBeVisible and keyboard_height > 0 and main_scene_y == 0:
			if !screenRaised:
				main_scene_y -= (keyboard_height - GlobalFunctions.get_margin_bottom())
				var up_tween = create_tween()
				up_tween.tween_property(main_scene, "position", Vector2(0, main_scene_y), 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				self.screenRaised = true
		elif not shouldKeyboardBeVisible: # If the keyboard shouldn't be visible ground the screen.
			if screenRaised:
				var down_tween = create_tween()
				down_tween.tween_property(main_scene, "position", Vector2(0, 0), 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				self.screenRaised = false
	
	# Annoyingly ugly
	if !original_position_y_set:
		original_position_y = self.position.y + self.size.y # Position relative to bottom side of input
		self.last_pos_y = original_position_y
		self.original_position_y_set = true
		
	# Less frequent updates.
	count += 1
	
	# Displacement control
	self.displacement = (self.position.y + self.size.y) - original_position_y
	

	if dragging:
		self.force = 0
		
		if (count % 100) == 0:
			print('velocity = ', self.velocity)
			print('prospective force = ', (-1 * (displacement * spring_constant)))
	else:
		#self.flung = false
		if self.flung:
			self.velocity = -10000
			self.force = 0
			self.position.y += (self.velocity * delta) # Change position depending on the velocity
			print('flung')
		else:
			self.force = -1 * (displacement * spring_constant) # Hookes law, extension * spring constant
			self.velocity += force # Change speed using force because F = A (due to the input being modelled as having no mass)
			self.position.y += (self.velocity * delta) # Change position depending on the velocity
			self.velocity *= 0.8
	
	if self.position.y < -(self.size.y):
		self.send_and_clear()
		self.teleported = true
		self.position.y = DisplayServer.screen_get_size().y
		self.flung = false
	
	displacement_monitor.text = 'x:  ' + str(self.displacement)
	velocity_monitor.text = 'v:  ' + str(self.velocity)
	force_monitor.text = 'F:  ' + str(self.force)


func _on_gui_input(event):
	if (event is InputEventScreenTouch):
		if event.double_tap:
			self.velocity = -1000 # MAGIC NUMBERS
		if event.pressed: # When the user first touches the input. 
			print('touch pressed')
		if !event.pressed: # If the touch was released
			if dragging: # If the touch was released and the input is being dragged
				self.dragging = false
				if velocity < -10:
					self.flung = true
	elif event is InputEventMouseButton: # This is repeated code, however, its doesn't seem too ugly at the moment
		if event.pressed:
			pass
		elif event.double_click:
			self.velocity = -1000 # MAGIC NUMBERS
		if !event.pressed:
			if dragging: # If the touch was released and the input is being dragged
				self.dragging = false
				if velocity < -10:
					self.flung = true
		else:
			print('mouse released')
			
		
	elif event is InputEventScreenDrag:
		self.flung = false
		self.dragging = true
		self.position.y += event.relative.y
		
		if !teleported:
			self.velocity = ((self.position.y + self.size.y) - last_pos_y)
		else:
			self.velocity = self.velocity
			teleported = false
		self.last_pos_y = (self.position.y + self.size.y)
		
		
func clicked_out():
	print(dragging)
	if !dragging:
		release_focus()

func _on_focus_exited():
	# When the input focus is exited the keyboard is pushed down
	shouldKeyboardBeVisible = false


func _on_focus_entered():
	print(self.focus_mode)
	shouldKeyboardBeVisible = true
	
func send_and_clear():
	ChatSignals.message_sent.emit(self.text)
	self.text = ''
