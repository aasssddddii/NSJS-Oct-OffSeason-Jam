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
	
	
func disable_start_menu() -> void:
	start_menu.process_mode = Node.PROCESS_MODE_DISABLED
func enable_start_menu()->void:
	start_menu.process_mode = Node.PROCESS_MODE_INHERIT
	
func clear_all_menus() -> void:
	for child in get_children():
		child.visible=false
#start menu
func open_options():
	clear_all_menus()
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
#in game
func toggle_options_menu()->void:
	if options_menu.visible:
		get_tree().paused = false
		clear_all_menus()
		player_ui.visible = true
	else:
		get_tree().paused = true
		clear_all_menus()
		update_options()
		options_menu.visible = true
		option_back_button.visible = false
	
func update_options()->void:
	#update window mode
	match game_manager.window_mode:
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
	
	
#option button handling
func cycle_window_mode()->void:
	if game_manager.window_mode < 2:
		game_manager.window_mode +=1
	else:
		game_manager.window_mode = 0
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
		track_player = false
		target.reset_player()
		game_manager.from_game = false
		reset_cam()
		game_manager.player_resource.reset_samples()
		
	
	
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
		next_display_sample.setup_display_sample(sample)
		
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
