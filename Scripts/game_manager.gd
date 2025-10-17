extends Node

@onready var test_sample_resource := preload("res://Resources/test_sample.tres")
@onready var player_resource := preload("res://Resources/PlayerResource.tres")
@onready var display_sample := preload("res://Prefabs/display_sample.tscn")
@onready var mesh_n_material_lib := preload("res://Resources/mesh_n_materials_library.tres")
var world_half_size_x := 250.0
var world_half_size_y := 250.0

var samples_needed:=5
var game_on:bool
var from_game:bool
#options
var window_mode:int

var player_node:CharacterController

##Sample Meshes
#@onready var test_sample_mesh = preload("res://Prefabs/3D files/Samples/test_sample_mesh.tres")
	#
	#
	#
##sample Materials
#@onready var test_sample_material = preload("res://Materials/Satillie_Textures/ShipBody/shipbody.tres")
#
##Planet Materials
