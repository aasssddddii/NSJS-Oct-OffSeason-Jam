extends Node

@onready var test_sample_resource := preload("res://Resources/test_sample.tres")
@onready var player_resource :PlayerResource
@onready var display_sample := preload("res://Prefabs/display_sample.tscn")
@onready var mesh_n_material_lib := preload("res://Resources/mesh_n_materials_library.tres")
@onready var explosion_prefab:=preload("res://Prefabs/explosion.tscn")
var world_half_size_x := 250.0
var world_half_size_y := 250.0

var samples_needed:=5
var game_on:bool
var from_game:bool


var player_node:CharacterController
var backgound_music_player:AudioStreamPlayer

var save_path :String


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_game()
	backgound_music_player = AudioStreamPlayer.new()
	add_child(backgound_music_player)
	backgound_music_player.bus = "BG"
	AudioServer.set_bus_volume_linear(1,player_resource.background_volume_db)
	if player_resource.sound_on:
		manage_bg_music("new","res://Audio/Ambent Music1.ogg")


func manage_bg_music(choice:String,audio_path)->void:
	match choice:
		"new":
			#change to new audio
			backgound_music_player.stream = load(audio_path)
			#play audio
			backgound_music_player.play()
		"pause":
			#turn down audio
			backgound_music_player.volume_db -= 8
		"unpause":
			#turn up audio
			backgound_music_player.volume_db = player_resource.background_volume_db
		"stop":
			backgound_music_player.stream_paused = true
		"play":
			if backgound_music_player.stream_paused:
				backgound_music_player.stream_paused = false
			elif !game_on and !backgound_music_player.stream_paused:
				backgound_music_player.stream = load("res://Audio/Ambent Music1.ogg")
				backgound_music_player.play()
			elif game_on and !backgound_music_player.stream_paused:#VVVChange to ingame music
				backgound_music_player.stream = load("res://Audio/Ambent Music1.ogg")
				backgound_music_player.play()

func save_game():
	var error = ResourceSaver.save(player_resource, save_path)
	if error != OK:
		print("Error saving resource: ", error)
		return error
	else:
		print("sanity SAVE check: ", player_resource.saved_samples)
		print("Resource saved successfully!")
		return true

func load_game():
	var loaded_resource
	if !OS.has_feature("standalone"):
		save_path = "res://Saves/Save_data.tres"
		loaded_resource = ResourceLoader.load(save_path)
	else:
		save_path = "user://Saves/Save_data.tres"
		loaded_resource = ResourceLoader.load(save_path)
	
	print("sanity LOAD Path: ",save_path)
	 
	if loaded_resource:
		player_resource = loaded_resource
		print("sanity LOAD check: ", player_resource.saved_samples)
		return true
	else:
		print("Error loading resource or file not found.")
		player_resource = load("res://Resources/PlayerResource.tres")
		return false

#func player_resource_setter():
	#player_resource = load("res://Resources/PlayerResource.tres")
	#pass
	

	
	
	
	
