extends RigidBody3D
class_name CharacterController

#planets gravity in range
var planets:Array[Planet]
var gravity_force := Vector3.ZERO

var rotation_dir
var current_thrust

const rotate_power:int = 10
const boost_power = 20
const break_power = 50 #higher number = longer slowdown time

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	gravity_force = Vector3.ZERO
	for planet in planets:
		var direction = global_position - planet.global_position
		var distance = direction.length()
		if distance > 0: 
			var gravity_constant = planet.planet_resource.gravity_strength 
			var gravity_amount = (gravity_constant * planet.planet_resource.mass) / distance
			gravity_force += direction.normalized() * gravity_amount
	# Apply gravity to velocity
	state.linear_velocity -= gravity_force
	
	process_movement(state)
	
	
	
func process_movement(_state: PhysicsDirectBodyState3D) -> void:
	pass
	
func add_planet(planet:Planet):
	planets.append(planet)
	
func remove_planet(planet:Planet):
	planets.remove_at(planets.find(planet))
