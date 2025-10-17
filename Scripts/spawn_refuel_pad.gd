extends StaticBody3D

var is_home_pad:bool

func spawn_refuel_pad(radius:int,is_home:bool):
	var mesh_instance := $MeshInstance3D
	var collision_shape := $CollisionShape3D
	var gpu_collider := $GPUParticlesCollisionBox3D
	
	mesh_instance.position = Vector3(0,radius,0)
	collision_shape.position = Vector3(0,radius,0)
	gpu_collider.position = Vector3(0,radius,0)
	is_home_pad = is_home
	if !is_home:
		rotation_degrees.z = randi_range(0,359)
	
