extends StaticBody3D
class_name Planet

var game_manager = GameManager

@onready var gravity_field = $"Gravity Field"
@onready var gavity_field_collider = $"Gravity Field/CollisionShape3D"
@export var planet_resource:PlanetResource
@onready var refuel_pad = $refuel_pad
@onready var planet_mesh = $MeshInstance3D
@onready var planet_collider = $surface
@onready var interactables_node = $"../../interactables"
@onready var hazards_node = $"../../hazards"
@onready var sample_spawner = $spawner_pivot/sample_spawner
@onready var spawner_pivot = $spawner_pivot
#asteroids
@onready var asteroid1_prefab = load("res://Prefabs/asteroid1.tscn")
@onready var asteroid2_prefab = load("res://Prefabs/asteroid2.tscn")
@onready var asteroid3_prefab = load("res://Prefabs/asteroid3.tscn")


func _ready() -> void:
	setup_planet()
	gravity_field.body_entered.connect(apply_gravity)
	gravity_field.body_exited.connect(remove_gravity)
	#initial set
	sample_spawner.position = Vector3(0,planet_resource.radius+10,0)
	if planet_resource.home_planet:
		spawn_home_pad()
	elif planet_resource.refuel_pad:
		spawn_refuel_pad()
	if planet_resource.asteroid_density > 0:
		spawn_asteroids()
	spawn_samples()
	
func setup_planet():
	var planet_mesh_ref = planet_mesh.mesh.duplicate(true)
	var planer_collider_ref = planet_collider.shape.duplicate(true)
	var gravity_field_collider_ref = gavity_field_collider.shape.duplicate(true)
	planet_mesh_ref.radius = planet_resource.radius
	planet_mesh_ref.height = planet_resource.radius * 2
	planer_collider_ref.radius = planet_resource.radius + (planet_resource.radius*0.0005)
	gravity_field_collider_ref.radius = planet_resource.radius * 5
	planet_mesh.mesh = planet_mesh_ref
	planet_collider.shape = planer_collider_ref
	gavity_field_collider.shape = gravity_field_collider_ref

func apply_gravity(body):
	if body.is_in_group("Player") || body.is_in_group("Sample")|| body.is_in_group("Asteroid"):
		body.add_planet(self)
		
func remove_gravity(body):
	if body.is_in_group("Player")|| body.is_in_group("Sample")|| body.is_in_group("Asteroid"):
		body.remove_planet(self)
		
func spawn_refuel_pad():
	var next_refuel_pad = preload("res://Prefabs/refuel_pad.tscn").instantiate()
	refuel_pad.add_child(next_refuel_pad)
	next_refuel_pad.spawn_refuel_pad(planet_resource.radius,false)

func spawn_home_pad():
	var next_refuel_pad = preload("res://Prefabs/refuel_pad.tscn").instantiate()
	refuel_pad.add_child(next_refuel_pad)
	next_refuel_pad.spawn_refuel_pad(planet_resource.radius,true)

func spawn_samples():
	for sample_number in planet_resource.sample_density:
		spawner_pivot.rotation_degrees = Vector3(0,0,randi_range(0,359))
		var next_research_sample = load("res://Prefabs/research_sample.tscn").instantiate()
		interactables_node.add_child(next_research_sample)
		next_research_sample.setup_sample(game_manager.test_sample_resource)
		next_research_sample.global_position = sample_spawner.global_position
	
func spawn_asteroids():
	var asteroid_prefabs := [asteroid1_prefab,asteroid2_prefab,asteroid3_prefab]
	for astroid_number in planet_resource.asteroid_density:
		#hijack sample spawner
		sample_spawner.position = Vector3(0,planet_resource.radius+randi_range(10,planet_resource.radius*4),0)
		spawner_pivot.rotation_degrees = Vector3(0,0,randi_range(0,359))
		var next_asteroid = asteroid_prefabs.pick_random().instantiate()
		hazards_node.add_child(next_asteroid)
		next_asteroid.global_position = sample_spawner.global_position
