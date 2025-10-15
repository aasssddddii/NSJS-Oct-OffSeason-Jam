extends Camera3D

@export var target:CharacterController
const camera_offset:=7

@onready var ui_fuel = $SubViewportContainer/CanvasLayer/HBoxContainer/RightContainer/ui_fuel

func _process(_delta: float) -> void:
	if target != null:
		start_tracking()
func start_tracking():
	global_position = Vector3(target.global_position.x,target.global_position.y,target.global_position.z+camera_offset)
