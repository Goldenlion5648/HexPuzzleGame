extends TileMap


const label = preload("res://objects/simple_label.tscn")
var alt_to_place = 0
var tile_id_to_place = 0

@onready var CustomHexagon = preload("res://objects/hexagon.gd")
# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.load_new_level.connect(load_hex_grid_for_new_level)
	place_labels()
	pass # Replace with function body.

func place_labels():
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
				set_cell(Globals.background_layer, Vector2i(i, j), Globals.source_id, 
							Globals.BASE_TILE_POS_IN_ATLAS, Globals.TILE_IDS.WHITE)
				add_child.call_deferred(current)
				current.set_global_position(to_global(map_to_local(Vector2i(i, j))) + (label_dim ) / 4.0)
			
func load_hex_grid_for_new_level(_args):
	print("about to load from dict")
	load_from_dict(Globals.read_from_level_data(Globals.current_level))

## loads level data from a json (likely loaded from a file)
func load_from_dict(json: Dictionary):
	self.clear_layer(Globals.layer_to_place_on)
	self.clear_layer(Globals.background_layer)
#	print(json)
	for key in json:
		var coords = str_to_var("Vector2" + key)
#		print(coords)
		#setup the background
		set_cell(Globals.background_layer, coords, Globals.source_id, 
						Globals.BASE_TILE_POS_IN_ATLAS, Globals.TILE_IDS.WHITE)
		set_cell(Globals.layer_to_place_on, coords, Globals.source_id, 
						Globals.BASE_TILE_POS_IN_ATLAS, json[key])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func place_at_clicked_spot():
	var erase_mode = false
	if Input.is_action_pressed("shift"):
		erase_mode = true
	
	var tile = local_to_map(to_local(get_global_mouse_position()))
	
	if Input.is_action_just_pressed("right_click"):
		erase_cell(Globals.background_layer, tile)
#	if Input.is_action_just_pressed("save_level"):
#		Globals.save_current_level(self, )
	if Input.is_action_just_pressed("load_level"):
#		
		Globals.load_new_level.emit(8)
		print("current hex is ", Globals.current_hexagon_to_place)
		
	if Input.is_action_just_pressed("left_click"):
		print("clicked position was ", tile)
		var current_alt = get_cell_alternative_tile(Globals.background_layer, tile)
		# when the user clicks outside the grid
		if current_alt == -1:
			return
		#TODO change this
		print("hex face ", Globals.HEX_FACE)
		var all_face_values : Array = Globals.HEX_FACE.values().duplicate(true)
#		Globals.current_hexagon_to_place = CustomHexagon.new(all_face_values.slice(0, all_face_values.size(), 2), [])
#		Globals.current_hexagon_to_place = CustomHexagon.new([0], [])
		if not Globals.current_hexagon_to_place.can_place_here(self, tile):
			print("invalid placement, does not form connection")
			return
		
		# the first parameter is the layer
		# the second is the position
		# change the fourth parameter to change what tile is placed
		set_cell(Globals.layer_to_place_on, tile, Globals.main_hexagon_sprite_source_id, Globals.BASE_TILE_POS_IN_ATLAS, Globals.TILE_IDS.BRIDGE)
		Globals.place_pipes(self, Globals.current_hexagon_to_place, tile)
		Globals.cell_in_main_grid_changed.emit()
		var had_path = dfs(Vector2i(0, 0), Vector2i(1, -3))
		print("had path ", had_path)

	
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
#		print("fringe, ", fringe)
		if cur in seen:
			continue
		seen[cur] = true
		if cur == to:
			return true
		fringe.append_array(Globals.get_walkable_around_coords(self, cur))
	return false
		

func _process(delta):
	place_at_clicked_spot()
