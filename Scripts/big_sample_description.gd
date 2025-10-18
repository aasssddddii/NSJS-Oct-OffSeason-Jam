extends ui_sample_description

@onready var big_display_sample = $display_sample



func setup_big_sample(resource:ResearchSampleResource):
	big_display_sample.setup_display_sample(resource,false)
