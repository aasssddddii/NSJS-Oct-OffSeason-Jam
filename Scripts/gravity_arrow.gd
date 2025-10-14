extends Node3D

var player:CharacterController

func setup_arrow(input_node:CharacterController):
	player = input_node

func _process(_delta: float) -> void:
	if player != null:
		global_position = player.global_position
