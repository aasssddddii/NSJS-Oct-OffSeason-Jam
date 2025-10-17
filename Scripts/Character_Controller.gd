extends RigidBody3D
class_name CharacterController

var game_manager = GameManager

#planets gravity in range
var planets:Array[Planet]
var gravity_force := Vector3.ZERO

signal planet_added(body)

var rotation_dir
var current_thrust

const rotate_power:int = 10
const boost_power = 20
const break_power = 50 #higher number = longer slowdown time

var orbital_lock:bool
var orbit_planet:Planet
var orbit_radius:float
var orbit_kp:= 6.0
var orbit_kd:= 3.0
var keep_circular_speed := true
var speed_blend := 0.15



func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	gravity_force = Vector3.ZERO
	for planet in planets:
		var direction = global_position - planet.global_position
		var distance = direction.length()
		if distance > 0: 
			var gravity_constant = planet.planet_resource.gravity_strength 
			var gravity_amount = (gravity_constant * planet.planet_resource.mass) / distance
			gravity_force += direction.normalized() * gravity_amount
	
	process_movement(state)
	
	if orbital_lock and is_instance_valid(orbit_planet):
		var to_ship_xy := Vector2(global_position.x - orbit_planet.global_position.x,
								  global_position.y - orbit_planet.global_position.y)
		var orbit_r := to_ship_xy.length()
		if orbit_r > 0:
			var radial_out_xy := to_ship_xy / orbit_r
			var velocity := state.linear_velocity
			var v_xy := Vector2(velocity.x, velocity.y)
			var speed_before := v_xy.length()
			var v_rad := v_xy.dot(radial_out_xy)
			var v_tan_xy := v_xy - radial_out_xy * v_rad
			#if self.is_in_group("Asteroid"):
				#print("speed before : ",speed_before)
			v_xy -= radial_out_xy * v_rad
			var t_dir_xy := v_tan_xy.normalized() 
			v_xy = t_dir_xy * speed_before
			if keep_circular_speed:
				var GM = orbit_planet.planet_resource.gravity_strength * orbit_planet.planet_resource.mass
				var g_here = GM / orbit_r
				var v_circ = sqrt(max(0.0, g_here * orbit_r))
				var target_speed = max(speed_before, v_circ)
				var new_speed = lerp(speed_before, target_speed, speed_blend)
				v_xy = t_dir_xy * new_speed
			var new_v := Vector3(v_xy.x, v_xy.y, velocity.z - gravity_force.z)
			var tiny := Vector2(new_v.x, new_v.y).dot(radial_out_xy)
			if abs(tiny) > 1e-6:
				var corrected_xy := Vector2(new_v.x, new_v.y) - radial_out_xy * tiny
				new_v.x = corrected_xy.x
				new_v.y = corrected_xy.y
			state.linear_velocity = new_v
			return
			
			
	state.linear_velocity -= gravity_force
	
	wrap_position()
	
	
func wrap_position():
	var pos := global_position
	var wrapped := false

	if pos.x > game_manager.world_half_size_x:
		pos.x = -game_manager.world_half_size_x
		wrapped = true
	elif pos.x < -game_manager.world_half_size_x:
		pos.x = game_manager.world_half_size_x
		wrapped = true

	if pos.y > game_manager.world_half_size_y:
		pos.y = -game_manager.world_half_size_y
		wrapped = true
	elif pos.y < -game_manager.world_half_size_y:
		pos.y = game_manager.world_half_size_y
		wrapped = true
	if wrapped:
		global_position = pos
func process_movement(_state: PhysicsDirectBodyState3D) -> void:
	pass
	
func add_planet(planet:Planet):
	planets.append(planet)
	planet_added.emit(planet)
	
func remove_planet(planet:Planet):
	planets.remove_at(planets.find(planet))
	
