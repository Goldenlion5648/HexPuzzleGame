extends TileMap


var starting_position_to_place_at = Vector2i(0, 0)

var current_blink_state = Globals.TILE_IDS.WHITE

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.cell_in_main_grid_changed.connect(on_tile_placed_in_main_grid)
#just commented this
#	Globals.load_new_level.connect(on_tile_placed_in_main_grid)

func reset_for_new_level():
	var max_possible_to_place = 10
	for i in range(max_possible_to_place):
		var placing_at = starting_position_to_place_at + Vector2i(i, i)
		Globals.clear_pipes(self, placing_at)
		erase_cell(Globals.background_layer, placing_at)
	

func on_tile_placed_in_main_grid():
	Globals.current_hexagon_to_place.set_as_used_up()
	if Globals.available_hexagons.all(func(x): return x.is_used_up()):
		Globals.current_hexagon_to_place = Globals.useless_hexagon
		return
	while Globals.available_hexagons[Globals.current_selected_hexagon_index].is_used_up():
		Globals.current_selected_hexagon_index += 1
		Globals.current_selected_hexagon_index %= Globals.available_hexagons.size()
#	print("ran on_tile_placed_in_main_grid")
#	print(Globals.available_hexagons)
#	print("new selected index ", Globals.current_selected_hexagon_index)

func update_displayed_tile():
#	if Globals.current_hexagon_to_place != null:
#		print(Globals.available_hexagons)
#	if Globals.current_hexagon_to_place == Globals.useless_hexagon:
#		return
	for i in range(Globals.available_hexagons.size()):
		var current = Globals.available_hexagons[i]
		var placing_at = starting_position_to_place_at + Vector2i(i, i)
		if current.is_used_up():
			set_cell(Globals.background_layer, placing_at, 
			Globals.source_id, Globals.BASE_TILE_POS_IN_ATLAS, 
			Globals.TILE_IDS.WALL)
			Globals.clear_pipes(self, placing_at)
		else:
			Globals.clear_pipes(self, placing_at)
			Globals.place_pipes(self, current, placing_at, false)
			set_cell(Globals.background_layer, placing_at, 
			Globals.source_id, Globals.BASE_TILE_POS_IN_ATLAS, 
			current_blink_state if i == Globals.current_selected_hexagon_index 
								else Globals.TILE_IDS.WHITE)



func select_tile():
	var tile = local_to_map(to_local(get_global_mouse_position()))
	if Input.is_action_just_pressed("left_click"):
		var current_alt = get_cell_alternative_tile(Globals.background_layer, tile)
		# when the user clicks outside the grid
		if current_alt == -1:
			return
		print("from display: ", tile)
		Globals.current_selected_hexagon_index = tile.y
		current_blink_state = Globals.TILE_IDS.BRIDGE
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_displayed_tile()
	select_tile()


func _on_blink_timer_timeout():
	if current_blink_state == Globals.TILE_IDS.WHITE:
		current_blink_state = Globals.TILE_IDS.BRIDGE
	else:
		current_blink_state = Globals.TILE_IDS.WHITE
