extends TextureRect

var sample_resource:ResearchSampleResource
@onready var ui_name = $HBoxContainer/RightContainer/ui_name
@onready var ui_description = $HBoxContainer/RightContainer/ui_description

func setup_sample_description(resource:ResearchSampleResource):
	sample_resource = resource
	
	ui_name.text = sample_resource.sample_name
	ui_description.text = sample_resource.sample_description
	
	visible = true

func hide_sample_description():
	visible = false
