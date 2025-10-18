extends Resource
class_name PlayerResource

@export var fuel:float =1.0
@export var health:float#= 1.0
@export var max_fuel:float = 1
@export var max_health:float = 1
@export var samples:Array[ResearchSampleResource] #= [load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres")]
@export var data_downloaded:float #= .608
@export var total_data:float

@export var home_samples:Array[ResearchSampleResource]
@export var saved_samples:Array[ResearchSampleResource]


@export var player_win:bool
#Options variables
@export var window_mode:int
@export var sound_on:= true
@export var background_volume_db:= .4
@export var sfx_volume_db:= .4


func reset_samples()->void:
	samples.clear()
	player_win = false

func reset_player()->void:
	fuel = 1
	health = 1
	data_downloaded=0
	samples = []
	reset_samples()

func save_sample(sample:ResearchSampleResource,home_saved:bool)-> void:
	if saved_samples.find(sample) == -1:
		saved_samples.append(sample)
	if home_saved:
		if home_samples.find(sample) == -1:
			home_samples.append(sample)
		
	print("DEBUG: saved samples now: ", saved_samples)

func bank_samples(win:bool) -> void:
	for sample in samples:
		save_sample(sample,win)
	
	
	
	
	
