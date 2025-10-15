extends CharacterController

const stage_2_duration:=1
const stage_2_timeout:=2
const thruster_fuel_burn:=.01
const refuel_speed:=.05
var time_since_stage_2:float
var time_in_stage_2:float
var can_stage_2:bool
var in_stage_2:bool
var planet_connected:bool

@onready var arrow_prefab = preload("res://Prefabs/gravity_arrow.tscn")
var arrow_pivot

var closest_planet:Planet
var distance_to_closest:float = 92233720368

var player_resource = load("res://Resources/PlayerResource.tres")
@onready var player_cam = $"../Camera3D"

var on_fuel:bool
@onready var refuel_prob = $refuel_prob


func _ready() -> void:
	#setup camera dynamically
	player_cam.target = self
	body_entered.connect(collision_handler)
	body_exited.connect(planet_disconnecter)
	refuel_prob.body_entered.connect(refuelable_source)
	refuel_prob.body_exited.connect(off_refuelable_source)
	arrow_pivot = arrow_prefab.instantiate()
	get_parent_node_3d().add_child.call_deferred(arrow_pivot)
	arrow_pivot.setup_arrow(self)
	

func _process(delta: float) -> void:
	#checking for closest planet
	for planet in planets:
		if global_position.distance_to(planet.global_position) < distance_to_closest:
			closest_planet = planet
			distance_to_closest = global_position.distance_to(planet.global_position)
	if !planets.is_empty():
		var rotation_rad = Vector2(closest_planet.global_position.x,closest_planet.global_position.y).angle_to_point(Vector2(global_position.x,global_position.y))
		#print("looking at: ", rad_to_deg(rotation_rad)+90)
		arrow_pivot.rotation_degrees.z = rad_to_deg(rotation_rad)+90
		arrow_pivot.visible = true
	else:
		arrow_pivot.visible = false
	distance_to_closest = 92233720368
	#stage 2 boosters
	if in_stage_2:
		if time_in_stage_2 > stage_2_duration:
			in_stage_2 = false
		else:
			time_in_stage_2 += delta
			print("i am stage 2 ing")
	player_cam.ui_fuel.text = var_to_str(int(player_resource.fuel))
	#refueling
	if on_fuel:
		refuel(refuel_speed)

func process_movement(state: PhysicsDirectBodyState3D) -> void:
	if player_resource.fuel > 0:
		rotation_dir = Input.get_axis("player_left","player_right")
		#print("rotation direction: ", rotation_dir)
		current_thrust = Vector3.ZERO
		if Input.is_action_pressed("player_thruster"):
			current_thrust = global_transform.basis.y * boost_power
			reduce_fuel(thruster_fuel_burn)
		if Input.is_action_just_pressed("stage_2"):
			#do stage 2 booster
			if can_stage_2:
				in_stage_2 = true
				time_in_stage_2 = 0
			else:
				print("no booosto :'(")
			#print("BOOOSTO!!!!: ")
			#can_stage_2 = false
		if in_stage_2:
			current_thrust = global_transform.basis.y * boost_power * 2
			
		if Input.is_action_pressed("player_brakes"):
			current_thrust = Vector3.ZERO
			state.linear_velocity -= linear_velocity/break_power
			if state.linear_velocity > Vector3.ZERO:
				reduce_fuel(thruster_fuel_burn/2)
		
		if rotation_dir != 0:
			apply_torque(Vector3(0,0,-rotation_dir * rotate_power))
		apply_force(current_thrust)
		#constant_force = current_thrust

func reduce_fuel(amount):
	player_resource.fuel -= amount

func refuel(amount):
	if player_resource.fuel < player_resource.max_fuel:
		player_resource.fuel += amount

func collision_handler(body:PhysicsBody3D):
	if body.is_in_group("Planet"):
		can_stage_2 = true
		planet_connected = true
		print("body: ",body)

func planet_disconnecter(body:PhysicsBody3D):
	if body.is_in_group("Planet"):
		planet_connected = false
		can_stage_2 = false
		
func refuelable_source(body:PhysicsBody3D):
	if body.is_in_group("Refuel"):
		on_fuel = true
		print("player on fuel source: ", on_fuel)
		
func off_refuelable_source(body:PhysicsBody3D):
	if body.is_in_group("Refuel"):
		on_fuel = false
		print("player on fuel source: ", on_fuel)
