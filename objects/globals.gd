extends Node

signal rotate_right
signal load_new_level
signal cell_in_main_grid_changed

var current_grid_rotation = 0
var rotation_increment = 60
var adj6_flat_top = [Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0)]
var adj6_corner_top = [Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0)]

const flat_top_frequency = 60
enum DIRECTION {ABOVE=0,UP=0,BELOW=1,DOWN=1,LEFT,RIGHT}

const hexagon_side_count = 6

var current_level = 0


enum HEX_FACE {TOP_FACE=0,TOP_RIGHT_FACE=1,BOTTOM_RIGHT_FACE=2,BOTTOM_FACE=3, BOTTOM_LEFT_FACE=4,TOP_LEFT_FACE=5}
var FACE_TO_OFFSET = {HEX_FACE.TOP_FACE: Vector2i(0, -1),HEX_FACE.TOP_RIGHT_FACE: Vector2i(1, -1),HEX_FACE.BOTTOM_RIGHT_FACE: Vector2i(1, 0),HEX_FACE.BOTTOM_FACE: Vector2i(0, 1), HEX_FACE.BOTTOM_LEFT_FACE: Vector2i(-1, 1),HEX_FACE.TOP_LEFT_FACE: Vector2i(-1, 0)}

enum HEX_CORNER {TOP_RIGHT_CORNER,RIGHT_CORNER,BOTTOM_RIGHT_CORNER,BOTTOM_LEFT_CORNER,LEFT_CORNER,TOP_LEFT_CORNER}
var CORNER_TO_OFFSET = {HEX_CORNER.TOP_RIGHT_CORNER: Vector2i(0, -1),HEX_CORNER.RIGHT_CORNER: Vector2i(1, -1),HEX_CORNER.BOTTOM_RIGHT_CORNER: Vector2i(1, 0),HEX_CORNER.BOTTOM_LEFT_CORNER: Vector2i(0, 1),HEX_CORNER.LEFT_CORNER: Vector2i(-1, 1),HEX_CORNER.TOP_LEFT_CORNER: Vector2i(-1, 0)}


var BASE_TILE_POS_IN_ATLAS = Vector2i(2, 0)
#these are the alternative ids bassed on the atlas 
enum TILE_IDS {WALL=10, GOAL=9,END=9, START=1, BRIDGE=8, WHITE=0}

const layer_to_place_on = 0
const background_layer = 1
const source_id = 1

const level_data_file_name = "level_data.json"
const placeables_file_name = "placeables.txt"
const level_holder_folder_with_prefix = "res://levels"

var useless_hexagon = CustomHexagon.new([])

var highest_distance_from_center = 3
var current_hexagon_to_place : CustomHexagon = CustomHexagon.new([])

var available_hexagons: Array[CustomHexagon] = []:
	get:
		return available_hexagons
	set(value):
		if value.size() > 0:
			current_selected_hexagon_index = 0
			current_hexagon_to_place = available_hexagons[0]
		else:
			current_hexagon_to_place = null
		available_hexagons = value
			
		
var current_selected_hexagon_index = 0:
	get:
		return current_selected_hexagon_index
	set(value):
		current_selected_hexagon_index = value
		if current_selected_hexagon_index >= available_hexagons.size():
			current_hexagon_to_place = useless_hexagon
		else:
			current_hexagon_to_place = available_hexagons[value]
		
		

const total_overlay_layers = 6
const starting_overlay_layer = 2

const pipe_sprites_source_id = 0
const main_hexagon_sprite_source_id = 1

const direction_to_pipe_atlas_coords_and_alt = {
	HEX_FACE.TOP_FACE : [Vector2i(0, 0), 1],
	HEX_FACE.TOP_RIGHT_FACE : [Vector2i(1, 0), 1],
	HEX_FACE.BOTTOM_RIGHT_FACE : [Vector2i(1, 0), 2],
	HEX_FACE.BOTTOM_FACE : [Vector2i(0, 0), 2],
	HEX_FACE.BOTTOM_LEFT_FACE : [Vector2i(1, 0), 3],
	HEX_FACE.TOP_LEFT_FACE : [Vector2i(1, 0), 4],
}

