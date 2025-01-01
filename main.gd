extends Control

# Imports
const WebsocketClient = preload("res://websockets_client.gd")

@export var http_request: HTTPRequest

var api_url = AppState.API_URL

@onready var _websocket_client = ActiveSocket.get_child(0)

func _ready():
	_websocket_client.connected.connect(_handle_client_connected)
	_websocket_client.disconnected.connect(_handle_client_disconnected)
	_websocket_client.error.connect(_handle_network_error)
	_websocket_client.data.connect(_handle_network_data)
	
	ChatSignals.message_sent.connect(send_message_to_socket)
	

# ------------------------ Save System ------------------------

func save(record, value):
	
	if typeof(value) == 1: # Boolean
		if value:
			value = 'True'
		else:
			value = 'False'
	else:
		print('ERROR: Unfamiliar Data Type')
		
		
	var save_dict = {
		record : value
	}
	
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_game.store_line(json_string)

	
func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return
	
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		var node_data = json.get_data()



# -------------- Networking ------------------



func send_message_to_socket(message_content: String):
	
	var data = {'message' : message_content}
	_websocket_client._send_data(data)


func _handle_client_connected():
	print("Client connected to server!")


func _handle_client_disconnected(was_clean: bool):
	OS.alert("Disconnected %s" % ["cleanly" if was_clean else "unexpectedly"])
	get_tree().quit()


func _handle_network_data(data: Dictionary):
	if data.has('message_code'):
		ChatSignals.message_received.emit(data['message'])


func _handle_network_error():
	OS.alert("There was an error")
	
