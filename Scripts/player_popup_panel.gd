extends Panel

@onready var objective1_popup = $objective1
@onready var objective2_popup = $objective2
@onready var tutorial1_popup = $tut1
@onready var tutorial2_popup = $tut2
@onready var tutorial3_popup = $tut3
@onready var tutorial4_popup = $tut4


func setup_objective(number:int):
	modulate.a = 1
	clear_popup_panel()
	#unhide objective
	match number:
		1:
			objective1_popup.visible = true
		2:
			objective2_popup.visible = true
	#show popup panel
	visible = true
	#wait some time
	await get_tree().create_timer(6).timeout
	#hide popup panel
	hide_popup_panel()
	
func setup_tutorial(number:int)->void:
	modulate.a = 1
	clear_popup_panel()
	#unhide tutorial
	match number:
		1:
			tutorial1_popup.visible = true
		2:
			tutorial2_popup.visible = true
		3:
			tutorial3_popup.visible = true
		4:
			tutorial4_popup.visible = true
	#show popup panel
	visible = true
	
func clear_popup_panel()->void:
	for child in get_children():
		child.visible = false
		pass
	
	
func hide_popup_panel()->void:
	#hide popup panelpreferably with alpha fade
	var tweener = create_tween()
	tweener.tween_property(self, "modulate:a", 0.0, .3)
	#clear popup panel
	tweener.finished.connect(clear_popup_panel)
	
