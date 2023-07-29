extends CanvasGroup

var saved_hexes: Array[String] = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_add_to_options_button_pressed():
	print("pressed add to options")
	var buttons : Array[CheckButton]
	buttons.assign(get_children().filter(func(x): return x is CheckButton))
	var exposed_faces: Array[int] = []
	for i in range(buttons.size()):
#		buttons[i].has_focus()
		print(buttons[i].button_pressed)
		if buttons[i].button_pressed:
			print("appeneded ", i)
			exposed_faces.append(i)
	print("exposed_faces ", exposed_faces)
	saved_hexes.append(Globals.array_to_string(exposed_faces))
	

func _on_save_level_button_pressed():
	Globals.save_current_level($"../gridHolder/half_offset_tile_map2", saved_hexes)


func _on_reset_button_pressed():
	pass # Replace with function body.
