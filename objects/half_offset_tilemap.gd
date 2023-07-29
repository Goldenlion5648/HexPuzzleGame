extends TileMap


const label = preload("res://objects/simple_label.tscn")
var alt_to_place = 0
var tile_id_to_place = 0

@onready var CustomHexagon = preload("res://objects/hexagon.gd")
# Called when the node enters the scene tree for the first time.
func _ready():
	place_labels()

	pass # Replace with function body.

func save_current_level():
	var level_data_file_only = "level_data.json"
	var current_folder = null
	var current_path = ""
	for i in range(10):
		current_folder = "res://levels/level%02d" % i
		print("folder top is ", current_folder)
		current_path = "%s/%s" % [current_folder, level_data_file_only]
		print("current_path ", current_path)
		if FileAccess.file_exists(current_path):
			continue
		break
	assert(not FileAccess.file_exists(current_path))
	DirAccess.make_dir_absolute(current_folder)
	var file_writer = FileAccess.open(current_path, FileAccess.WRITE)
	print("current file ", file_writer)
	
	print("folder is ", current_folder)
	print("file to write outside is ", file_writer)
	var tile_to_alt_id = {}
	for i in range(-Globals.highest_distance_from_center, Globals.highest_distance_from_center + 1):
		for j in range(-Globals.highest_distance_from_center, Globals.highest_distance_from_center + 1):
			tile_to_alt_id[Vector2i(i, j)] = get_cell_alternative_tile(Globals.layer_to_place_on, Vector2i(i, j)) 
	var sorted_version = {}
	var sorted_keys = tile_to_alt_id.keys()
	print(sorted_keys)
	sorted_keys.sort_custom(func(a, b): return tile_to_alt_id[a] > tile_to_alt_id[b])
	print(sorted_keys)
#	return
	for key in sorted_keys:
		sorted_version[key] = tile_to_alt_id[key]
	print(sorted_version)
	var json_version = JSON.stringify(sorted_version, "    ", false)
	file_writer.store_line(json_version)
	var image = get_viewport().get_texture().get_image()
	image.save_png("%s/preview.png" % current_folder)
	

func place_labels():
	var tile_size = Vector2(101, 88)
	var offset = tile_size / 3.0
	print(offset)
	for i in range(-Globals.highest_distance_from_center, Globals.highest_distance_from_center + 1):
		for j in range(-Globals.highest_distance_from_center, Globals.highest_distance_from_center + 1):
			if abs(i + j) >= Globals.highest_distance_from_center + 1:
				continue
			var current: Label = label.instantiate()
			current.set_global_position(to_global(map_to_local(Vector2i(i, j))) - offset)
#			print("label position ", current.position)
			current.text = "%d %d" % [i, j]
#			add_sibling.call_deferred(current)
			var white_tile = 2
			set_cell(Globals.background_layer, Vector2i(i, j), 1, Vector2i(white_tile, 0), alt_to_place)
			add_child.call_deferred(current)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func place_at_clicked_spot():
	var erase_mode = false
	if Input.is_action_pressed("shift"):
		erase_mode = true
	
	var tile = local_to_map(to_local(get_global_mouse_position()))
	
	if Input.is_action_just_pressed("right_click"):
		erase_cell(0, tile)
	if Input.is_action_just_pressed("save_level"):
		save_current_level()
		
	if Input.is_action_just_pressed("left_click"):
		print("clicked position was ", tile)
		print(tile)
		var current_alt = get_cell_alternative_tile(Globals.background_layer, tile)
		print("clicked on a tile with alt ", current_alt)
		# outside of grid
		if current_alt == -1:
			return
		#TODO change this
		var current_hexagon_to_place = CustomHexagon.new([Globals.HEX_FACE.BOTTOM_FACE], [])
		if current_hexagon_to_place.can_place_here(self, tile) == false:
			return
		
		# the first parameter is the layer
		# the second is the position
		# change the fourth parameter to change what tile is placed
		set_cell(Globals.layer_to_place_on, tile, 1, Globals.BASE_TILE_POS, Globals.TILE_IDS.BRIDGE)
		
		var had_path = dfs(Vector2i(0, 0), Vector2i(1, -3))
		print("had path ", had_path)
#
#		print("above are", Globals.get_tile_offsets_in_direction(Globals.DIRECTION.ABOVE))
#		print("right are", Globals.get_tile_offsets_in_direction(Globals.DIRECTION.RIGHT))
#		print("down are", Globals.get_tile_offsets_in_direction(Globals.DIRECTION.DOWN))
#		print("left are", Globals.get_tile_offsets_in_direction(Globals.DIRECTION.LEFT))


	
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
