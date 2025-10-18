extends TextureRect
class_name display_sample

const rotation_speed:=.5
var mesh_instance:MeshInstance3D
var sample_resource:ResearchSampleResource

var ui_sample_description

func _process(_delta: float) -> void:
	if mesh_instance:
		mesh_instance.rotation_degrees += Vector3(0,rotation_speed,0)

func setup_display_sample(resource:ResearchSampleResource,from_game:bool):
	if from_game:
		ui_sample_description = $"../../../ui_sample_description"
	else:
		ui_sample_description = $"../../../Panel2/big_sample_description"
		
		
	mesh_instance = $SubViewport/Node3D/MeshInstance3D
	sample_resource = resource
	mesh_instance.mesh = sample_resource.replacement_mesh
	mesh_instance.set_surface_override_material(0,sample_resource.sample_material)
	texture = $SubViewport.get_texture()


func _on_mouse_entered() -> void:
	print("show details: ", sample_resource.sample_description)
	ui_sample_description.setup_sample_description(sample_resource)
	if $"../../../..".name == "Samples_screen":#LAZY kek
		ui_sample_description.setup_big_sample(sample_resource)
	



func _on_mouse_exited() -> void:
	print("hide details: ")
	ui_sample_description.hide_sample_description()
