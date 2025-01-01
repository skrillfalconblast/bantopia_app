extends Node

signal progress_changed(progress)
signal load_done(loaded_resource)
signal launch_screen_pressed

const main_scene_path = "res://main.tscn"
const launch_scene_path = "res://launch.tscn"

#var _load_screen_path: String = ''
#var _load_screen = load(_load_screen_path)
var _loaded_resource: PackedScene
var _scene_path: String
var _progress: Array

var CHAT_BUFFER = []

func load_scene(scene_path: String) -> void:
	self._scene_path = scene_path
	
	# var new_loading_screen = _load_screen.instantiate()
	# get_tree().get_root().add_child(new_loading_screen)
	
	# self.progress_changed.connect(new_loading_screen._update_progress_bar)
	# self.load_done.connect(new_loading_screen._start_outro_animation)
	
	#await Signal(new_loading_screen, "loading_screen_has_full_coverage")
	
	start_load()
	
func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(_scene_path)
	if state == OK:
		print('state active')
		set_process(true)
		
		
func _process(delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	match load_status:
		0, 2: #? THREAD_LOAD_INVALID_RESOURCE, THREAD_LOAD_FAILED
			set_process(false)
			print('Thread Load FAILED. Trying again.')
			load_scene(_scene_path)
			return
		1: #? THREAD_LOAD_IN_PROGRESS
			self.progress_changed.emit(_progress[0])
			print(_progress[0])
		3: #? THREAD_LOAD_LOADED
			print('thread loaded')
			_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
			self.progress_changed.emit(_progress[0])
			self.load_done.emit(_loaded_resource)
			set_process(false)
