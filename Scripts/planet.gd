extends StaticBody3D
class_name Planet


@onready var gravity_field = $"Gravity Field"
@export var planet_resource:PlanetResource
#Planet Variables
#var gravity_strength:float = 1
#var mass:float = .5

func _ready() -> void:
	gravity_field.body_entered.connect(apply_gravity)
	gravity_field.body_exited.connect(remove_gravity)
	#planet_resource = load("res://Resources/Test_Planet.tres")
	
func apply_gravity(body):
	if body.is_in_group("Player"):
		body.add_planet(self)
		
func remove_gravity(body):
	if body.is_in_group("Player"):
		body.remove_planet(self)
