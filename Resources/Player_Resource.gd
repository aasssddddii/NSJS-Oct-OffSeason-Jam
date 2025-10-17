extends Resource
class_name PlayerResource

@export var fuel:float =1.0
@export var health:float#= 1.0
@export var max_fuel:float = 1
@export var max_health:float = 1
@export var samples:Array[ResearchSampleResource] #= [load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres"),load("res://Resources/test_sample.tres")]
@export var data_downloaded:float #= .608


func reset_samples()->void:
	samples.clear()
