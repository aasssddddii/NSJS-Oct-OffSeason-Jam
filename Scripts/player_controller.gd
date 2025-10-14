extends CharacterController

const stage_2_duration:=1
const stage_2_timeout:=2
var time_since_stage_2:float
var time_in_stage_2:float
var can_stage_2:bool
var in_stage_2:bool
var planet_connected:bool

@onready var arrow_prefab = preload("res://Prefabs/gravity_arrow.tscn")
var arrow_pivot


func _ready() -> void:#setup camera dynamically
	body_entered.connect(collision_handler)
	body_exited.connect(planet_disconnecter)
	arrow_pivot = arrow_prefab.instantiate()
	get_parent_node_3d().add_child.call_deferred(arrow_pivot)
	arrow_pivot.setup_arrow(self)
	

func _process(delta: float) -> void:
	if in_stage_2:
		#doubleboosting
		if time_in_stage_2 > stage_2_duration:
			in_stage_2 = false
		else:
			time_in_stage_2 += delta
			print("i am stage 2 ing")

func process_movement(state: PhysicsDirectBodyState3D) -> void:
	if gravity_force != Vector3.ZERO:
		var rotation_rad = Vector2(gravity_force.x,gravity_force.y).angle()
		print("looking at: ", rad_to_deg(rotation_rad))
		arrow_pivot.rotation_degrees.x = rad_to_deg(rotation_rad)
		arrow_pivot.visible = true
	else:
		#arrow_pivot.visible = false
		pass
		
	rotation_dir = Input.get_axis("player_left","player_right")
	#print("rotation direction: ", rotation_dir)
	current_thrust = Vector3.ZERO
	if Input.is_action_pressed("player_thruster"):
		current_thrust = global_transform.basis.y * boost_power
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
		
	
	if rotation_dir != 0:
		apply_torque(Vector3(0,0,-rotation_dir * rotate_power))
	apply_force(current_thrust)
	#constant_force = current_thrust

func collision_handler(body:PhysicsBody3D):
	if body.is_in_group("Planet"):
		can_stage_2 = true
		planet_connected = true
		print("body: ",body)

func planet_disconnecter(body:PhysicsBody3D):
	if body.is_in_group("Planet"):
		planet_connected = false
		can_stage_2 = false
