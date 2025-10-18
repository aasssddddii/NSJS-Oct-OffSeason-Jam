extends Camera3D

var game_manager = GameManager

@export var target:CharacterController
const camera_offset:=7
const zoom_speed:=4
const max_offset:=30
const starting_position:= Vector3(-136.291,154.004,369.533)
const starting_rotation:= Vector3(-19,-28.6,-1.2)
const camera_transition_time:=5
var current_offset:= 7


@onready var start_button = $Start_Menu/SubViewport/VBoxContainer/start
@onready var options_button = $Start_Menu/SubViewport/VBoxContainer/options
@onready var quit_button= $Start_Menu/SubViewport/VBoxContainer/quit
@onready var credits_button = $Start_Menu/SubViewport/VBoxContainer/credits
@onready var end_screen = $End_screen
@onready var ui_fuel_bar = $SubViewportContainer/CanvasLayer/HBoxContainer/RightContainer/ui_fuel_bar
@onready var ui_health_bar = $SubViewportContainer/CanvasLayer/HBoxContainer/RightContainer/ui_health_bar
@onready var ui_stage_2_cooldown_bar = $SubViewportContainer/CanvasLayer/HBoxContainer/RightContainer/ui_stage2_cooldown_bar
@onready var ui_data_bar = $"SubViewportContainer/CanvasLayer/Lore Ui/RightContainer/ui_data_bar"
@onready var ui_player_samples = $"SubViewportContainer/CanvasLayer/Lore Ui/RightContainer/ui_samples"
@onready var option_back_button = $Options_Menu/SubViewport/back_button
@onready var credits_back_button = $Credit_Screen/SubViewport/back
@onready var start_menu = $Start_Menu
@onready var sample_library_screen = $Samples_screen
@onready var player_ui = $SubViewportContainer
@onready var options_menu = $Options_Menu
@onready var credit_screen = $Credit_Screen
@onready var ty_message = $Credit_Screen/SubViewport/TY
@onready var end_back_button = $End_screen/SubViewport/ok_button
#option menu stuff
@onready var ui_window = $Options_Menu/SubViewport/HBoxContainer/RightContainer/ui_window

@onready var sample_display_grid = $End_screen/SubViewport/ScrollContainer/GridContainer
@onready var ui_samples = $End_screen/SubViewport/HBoxContainer/RightContainer/MarginContainer/ui_samples


@onready var ui_data = $End_screen/SubViewport/HBoxContainer/RightContainer/ui_data
#endscreen lore text
@onready var true_end = $"End_screen/SubViewport/Panel2/Mission True End"
@onready var good_end = $"End_screen/SubViewport/Panel2/Mission Succes"
@onready var bad_end = $"End_screen/SubViewport/Panel2/Mission Failed"

@onready var sound_label = $"Options_Menu/SubViewport/HBoxContainer/MarginContainer/LeftContainer/Sound Label2"
@onready var music_label = $"Options_Menu/SubViewport/HBoxContainer/MarginContainer/LeftContainer/music Label3"
@onready var sfx_label = $"Options_Menu/SubViewport/HBoxContainer/MarginContainer/LeftContainer/Sfx Label4"
@onready var ui_sound = $Options_Menu/SubViewport/HBoxContainer/RightContainer/ui_sound
@onready var music_slider = $Options_Menu/SubViewport/HBoxContainer/RightContainer/MarginContainer/music_slider
@onready var sfx_slider = $Options_Menu/SubViewport/HBoxContainer/RightContainer/MarginContainer2/sfx_slider

@onready var sample_library_close_button = $Samples_screen/SubViewport/back_button
@onready var sample_library_open_button = $Start_Menu/SubViewport/VBoxContainer/sample
@onready var sample_grid = $Samples_screen/SubViewport/ScrollContainer/GridContainer

var track_player:bool

func _ready() -> void:
	reset_cam()
	start_button.button_up.connect(start_transition)
	options_button.button_up.connect(open_options)
	credits_button.button_up.connect(open_credits)
	quit_button.button_up.connect(quit_game)
	option_back_button.button_up.connect(option_close)
	credits_back_button.button_up.connect(close_credits)
	end_back_button.button_up.connect(open_credits)
	ui_window.button_up.connect(cycle_window_mode)
	ui_sound.button_up.connect(toggle_sound)
	sample_library_open_button.button_up.connect(open_sample_library)
	sample_library_close_button.button_up.connect(close_sample_library)
	music_slider.value_changed.connect(update_music_volume)
	sfx_slider.value_changed.connect(update_sfx_volume)
	clear_all_menus()
	start_menu.visible = true
	
	
func _process(_delta: float) -> void:
	if track_player and target != null:
		start_tracking()
	if game_manager.game_on:
		if Input.is_action_just_pressed("camera_zoom_in"):
			if current_offset > camera_offset:
				current_offset -= zoom_speed
		if Input.is_action_just_pressed("camera_zoom_out"):
			if current_offset < max_offset:
				current_offset += zoom_speed
		if Input.is_action_just_pressed("player_pause"):
			
			toggle_options_menu()
			
func start_tracking():
	global_position = Vector3(target.global_position.x,target.global_position.y,target.global_position.z+current_offset)

func reset_camera():
	current_offset = 7
	global_position = Vector3(target.global_position.x,target.global_position.y,target.global_position.z+current_offset)
func start_transition()->void:
	#print("starting game, checking target: ", target)
	clear_all_menus()
	disable_start_menu()
	var tweener = create_tween()
	tweener.set_parallel()
	tweener.tween_property(self,"global_position",Vector3(target.global_position.x,target.global_position.y,target.global_position.z+current_offset),camera_transition_time)
	tweener.tween_property(self,"rotation_degrees",Vector3(0,0,0),camera_transition_time)
	tweener.play()
	
	tweener.finished.connect(start_game)
	
