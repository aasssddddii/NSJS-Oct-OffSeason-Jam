extends CharacterController

const stage_2_duration:=1
const stage_2_timeout:=5
const thruster_fuel_burn:=.0001
const refuel_speed:=.002
const heal_speed:=.006
const too_fast := Vector2(1.4,1.4)
const velocity_dmg_mod:=50
const fire_spin_speed:= 3
const default_download_speed:=.0002
var time_since_stage_2:float
var time_in_stage_2:float
var can_stage_2:bool
var in_stage_2:bool
var planet_connected:bool
const damage_timeout:float = 2.5
var time_since_last_collision:float

@onready var arrow_prefab = preload("res://Prefabs/gravity_arrow.tscn")
var arrow_pivot

var closest_planet:Planet
var distance_to_closest:float = 92233720368

#var game_manager.player_resource = load("res://Resources/PlayerResource.tres")
@onready var player_cam = $"../Camera3D"

var on_fuel:bool
@onready var refuel_prob = $refuel_prob
@onready var sample_range_area = $sample_range
@onready var sample_probe = $sample_probe

@onready var player_animator = $"sat1/AnimationPlayer"

var arrow_shaft
var first_contact:= true
var last_planet_on:Planet

var can_end_game:bool# = true

@onready var fire_node = $Fire
@onready var player_fire = $Fire/muzzlefire
@onready var fire_emiition = $Fire/GPUParticles3D

@onready var air_brake_parent = $Air_brakes
@onready var data_signal = $"Data signal"
var wifi_level:int

var sample_in_range:bool
var mouth_open:bool

func _ready() -> void:
	#game_manager.player_node = self
	#setup camera dynamically
	player_cam.target = self
	
	
	body_entered.connect(collision_handler)
	refuel_prob.body_entered.connect(refuelable_source)
	refuel_prob.body_exited.connect(off_refuelable_source)
	sample_probe.body_entered.connect(collect_sample)
	sample_range_area.body_entered.connect(open_mouth)
	sample_range_area.body_exited.connect(close_mouth)
	arrow_pivot = arrow_prefab.instantiate()
	get_parent_node_3d().add_child.call_deferred(arrow_pivot)
	arrow_pivot.setup_arrow(self)
	arrow_shaft = arrow_pivot.get_child(0)
	


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
			reduce_fuel(thruster_fuel_burn*20)
			print("i am stage 2 ing")
	else:
		if time_since_stage_2 > stage_2_timeout:
			can_stage_2 = true
		else:
			time_since_stage_2 += delta
	#damage cooldown
	time_since_last_collision += delta
	if time_since_last_collision > damage_timeout:
		if last_planet_on != null:
			last_planet_on = null
		if first_contact != true:
			#print("player can now be damaged")
			first_contact = true
	update_ui()
	#refueling
	if on_fuel:
		refuel(refuel_speed)
		heal(heal_speed)
		
	arrow_shaft.visible = orbital_lock
	if player_fire.visible:
		fire_node.rotation_degrees += Vector3(0,fire_spin_speed,0)
		
	#Data Download Visual handler
	if closest_planet != null and game_manager.game_on:
		#print("checking download radius: ", closest_planet.planet_resource.download_radius)
		if !closest_planet.planet_resource.home_planet:
			#check for sweet spot range
			if abs(global_position.distance_to(closest_planet.global_position) - closest_planet.planet_resource.download_radius) <= 3:
				wifi_level = 3
			elif abs(global_position.distance_to(closest_planet.global_position) - closest_planet.planet_resource.download_radius) <= 13:
				wifi_level = 2
			elif abs(global_position.distance_to(closest_planet.global_position) - closest_planet.planet_resource.download_radius) <= 20:
				wifi_level = 1
			
			#Display wiFi accordingly
			display_wifi(wifi_level)
	elif closest_planet == null:
		wifi_level = 0

func display_wifi(level:int)->void:
	data_signal.set_signal_strength(level)
		
