extends TileMap


const label = preload("res://objects/simple_label.tscn")
var alt_to_place = 0
var tile_id_to_place = 0

@onready var CustomHexagon = preload("res://objects/hexagon.gd")
# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.load_new_level.connect(load_hex_grid_for_new_level)
	place_labels_and_initial_tiles()

func place_labels_and_initial_tiles():
	var tile_size = Vector2(101, 88)
	var offset = tile_size / 2.0
	var label_dim = Vector2i(82, 60)
	print(offset)
	for i in range(-Globals.highest_distance_from_center, Globals.highest_distance_from_center + 1):
		for j in range(-Globals.highest_distance_from_center, Globals.highest_distance_from_center + 1):
			if abs(i) + abs(j) <= Globals.highest_distance_from_center :

				var current: Label = label.instantiate()
	#			print("label position ", current.position)
				current.text = "%d %d" % [i, j]
	#			add_sibling.call_deferred(current)
				var white_tile = 2
#				set_cell(Globals.background_layer, Vector2i(i, j), Globals.source_id, 
#							Globals.BASE_TILE_POS_IN_ATLAS, Globals.TILE_IDS.WHITE)
				add_child.call_deferred(current)
				current.set_global_position(to_global(map_to_local(Vector2i(i, j))) + (label_dim ) / 4.0)
			
func load_hex_grid_for_new_level(_args):
	print("about to load from dict")
	load_from_dict(Globals.read_from_level_data(Globals.current_level))

## loads level data from a json (likely loaded from a file)
func load_from_dict(json: Dictionary):
	self.clear_layer(Globals.walkable_tiles_layer)
	self.clear_layer(Globals.background_layer)
#	print(json)
	for key in json:
		var coords = str_to_var("Vector2" + key)
#		print(coords)
		#setup the background
		set_cell(Globals.background_layer, coords, Globals.source_id, 
						Globals.BASE_TILE_POS_IN_ATLAS, Globals.TILE_IDS.WHITE)
		set_cell(Globals.walkable_tiles_layer, coords, Globals.source_id, 
						Globals.BASE_TILE_POS_IN_ATLAS, json[key])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func place_at_clicked_spot():
	var tile = local_to_map(to_local(get_global_mouse_position()))
	
	if Input.is_action_just_pressed("right_click") and Globals.is_in_level_editing_mode:
		erase_cell(Globals.background_layer, tile)
		erase_cell(Globals.walkable_tiles_layer, tile)
		print("erased ", tile)
#	if Input.is_action_just_pressed("save_level"):
#		Globals.save_current_level(self)
	if Input.is_action_just_pressed("load_level"):
#		
		Globals.load_new_level.emit(Globals.get_newest_level())
		print("current hex is ", Globals.current_hexagon_to_place)
		
	if Input.is_action_just_pressed("left_click"):
		print("clicked position was ", tile)
		var current_alt = get_cell_alternative_tile(Globals.background_layer, tile)
		# when the user clicks outside the grid
		print("current_alt ", current_alt)
		if current_alt == -1:
			if Globals.is_in_level_editing_mode:
				set_cell(Globals.background_layer, tile, Globals.source_id, Globals.BASE_TILE_POS_IN_ATLAS, Globals.TILE_IDS.WHITE)
				if Globals.current_level_maker_hex_to_place != Globals.TILE_IDS.WHITE:
					set_cell(Globals.walkable_tiles_layer, tile, Globals.source_id, Globals.BASE_TILE_POS_IN_ATLAS, Globals.current_level_maker_hex_to_place)
			return
		#TODO change this
		print("hex face ", Globals.HEX_FACE)
		var all_face_values : Array = Globals.HEX_FACE.values().duplicate(true)
#		Globals.current_hexagon_to_place = CustomHexagon.new(all_face_values.slice(0, all_face_values.size(), 2), [])
#		Globals.current_hexagon_to_place = CustomHexagon.new([0], [])
		if get_cell_alternative_tile(Globals.walkable_tiles_layer, tile) == Globals.TILE_IDS.WALL or\
		not Globals.current_hexagon_to_place.can_place_here(self, tile):
			print("invalid placement, wall or does not form connection")
			return
		
		# the first parameter is the layer
		# the second is the position
		# change the fourth parameter to change what tile is placed
		place_available_with_animation(tile)
		var had_path = has_path_from_start_to_end()
		print("had path ", had_path)

func place_available_with_animation(tile: Vector2i):
	set_cell(Globals.walkable_tiles_layer, tile, Globals.main_hexagon_sprite_source_id, Globals.BASE_TILE_POS_IN_ATLAS, Globals.TILE_IDS.BRIDGE)
	Globals.place_pipes(self, Globals.current_hexagon_to_place, tile)
	var placed_faces = Globals.current_hexagon_to_place.placeable_against_faces
	Globals.cell_in_main_grid_changed.emit()
	var faces_to_iterate = Globals.HEX_FACE.values()
	while faces_to_iterate[0] not in placed_faces:
		faces_to_iterate = Globals.get_rotated_array(faces_to_iterate, Globals.DIRECTION.RIGHT)
	for face in faces_to_iterate:
		if face in placed_faces:
			continue
		Globals.place_pipes(self, CustomHexagon.new([face]), tile)
		placed_faces.append(face)
		await get_tree().create_timer(0.2).timeout


func has_path_from_start_to_end() -> bool:
	var starting_spots = get_used_cells_by_id(Globals.walkable_tiles_layer, Globals.source_id, Globals.BASE_TILE_POS_IN_ATLAS, Globals.TILE_IDS.START)
	var ending_spots = get_used_cells_by_id(Globals.walkable_tiles_layer, Globals.source_id, Globals.BASE_TILE_POS_IN_ATLAS, Globals.TILE_IDS.GOAL)
	for possible_starting_spot in starting_spots:
		for possible_ending_spot in ending_spots:
			if dfs(possible_starting_spot, possible_ending_spot):
				return true
	return false
	
	
## returns true if there is a path from "from" -> "to"
## false otherwise
func dfs(from: Vector2i, to: Vector2i):
#	print("from ", from, " to ", to)
	var fringe = Globals.get_walkable_around_coords(self, from)
#	print("starting fringe ", fringe)
	if from == to:
		return true
	var cur = null
	var seen = {}
	while fringe.size() > 0:
		cur = fringe.pop_back()
#		print("cur ", cur)
		print("fringe, ", fringe)
		if cur in seen:
			continue
		seen[cur] = true
		if cur == to:
			return true
		fringe.append_array(Globals.get_walkable_around_coords(self, cur))
	return false
		

func _process(delta):
	pass
func _unhandled_input(event: InputEvent):
	place_at_clicked_spot()
	
