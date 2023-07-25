extends Node

signal rotate_right

var current_grid_rotation = 0
var rotation_increment = 30
var adj6_flat_top = [[0, -1], [1, -1], [1, 0], [0, 1], [-1, 1], [-1, 0]]
var adj6_corner_top = [[0, -1], [1, -1], [1, 0], [0, 1], [-1, 1], [-1, 0]]

const flat_top_frequency = 60
enum DIRECTION {ABOVE=0,UP=0,BELOW=1,DOWN=1,LEFT,RIGHT}

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

func on_rotate_right():
	update_rotation_vars()


func _process(delta):
	if Input.is_action_just_pressed("rotate_grid_right"):
		rotate_right.emit()
#		rotate(deg_to_rad(30))
#		rotated_right.emit()