func update_ui():
	player_cam.ui_fuel_bar.value = game_manager.player_resource.fuel
	player_cam.ui_health_bar.value = game_manager.player_resource.health
	player_cam.ui_stage_2_cooldown_bar.value = (time_since_stage_2/stage_2_timeout)
	player_cam.ui_data_bar.value = game_manager.player_resource.data_downloaded
	player_cam.ui_player_samples.text = var_to_str(game_manager.player_resource.samples.size()) + " / 5 stored"
	

func process_movement(state: PhysicsDirectBodyState3D) -> void:
	if game_manager.player_resource.fuel > 0 and game_manager.game_on:
		rotation_dir = Input.get_axis("player_left","player_right")
		#print("rotation direction: ", rotation_dir)
		current_thrust = Vector3.ZERO
		#in orbital Lock
		if Input.is_action_pressed("orbital_lock"):
			if closest_planet != null:
				#check if planet has data left to download
				#check if in planets sweet spot for downloads
				#print("distance to closest: ",global_position.distance_to(closest_planet.global_position))
				if global_position.distance_to(closest_planet.global_position) > closest_planet.planet_resource.radius+5:
					orbit_planet = closest_planet
					orbital_lock = true
					#check if planet has data left to download
					#check if in planets sweet spot for downloads
					if closest_planet.planet_resource.orbital_data > 0 and wifi_level > 0:
						var download_speed:= default_download_speed * wifi_level
						closest_planet.planet_resource.orbital_data -= download_speed
						game_manager.player_resource.data_downloaded += download_speed
						print("data downloaded: ", game_manager.player_resource.data_downloaded)
					
		if !Input.is_action_pressed("orbital_lock"):
			orbit_planet = null
			closest_planet = null
			orbital_lock = false
		if Input.is_action_pressed("player_thruster") and !in_stage_2:
			current_thrust = global_transform.basis.y * boost_power
			reduce_fuel(thruster_fuel_burn)
			show_player_fire(true)			
		if Input.is_action_just_pressed("stage_2"):
			#do stage 2 booster
			if can_stage_2:
				can_stage_2 = false
				in_stage_2 = true
				time_in_stage_2 = 0
				time_since_stage_2 = 0
			else:
				print("no booosto :'(")
		if in_stage_2:
			current_thrust = global_transform.basis.y * boost_power * 2
			
		if Input.is_action_pressed("player_brakes"):
			current_thrust = Vector3.ZERO
			state.linear_velocity -= linear_velocity/break_power
			reduce_fuel(thruster_fuel_burn/1.5)
			show_air_brakes(true)
		
		if rotation_dir != 0:
			apply_torque(Vector3(0,0,-rotation_dir * rotate_power))
			
			
			
			
			
		apply_central_force(current_thrust)
		#turn off visuals
		if Input.is_action_just_released("player_thruster"):
			show_player_fire(false) 
		if Input.is_action_just_released("player_brakes"):
			show_air_brakes(false)
	elif game_manager.player_resource.fuel <= 0:
		show_air_brakes(false)
		show_player_fire(false)
		end_game(false)
		

func reduce_fuel(amount):
	game_manager.player_resource.fuel -= amount

func refuel(amount):
	if game_manager.player_resource.fuel < game_manager.player_resource.max_fuel:
		game_manager.player_resource.fuel += amount
		
func heal(amount):
	if game_manager.player_resource.health < game_manager.player_resource.max_health:
		game_manager.player_resource.health += amount

func damage_player(amount):
	if game_manager.player_resource.health-amount > 0:
		game_manager.player_resource.health -= amount
	else:
		#end game
		end_game(false)
		print("player Loss")
		

func end_game(win:bool):
	if game_manager.game_on:
		game_manager.from_game = true
		game_manager.game_on = false
		player_cam.open_end(win)
		player_cam.reset_camera()