const face_to_grid_layer = {
	HEX_FACE.TOP_FACE : 2,
	HEX_FACE.TOP_RIGHT_FACE : 3,
	HEX_FACE.BOTTOM_RIGHT_FACE : 4,
	HEX_FACE.BOTTOM_FACE : 5,
	HEX_FACE.BOTTOM_LEFT_FACE : 6,
	HEX_FACE.TOP_LEFT_FACE : 7
}


func _ready():
	rotate_right.connect(on_rotate_right)
	assert(DIRECTION.BELOW == DIRECTION.DOWN)
	load_new_level.connect(on_load_new_level)
	print("connections: ", load_new_level.get_connections())
#	load_new_level.emit(8)

func on_load_new_level(level_num_to_load: int):
	print("ran on_load_new_level, loading level ", level_num_to_load)
	current_level = level_num_to_load
	read_from_level_data(level_num_to_load)
	read_placeable_data(level_num_to_load)
	print("current_hexagon_to_place ", current_hexagon_to_place)
	print("available_hexagons ", available_hexagons)
	

func get_times_rotated_60():
	return (current_grid_rotation / flat_top_frequency) % hexagon_side_count


func get_tile_offsets_in_direction(direction: DIRECTION):
	if has_flat_top():
		match direction:
			DIRECTION.ABOVE:
				return [adj6_flat_top[-1],adj6_flat_top[0],adj6_flat_top[1]]
			DIRECTION.RIGHT:
				return [adj6_flat_top[1], adj6_flat_top[2]]
			DIRECTION.DOWN:
				return adj6_flat_top.slice(2,5)
			DIRECTION.LEFT:
				return [adj6_flat_top[4], adj6_flat_top[5]]
	else:
		match direction:
			DIRECTION.ABOVE:
				return adj6_corner_top.slice(0,2)
			DIRECTION.RIGHT:
				return adj6_corner_top.slice(1,4)
			DIRECTION.DOWN:
				return adj6_corner_top.slice(3,5)
			DIRECTION.LEFT:
				return adj6_corner_top.slice(4) + adj6_corner_top[0]
	

func place_pipes(board_to_place_in: TileMap, hexagon_being_placed: CustomHexagon, position_to_place_at: Vector2i, use_rotation=true):
	for face in hexagon_being_placed.placeable_against_faces:
		var coords_and_alt 
		if use_rotation:
			coords_and_alt = Globals.direction_to_pipe_atlas_coords_and_alt[posmod((face - Globals.get_times_rotated_60()), Globals.hexagon_side_count)]
		else:
			coords_and_alt = Globals.direction_to_pipe_atlas_coords_and_alt[face]
			
		var coords = coords_and_alt[0]
		var alt = coords_and_alt[1]
		board_to_place_in.set_cell(Globals.face_to_grid_layer[face], position_to_place_at, Globals.pipe_sprites_source_id, coords, alt)

func clear_pipes(board_to_place_in: TileMap, position_to_place_at: Vector2i):
	for face in HEX_FACE.values():
		board_to_place_in.erase_cell(Globals.face_to_grid_layer[face], position_to_place_at)
		
func has_flat_top():
	return current_grid_rotation % flat_top_frequency == 0
	
func has_pointed_top():
	return not has_flat_top()

func update_rotation_vars(direction=DIRECTION.RIGHT):
	assert(direction in [DIRECTION.RIGHT, DIRECTION.LEFT], "direction should be left or right")
	if direction == DIRECTION.RIGHT:
		current_grid_rotation += rotation_increment
	elif direction == DIRECTION.LEFT:
		current_grid_rotation -= rotation_increment
		
	# TODO if rotation is ever changed to less than 30 degrees at a time
	# then this will break
	if current_grid_rotation % flat_top_frequency == 0:
#		print("before ", adj6_flat_top)
		adj6_flat_top = get_rotated_array(adj6_flat_top, direction)
#		print("new    ", adj6_flat_top)
	else:
		adj6_corner_top = get_rotated_array(adj6_corner_top, direction)
		
func get_rotated_array(start: Array, direction:DIRECTION) -> Array:
	var temp = start.duplicate()
	assert(direction in [DIRECTION.RIGHT, DIRECTION.LEFT], "direction should be left or right")
	if direction == DIRECTION.RIGHT:
		temp = [temp[-1]] + temp.slice(0, -1)
	elif direction == DIRECTION.LEFT:
		temp = temp.slice(1) + [temp[0]]
	return temp

