extends StaticBody3D

func spawn_refuel_pad(radius:int):
	var mesh_instance := $MeshInstance3D
	var collision_shape := $CollisionShape3D
	
	mesh_instance.position = Vector3(0,radius,0)
	collision_shape.position = Vector3(0,radius,0)
	rotation_degrees.z = randi_range(0,259)
	
