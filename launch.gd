extends Control

# Imports
const WebsocketClient = preload("res://websockets_client.gd")

@onready var animations = $AnimationPlayer

@export var http_request: HTTPRequest

@onready var api_url = AppState.API_URL

# Scene loading stuff
var progress = []
var scene_load_status = 0

# Try to optimise this unscalable work.
var warning_animation_done = false
var http_request_done = false
var socket_prepared = false
var new_scene_added_to_tree = false
var new_scene_prepared_to_switch = false # In this case it means the messages are loaded

# Global http varaible, try refactor this stuff to make it scalable.
var _http_body: PackedByteArray

var _data: Dictionary

var _websocket_client: Node

func _ready():
	
	ActiveSocket.add_child(WebsocketClient.new())
	_websocket_client = ActiveSocket.get_child(0)
	
	# Prepare socket when the scene is loaded (mabye change the trigger to "as soon as possible")
	LoadManager.load_done.connect(add_main_scene_in_background)
	LoadManager.launch_screen_pressed.connect(_on_animation_finished.bind('Epilepsy Warning'))
	
	ChatSignals.loaded_messages.connect(loaded_messages)
	
	http_request.request(api_url) # Get the latest posts with an http request.
	
	LoadManager.load_scene(LoadManager.main_scene_path)
	
	self.animations.play.bind('Epilepsy Warning')
	
#func _exit_tree():
	#socket_thread.wait_to_finish()

#### Flow Chart #####
# 1. Send http request -> Wait for response -> Prepare socket
# 2. Start loading main scene -> Wait for load to finish
# 3. Start animation

# : When (socket is prepared) and (load is finished)
# -> Prepare new scene to switch (e.g. load the messages of the main scene in the background)

# When (new scene is prepared to switch) and (animation has finished)
# -> Switch Scene
### End ###

# When the http request comes back
func _on_http_request_completed(result, response_code, headers, body):
	match result:
		0:#? RESULT_SUCCESS
			self._http_body = body
			self.http_request_done = true
			print('request completed')
			prepare_socket()
		2, 3, 4, 5, 9:#? RESULT_CANT_CONNECT = 2, RESULT_CANT_RESOLVE = 3, RESULT_CONNECTION_ERROR = 4, RESULT_TLS_HANDSHAKE_ERROR = 5, RESULT_REQUEST_FAILED = 9
			print("Something went wrong when you tried to connect to the server. I'm tring again.")
			http_request.request(api_url)
		1, 6, 7, 8, 10, 11, 12:#? RESULT_CHUNKED_BODY_SIZE_MISMATCH = 1, RESULT_NO_RESPONSE = 6, RESULT_BODY_SIZE_LIMIT_EXCEEDED = 7, ULT_BODY_DECOMPRESS_FAILED = 8, RESULT_DOWNLOAD_FILE_CANT_OPEN = 10, RESULT_DOWNLOAD_FILE_WRITE_ERROR = 11, RESULT_REDIRECT_LIMIT_REACHED = 12
			print("Something went wrong with the data you received from the server. I'm tring again.")
			http_request.request(api_url)
		13:#? RESULT_TIMEOUT = 13
			print("Your request is taking too long, I'm sending another.")
			http_request.request(api_url)

func _on_animation_finished(anim_name):
	self.warning_animation_done = true
	if anim_name == 'Epilepsy Warning':
		print('animation done')
		if new_scene_prepared_to_switch: # Whichever happens last (the new scene being prepared or the animation finishing)
			switch_to_main()
	
func prepare_socket():
	# Instance the new scene and hook up its websocket connection
	var json_string = _http_body.get_string_from_utf8() # Get the response body as a json string
	
	var json = JSON.new()
	var err = json.parse(json_string) # Parse json string into a dictionary
	if err == OK:
		self._data = json.data
		
		if self._data:
			var websocket_url = AppState.WEBSOCKET_URL.format({'post_code' : _data['post_code']})
			
			_websocket_client.connect_to_socket(websocket_url, 8081)
			self.socket_prepared = true
			print('socket prepared')
			if new_scene_added_to_tree: # Whichever happens last (the socket being prepared or the new scene being added to the tree)
				ChatSignals.load_messages.emit(_data['recent_messages'])
		else:
			print('NO DATA RECEIVED')
	else:
		prepare_socket()

# Try generalise this to adding any scene (may be as easy as changing the name of this function)
func add_main_scene_in_background(new_scene_resource):
	var new_scene = new_scene_resource.instantiate()
	new_scene.visible = false
	get_node("/root").add_child(new_scene)
	self.new_scene_added_to_tree = true
	print('new scene added to tree')
	if socket_prepared: # Whichever happens last (the socket being prepared or the new scene being added to the tree)
		ChatSignals.load_messages.emit(_data['recent_messages'])
	
func loaded_messages():
	print('loaded messages')
	self.new_scene_prepared_to_switch = true
	if warning_animation_done: # Whichever happens last (the new scene being prepared or the animation finishing)
		switch_to_main()

# THIS IS HORREDNOUS PLEASE DO SOMETHING ABOUT THIS
func switch_to_main():
	# New Scene
	print('scene switch started')
	get_tree().root.get_node('Main').visible = true
	get_tree().current_scene = get_tree().root.get_node('Main')
	self.queue_free()
	print('scene switch finisihed')
