extends CharacterController
class_name Sample

@export var research_resource:ResearchSampleResource



func setup_sample(sample_resource:ResearchSampleResource):
	var mesh_node = $MeshInstance3D
	var collider_node = $CollisionShape3D
	
	research_resource = sample_resource
	
	mass = research_resource.mass
	collider_node.shape = research_resource.replacement_collider
	mesh_node.mesh = research_resource.replacement_mesh
	mesh_node.set_surface_override_material(0,research_resource.sample_material)
	
