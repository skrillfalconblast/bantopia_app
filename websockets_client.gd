extends Node

signal connected
signal data
signal disconnected
signal error

# Our WebSocketClient instance
var _client = WebSocketPeer.new()

var _last_connected_url: String = ''

func connect_to_socket(websocket_url: String, port: int) -> void:
	# Connects to the server or emits an error signal.
	# If connected, emits a connect signal.
	
	print('ATTEMPTING TO CONNECT')
	print(websocket_url)
	self._last_connected_url = websocket_url
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		self.error.emit()
	else:
		print("CONNECTION SUCCESSFUL")
	

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)


func _connected(proto = ""):
	print("Connected with protocol: ", proto)


func _on_data(packet):
	var json_string: String = packet.get_string_from_utf8()
	
	var json = JSON.new()
	var err = json.parse(json_string)
	if err == OK:
		var json_data = json.data
		
		if typeof(json_data) == TYPE_DICTIONARY:
			self.data.emit(json_data)
			
		else:
			print("Unexpected data: ", typeof(json_data))
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

func _process(delta):
	_client.poll()
	var state = _client.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while _client.get_available_packet_count():
			var packet: PackedByteArray = _client.get_packet()
			self._on_data(packet)
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		print('Websocket state is closing.')
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = _client.get_close_code()
		var reason = _client.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		
		# Attempt to reconnect
		if _last_connected_url:
			self.connect_to_socket(_last_connected_url, 8081)


func _send_data(dict: Dictionary) -> void:
	if _client.get_ready_state() == 1:
		var data = JSON.stringify(dict).to_utf8_buffer()
		_client.send(data)
	else:
		print('Not sent, client ready state = ', _client.get_ready_state())