func collision_handler(body:PhysicsBody3D):
	time_since_last_collision = 0
	if body.is_in_group("Planet") and first_contact:
		last_planet_on = body
		first_contact = false
		var velocity_x :float= abs(linear_velocity.x)
		var velocity_y :float= abs(linear_velocity.y)
		print("Hit planet: ",body.name," speed: ", linear_velocity)
		if velocity_x  > too_fast.x or velocity_y > too_fast.y:
			var damage_amount:float
			if velocity_x > velocity_y:
				damage_amount = (abs(velocity_x) / 100)*2
			else:
				damage_amount = (abs(velocity_y) / 100)*2
			
			print("Hit planet Too Fast : ",body.name," speed: ", linear_velocity, " taking damage: ",String.num(damage_amount,2))
			damage_player(damage_amount)
	if body.is_in_group("Asteroid") and first_contact:
		first_contact = false
		var damage_amount:float
		var velocity_x :float= abs(body.linear_velocity.x)
		var velocity_y :float= abs(body.linear_velocity.y)
		
		if velocity_x > velocity_y:
			damage_amount = velocity_x / velocity_dmg_mod
		else:
			damage_amount = velocity_y / velocity_dmg_mod
		damage_player(damage_amount)
		print("hit asteroid with speed: ", body.linear_velocity, " taking damage: ",String.num(damage_amount,2))
	
	elif can_end_game and body.is_in_group("Planet"):
		if body.planet_resource.home_planet:
			print("END THE GAME, PLAYER WIN")
			end_game(true)
			
	elif can_end_game and body.is_in_group("Refuel"):
		if body.is_home_pad:
			print("END THE GAME, PLAYER WIN")
			end_game(true)
#func last_planet_resetter(body:PhysicsBody3D):
	#if body.is_in_group("Planet"):
		#if body == last_planet_on:
			#
			#last_planet_on = null
		
func refuelable_source(body:PhysicsBody3D):
	if body.is_in_group("Refuel"):
		on_fuel = true
		#print("player on fuel source: ", on_fuel)
		
func off_refuelable_source(body:PhysicsBody3D):
	if body.is_in_group("Refuel"):
		on_fuel = false
		#print("player on fuel source: ", on_fuel)
		
		
func collect_sample(body:PhysicsBody3D):
	if body.is_in_group("Sample"):
		if sample_range_area.get_overlapping_bodies().filter(func(cheking_body): return cheking_body is Sample).size() <2:
			sample_in_range = false
			sample_checker()
		game_manager.player_resource.samples.append(body.research_resource)
		print("sample collected player now has samples: ", game_manager.player_resource.samples)
		body.queue_free()
		if game_manager.player_resource.samples.size() >= game_manager.samples_needed:
			can_end_game = true



func open_mouth(body):
	
	if body.is_in_group("Sample"):
		sample_in_range = true
		sample_checker()
func close_mouth(body):
	if body.is_in_group("Sample"):
		print("samples left in range: ", sample_range_area.get_overlapping_bodies().filter(func(cheking_body): return cheking_body is Sample).size())
		if sample_range_area.get_overlapping_bodies().filter(func(cheking_body): return cheking_body is Sample).size() <2:
			sample_in_range = false
			sample_checker()

func sample_checker():
	if sample_in_range:
		if !mouth_open:
			if !player_animator.is_playing():
				player_animator.play("open_mouth")
			mouth_open = true
	else:
		if mouth_open:
			if !player_animator.is_playing():
				player_animator.play("close_mouth")
			mouth_open = false
		

	
# Delete after testing VVVVV
#var test_toggler:bool = true
#func _unhandled_input(e):
	#if e.is_action_pressed("ui_accept"):
		#end_game()
func reset_player():
	get_tree().reload_current_scene()

func show_player_fire(choice:bool)->void:
	player_fire.visible = choice
	fire_emiition.emitting = choice
	
func show_air_brakes(choice:bool)->void:
	for air_brake_emitter in air_brake_parent.get_children():
		air_brake_emitter.get_child(0).emitting = choice
	
