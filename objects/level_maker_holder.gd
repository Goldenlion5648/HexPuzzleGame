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
#		print(buttons[i].button_pressed)
		if buttons[i].button_pressed:
#			print("appeneded ", i)
			exposed_faces.append(i)
#	print("exposed_faces ", exposed_faces)
	saved_hexes.append(Globals.array_to_string(exposed_faces))
	

func _on_save_level_button_pressed():
	Globals.save_current_level($"../gridHolder/half_offset_tile_map2", saved_hexes)


func _on_reset_button_pressed():
	get_tree().reload_current_scene()
	var level_editing_dummy_level = 999
	Globals.load_new_level.emit(level_editing_dummy_level)


func _on_debug_enable_checkbox_pressed():
	get_viewport().set_input_as_handled()
	print("editing mode: ", Globals.is_in_level_editing_mode )
#	await get_tree().create_timer(1.0).timeout
	Globals.is_in_level_editing_mode = $debug_enable_checkbox.button_pressed
	print("editing mode: ", Globals.is_in_level_editing_mode )


func _on_currently_placing_options_item_selected(index):
	var current = $currently_placing_options.get_item_text(index)
	Globals.current_level_maker_hex_to_place = Globals.TILE_IDS[current]