func start_game() -> void:
	game_manager.game_on = true
	player_ui.visible = true
	track_player = true
	game_manager.player_resource.reset_player()
	
	
func disable_start_menu() -> void:
	start_menu.process_mode = Node.PROCESS_MODE_DISABLED
func enable_start_menu()->void:
	start_menu.process_mode = Node.PROCESS_MODE_INHERIT
	
func clear_all_menus() -> void:
	for child in get_children():
		child.visible=false
		
func open_sample_library()->void:
	clear_all_menus()
	setup_sample_library()
	sample_library_screen.visible = true
func close_sample_library()->void:
	clear_all_menus()
	#clear sample grid
	start_menu.visible = true
	
func setup_sample_library():
	for sample in game_manager.player_resource.saved_samples:
		var next_display_sample = game_manager.display_sample.instantiate()
		sample_grid.add_child(next_display_sample)
		next_display_sample.setup_display_sample(sample,false)
	
#start menu
func open_options():
	clear_all_menus()
	setup_sliders()
	update_options()
	options_menu.visible=true
func option_close()->void:
	if !game_manager.game_on:
		clear_all_menus()
		start_menu.visible=true
	else:
		clear_all_menus()
		player_ui.visible = true
		get_tree().paused = false
	print("saving game: ", game_manager.save_game())
#in game
func toggle_options_menu()->void:
	if options_menu.visible:
		get_tree().paused = false
		clear_all_menus()
		player_ui.visible = true
		game_manager.manage_bg_music("unpause",null)
		print("saving game: ", game_manager.save_game())
	else:#paused
		get_tree().paused = true
		clear_all_menus()
		update_options()
		options_menu.visible = true
		option_back_button.visible = false
		game_manager.manage_bg_music("pause",null)
	
func update_options()->void:
	#update window mode
	match game_manager.player_resource.window_mode:
		0:
			ui_window.text = "Windowed"
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
		1:
			ui_window.text = "Fullscreen"
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2:
			ui_window.text = "Borderless"
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,true)
	#update sound settings
	match game_manager.player_resource.sound_on:
		true:
			ui_sound.text = "on"
			show_sound_settings(true)
		false:
			ui_sound.text = "off"
			show_sound_settings(false)
	
	
func show_sound_settings(choice:bool):
	music_label.visible = choice
	music_slider.visible = choice
	sfx_label.visible = choice
	sfx_slider.visible = choice
	
		


func toggle_sound():
	var bus_index = AudioServer.get_bus_index("Master")
	game_manager.player_resource.sound_on = !game_manager.player_resource.sound_on
	if game_manager.player_resource.sound_on == true:
		#turn music back on
		AudioServer.set_bus_volume_db(bus_index,0)
		game_manager.manage_bg_music("play",null)
	else:
		AudioServer.set_bus_volume_db(bus_index,-80)
		game_manager.manage_bg_music("stop",null)
	update_options()
	
func update_music_volume(value:float):
	game_manager.player_resource.background_volume_db = value
	AudioServer.set_bus_volume_linear(1,value)
	
func update_sfx_volume(value:float):
	game_manager.player_resource.sfx_volume_db = value
	AudioServer.set_bus_volume_linear(2,value)
	#linear_to_db(value)
	
func setup_sliders():
	music_slider.value = game_manager.player_resource.background_volume_db
	sfx_slider.value = game_manager.player_resource.sfx_volume_db
	
#option button handling
func cycle_window_mode()->void:
	if game_manager.player_resource.window_mode < 2:
		game_manager.player_resource.window_mode +=1
	else:
		game_manager.player_resource.window_mode = 0
	update_options()
	
	


func open_credits():
	clear_all_menus()
	credit_screen.visible = true
	if game_manager.from_game:
		ty_message.visible = true
	else:
		ty_message.visible = false
	
func close_credits():
	clear_all_menus()
	enable_start_menu()
	start_menu.visible = true
	if game_manager.from_game:
		#game_manager.reset_game()
		game_manager.player_resource.bank_samples(game_manager.player_resource.player_win)
		track_player = false
		#target.reset_player()
		game_manager.save_game()
		game_manager.player_resource.reset_player()
		game_manager.from_game = false
		reset_cam()
		get_tree().reload_current_scene()
		#game_manager.player_resource.reset_samples()
		
	
	
func open_end(win:bool):
	clear_all_menus()
	setup_end(win)
	end_screen.visible = true
	
func setup_end(win:bool):
	var sample_amount = game_manager.player_resource.samples.size()
	clear_sample_diaplay()
	ui_samples.text = var_to_str(sample_amount)
	ui_data.text = String.num(game_manager.player_resource.data_downloaded,3) + " TB"
	for sample in game_manager.player_resource.samples:
		var next_display_sample = game_manager.display_sample.instantiate()
		sample_display_grid.add_child(next_display_sample)
		next_display_sample.setup_display_sample(sample,true)
		
	if game_manager.player_resource.samples.size()>=game_manager.samples_needed*2 and win:
		true_end.visible = true
	elif game_manager.player_resource.samples.size()>=game_manager.samples_needed and win:
		good_end.visible = true
	else:
		bad_end.visible = true
func clear_sample_diaplay():
	for child in sample_display_grid.get_children():
		child.queue_free()
	
func quit_game() -> void:
	get_tree().quit()
func reset_cam()->void:
	global_position = starting_position
	rotation_degrees = starting_rotation
