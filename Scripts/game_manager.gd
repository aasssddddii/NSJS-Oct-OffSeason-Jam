extends Node


@onready var player_resource :PlayerResource
@onready var display_sample := preload("res://Prefabs/display_sample.tscn")
@onready var mesh_n_material_lib := preload("res://Resources/mesh_n_materials_library.tres")
@onready var explosion_prefab:=preload("res://Prefabs/explosion.tscn")
var world_half_size_x := 775.0
var world_half_size_y := 775.0

#SAMPLES
@onready var test_sample_resource := preload("res://Resources/test_sample.tres")
@onready var monkey_head_sample:= preload("res://Resources/Real Samples/monkey_head.tres")
@onready var data_pad_sample:=preload("res://Resources/Real Samples/datapad.tres")
@onready var tesseract_sample:=preload("res://Resources/Real Samples/tesseract.tres")
@onready var can_sample:=preload("res://Resources/Real Samples/can.tres")
@onready var cubething_sample:= preload("res://Resources/Real Samples/cubething.tres")
@onready var message_sample:=preload("res://Resources/Real Samples/message.tres")
@onready var cone_sample:=preload("res://Resources/Real Samples/cone.tres")
@onready var can2_sample := preload("res://Resources/Real Samples/can2.tres")
@onready var ore1_sample := preload("res://Resources/Real Samples/ferrite_ore.tres")
@onready var ore2_sample := preload("res://Resources/Real Samples/verilium_ore.tres")
@onready var ore3_sample := preload("res://Resources/Real Samples/moolooite_ore.tres")
@onready var cozy_sample := preload("res://Resources/Real Samples/cozy.tres")
@onready var _sample := preload("res://Resources/Real Samples/710.tres")
@onready var random_sample := preload("res://Resources/Real Samples/random.tres")
@onready var planet1_sample := preload("res://Resources/Real Samples/planets/Ferrith_sample.tres")
@onready var planet2_sample := preload("res://Resources/Real Samples/planets/Kessil-V_sample.tres")
@onready var planet3_sample := preload("res://Resources/Real Samples/planets/Obsidara_sample.tres")
@onready var planet4_sample := preload("res://Resources/Real Samples/planets/Orris_sample.tres")
@onready var planet5_sample := preload("res://Resources/Real Samples/planets/Seraphe_sample.tres")
@onready var planet6_sample := preload("res://Resources/Real Samples/planets/Veltrine_sample.tres")
@onready var planet7_sample := preload("res://Resources/Real Samples/planets/Venera_sample.tres")

@onready var planet8_sample := preload("res://Resources/Real Samples/planets/Earth_sample.tres")
@onready var planet9_sample := preload("res://Resources/Real Samples/planets/Icetopia_sample.tres")
@onready var planet10_sample := preload("res://Resources/Real Samples/planets/Limona_sample.tres")
@onready var planet11_sample := preload("res://Resources/Real Samples/planets/Redstarium_sample.tres")
@onready var planet12_sample := preload("res://Resources/Real Samples/planets/Voxy_sample.tres")



#BG Music
var start_music:= "res://Audio/Ambent Music1.ogg"
var game_music1:= "res://Audio/game_track1.ogg"

var all_samples:Array[ResearchSampleResource]

var samples_needed:=7
var game_on:bool
var from_game:bool


var player_node:CharacterController
var backgound_music_player:AudioStreamPlayer

var save_path :String

var sample_testing:=false

func _ready() -> void:
	all_samples = [
		monkey_head_sample,
		data_pad_sample,
		tesseract_sample,
		can_sample,
		cubething_sample,
		cone_sample,
		can2_sample,
		ore1_sample,
		ore2_sample,
		ore2_sample,
		_sample,
		cozy_sample,
		random_sample,
		planet1_sample,
		planet2_sample,
		planet3_sample,
		planet4_sample,
		planet5_sample,
		planet6_sample,
		planet7_sample,
		planet8_sample,
		planet9_sample,
		planet10_sample,
		planet11_sample,
		planet12_sample,
	]
	#all_samples = [random_sample]
	
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_game()
	backgound_music_player = AudioStreamPlayer.new()
	add_child(backgound_music_player)
	backgound_music_player.bus = "BG"
	AudioServer.set_bus_volume_linear(1,player_resource.background_volume_db)
	if player_resource.sound_on:
		manage_bg_music("new",start_music)


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
	
func reload_game():
	get_tree().paused = false
	game_on = false
	get_tree().reload_current_scene()
	if player_resource.sound_on:
		manage_bg_music("new",start_music)
	
	
	
