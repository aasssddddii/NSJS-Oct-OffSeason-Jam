extends TextureRect
class_name ui_sample_description

var game_manager = GameManager

var sample_resource:ResearchSampleResource
@onready var ui_name = $HBoxContainer/RightContainer/ui_name
@onready var ui_description = $HBoxContainer/RightContainer/ui_description
var ui_satus
func setup_sample_description(resource:ResearchSampleResource):
	sample_resource = resource
	ui_name.text = sample_resource.sample_name
	ui_description.text = sample_resource.sample_description
	
	if get_parent().name == "Panel2":#LAZY
		ui_satus = $HBoxContainer/RightContainer/ui_status
		var collected_text:String
		if game_manager.player_resource.home_samples.has(resource):
			collected_text = "Retrieved"
		else:
			collected_text = "Lost in Space"
			
		ui_satus.text = collected_text
	
	
	visible = true

func hide_sample_description():
	visible = false
