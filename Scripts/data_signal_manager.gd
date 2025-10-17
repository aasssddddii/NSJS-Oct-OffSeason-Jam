extends Node3D


func set_signal_strength(level:int):
	for wifi_signaler in get_children():
		var bar_number:= 1
		for wifi_bar in wifi_signaler.get_children():
			if bar_number <= level:
				wifi_bar.visible = true
			else:
				wifi_bar.visible = false
				
			bar_number +=1