func read_placeable_data(level_num_to_load: int):
	var placeables_file = "%s/level%02d/%s" % [level_holder_folder_with_prefix, level_num_to_load, placeables_file_name]
	var placeables_data = FileAccess.open(placeables_file, FileAccess.READ)
	print("file to read ", placeables_file)
	print("data ", placeables_data.get_as_text())
	print("reading placeable data")
	var string_array_version = placeables_data.get_as_text().strip_edges().split("\n") as Array[String]
	print("string array version ", string_array_version)
	available_hexagons.clear()
	available_hexagons.assign(string_array_version.map(func(x): 
		return CustomHexagon.from_binary_string(x)))
	available_hexagons = available_hexagons.duplicate(true)
	print("new value of placeables ", available_hexagons)
	

## loads level data from a file
func read_from_level_data(level_num_to_load: int) -> Variant:
	var level_json_file = "%s/level%02d/%s" % [level_holder_folder_with_prefix, level_num_to_load, level_data_file_name]
	var level_data = FileAccess.open(level_json_file, FileAccess.READ)
	var tile_json_data = JSON.parse_string(level_data.get_as_text())
	return tile_json_data
	
	

func save_current_level(board: TileMap, available_to_place: Array[String]):
	var current_folder = null
	var current_path = ""
	for i in range(10):
		current_folder = "%s/level%02d" % [level_holder_folder_with_prefix, i]
		current_path = "%s/%s" % [current_folder, level_data_file_name]
		if FileAccess.file_exists(current_path):
			continue
		break
	assert(not FileAccess.file_exists(current_path))
	DirAccess.make_dir_absolute(current_folder)
	var hex_grid_data = FileAccess.open(current_path, FileAccess.WRITE)
	var placeables_data = FileAccess.open(current_folder + "/" + placeables_file_name, FileAccess.WRITE)
	
	var tile_to_alt_id = {}
	for i in range(-Globals.highest_distance_from_center, Globals.highest_distance_from_center + 1):
		for j in range(-Globals.highest_distance_from_center, Globals.highest_distance_from_center + 1):
			if board.get_cell_alternative_tile(background_layer, Vector2i(i, j)) == TILE_IDS.WHITE:
				tile_to_alt_id[Vector2i(i, j)] = board.get_cell_alternative_tile(layer_to_place_on, Vector2i(i, j)) 
	#rearrange so that tiles that are not empty appear at the top of the file
	var sorted_version = {}
	var sorted_keys = tile_to_alt_id.keys()
	sorted_keys.sort_custom(func(a, b): return tile_to_alt_id[a] > tile_to_alt_id[b])
	for key in sorted_keys:
		sorted_version[key] = tile_to_alt_id[key]
	var json_version = JSON.stringify(sorted_version, "    ", false)
	hex_grid_data.store_line(json_version)
	for placeable in available_to_place:
		placeables_data.store_line(placeable)
	# store a screenshot of the level
	var image = get_viewport().get_texture().get_image()
	image.save_png("%s/preview.png" % current_folder)

func array_to_string(placeable_against_faces: Array):
	var representation = []
	for i in range(Globals.HEX_FACE.size()):
		if i in placeable_against_faces:
			representation.append(1)
		else:
			representation.append(0)
			
	return CustomHexagon.string_representation_sep.join(representation)
	
func get_walkable_around_coords(board: TileMap, pos: Vector2i) -> Array[Vector2i]:
	var all_used_cells = board.get_used_cells(layer_to_place_on)
	var all_spots_around = board.get_surrounding_cells(pos)
	var ret: Array[Vector2i] = []
	for spot in all_spots_around:
		var alt_id = board.get_cell_alternative_tile(layer_to_place_on, spot)
#		print("spot ", spot, " has alt id ", alt_id)
		if spot in all_used_cells and alt_id in [
			Globals.TILE_IDS.BRIDGE,
			Globals.TILE_IDS.START,
			Globals.TILE_IDS.GOAL
		]:
			ret.append(spot)
#	print(ret)
	return ret

func on_rotate_right():
	update_rotation_vars()


func _process(delta):
	if Input.is_action_just_pressed("rotate_grid_right"):
		rotate_right.emit()
#		rotate(deg_to_rad(30))
#		rotated_right.emit()
