extends Node



signal rotate_right

var current_grid_rotation = 0
var rotation_increment = 30
var adj6_flat_top = [Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0)]
var adj6_corner_top = [Vector2i(0, -1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 1), Vector2i(-1, 0)]

const flat_top_frequency = 60
enum DIRECTION {ABOVE=0,UP=0,BELOW=1,DOWN=1,LEFT,RIGHT}


enum HEX_FACE {TOP_FACE=0,TOP_RIGHT_FACE=1,BOTTOM_RIGHT_FACE=2,BOTTOM_FACE=3, BOTTOM_LEFT_FACE=4,TOP_LEFT_FACE=5}
var FACE_TO_OFFSET = {HEX_FACE.TOP_FACE: Vector2i(0, -1),HEX_FACE.TOP_RIGHT_FACE: Vector2i(1, -1),HEX_FACE.BOTTOM_RIGHT_FACE: Vector2i(1, 0),HEX_FACE.BOTTOM_FACE: Vector2i(0, 1), HEX_FACE.BOTTOM_LEFT_FACE: Vector2i(-1, 1),HEX_FACE.TOP_LEFT_FACE: Vector2i(-1, 0)}

enum HEX_CORNER {TOP_RIGHT_CORNER,RIGHT_CORNER,BOTTOM_RIGHT_CORNER,BOTTOM_LEFT_CORNER,LEFT_CORNER,TOP_LEFT_CORNER}
var CORNER_TO_OFFSET = {HEX_CORNER.TOP_RIGHT_CORNER: Vector2i(0, -1),HEX_CORNER.RIGHT_CORNER: Vector2i(1, -1),HEX_CORNER.BOTTOM_RIGHT_CORNER: Vector2i(1, 0),HEX_CORNER.BOTTOM_LEFT_CORNER: Vector2i(0, 1),HEX_CORNER.LEFT_CORNER: Vector2i(-1, 1),HEX_CORNER.TOP_LEFT_CORNER: Vector2i(-1, 0)}


var BASE_TILE_POS = Vector2i(2, 0)
#these are the alternative ids bassed on the atlas 
enum TILE_IDS {WALL=10, GOAL=9,END=9, START=1, BRIDGE=8}

const layer_to_place_on = 0
const background_layer = 1
const source_id = 1

var highest_distance_from_center = 3



#var current_placing = Hexagon.new()

func _ready():
	rotate_right.connect(on_rotate_right)
	assert(DIRECTION.BELOW == DIRECTION.DOWN)

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
	

func has_flat_top():
	return current_grid_rotation % flat_top_frequency == 0
	
func has_pointed_top():
	return not has_flat_top()

func update_rotation_vars(direction=DIRECTION.RIGHT):
	if direction == DIRECTION.RIGHT:
		current_grid_rotation += rotation_increment
	elif direction == DIRECTION.RIGHT:
		current_grid_rotation -= rotation_increment
		
	# TODO if rotation is ever changed to less than 30 degrees at a time
	# then this will break
	if current_grid_rotation % flat_top_frequency == 0:
		print("before ", adj6_flat_top)
		adj6_flat_top = get_rotated_array(adj6_flat_top, direction)
		print("new    ", adj6_flat_top)
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
