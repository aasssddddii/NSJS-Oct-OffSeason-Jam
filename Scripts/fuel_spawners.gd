extends Node3D

@onready var interactable_node = $"../interactables"
@onready var fuel_dust:= preload("res://Prefabs/fuel_sphere.tscn")

var game_manager = GameManager

func _ready() -> void:
	for child in get_children():
		for fuel_spawn_number in 10:
			var next_fuel_dust = fuel_dust.instantiate()
			interactable_node.add_child(next_fuel_dust)
			next_fuel_dust.global_position = child.global_position + Vector3(randi_range(0,300),randi_range(0,300),0)
			if abs(next_fuel_dust.global_position.x) > game_manager.world_half_size_x:
				if next_fuel_dust.global_position.x >0:
					next_fuel_dust.global_position.x = game_manager.world_half_size_x -10
				else:
					next_fuel_dust.global_position.x = -game_manager.world_half_size_x +10
			if abs(next_fuel_dust.global_position.y) > game_manager.world_half_size_y:
				if next_fuel_dust.global_position.y >0:
					next_fuel_dust.global_position.y = game_manager.world_half_size_y -10
				else:
					next_fuel_dust.global_position.y = -game_manager.world_half_size_y +10
