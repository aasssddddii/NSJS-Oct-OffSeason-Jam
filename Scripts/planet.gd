extends StaticBody3D
class_name Planet


@onready var gravity_field = $"Gravity Field"
@onready var gavity_field_collider = $"Gravity Field/CollisionShape3D"
@export var planet_resource:PlanetResource
@onready var refuel_pad_prefab = preload("res://Prefabs/refuel_pad.tscn")
@onready var refuel_pad = $refuel_pad
@onready var planet_mesh = $MeshInstance3D
@onready var planet_collider = $surface
#Planet Variables
#var gravity_strength:float = 1
#var mass:float = .5

func _ready() -> void:
	setup_planet()
	gravity_field.body_entered.connect(apply_gravity)
	gravity_field.body_exited.connect(remove_gravity)
	if planet_resource.refuel_pad:
		spawn_refuel_pad()
	
func setup_planet():
	var planet_mesh_ref = planet_mesh.mesh
	var planer_collider_ref = planet_collider.shape
	planet_mesh_ref.radius = planet_resource.radius
	planet_mesh_ref.height = planet_resource.radius *2
	planer_collider_ref.radius = planet_resource.radius + 0.05
	

func apply_gravity(body):
	if body.is_in_group("Player"):
		body.add_planet(self)
		
func remove_gravity(body):
	if body.is_in_group("Player"):
		body.remove_planet(self)
		
func spawn_refuel_pad():
	var next_refuel_pad = refuel_pad_prefab.instantiate()
	refuel_pad.add_child.call_deferred(next_refuel_pad)
	var planet_mesh_ref = planet_mesh.mesh
	next_refuel_pad.spawn_refuel_pad(planet_mesh_ref.radius)
	
