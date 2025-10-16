extends CharacterController

var first_planet:Planet
var clockwise := true 
var use_circular_speed := true   
var initial_speed_override := 10.0 

func _ready() -> void:
	planet_added.connect(orbit_this_planet)


func _process(_delta: float) -> void:
	if first_planet != null:
		orbit_radius = (global_position - first_planet.global_position).length()
		
		var to_ship := global_position - first_planet.global_position
		var r_xy := Vector2(to_ship.x, to_ship.y)
		var r := r_xy.length()
		if r == 0.0:
			return
		var radial_xy := r_xy / r
		var tangent_xy := Vector2(-radial_xy.y, radial_xy.x)  
		if clockwise:
			tangent_xy = -tangent_xy
		#set speed
		var speed := randf_range(4,18)
		if speed <= 0.0 and use_circular_speed:
			var GM := first_planet.planet_resource.gravity_strength * first_planet.planet_resource.mass
			var g_here := GM / r
			speed = sqrt(max(0.0, g_here * r))  
			
		if speed <= 0.0:
			speed = 10.0  
		var v_xy := tangent_xy * speed
		linear_velocity = Vector3(v_xy.x, v_xy.y, linear_velocity.z)
	
func orbit_this_planet(planet:Planet):
	if first_planet == null:
		apply_force(Vector3())
		orbit_planet = planet
		orbital_lock = true
		first_planet = planet
		var choices := [true,false]
		clockwise = choices.pick_random()
		
		
		#linear_velocity = Vector3(v_xy.x, v_xy.y, linear_velocity.z)
