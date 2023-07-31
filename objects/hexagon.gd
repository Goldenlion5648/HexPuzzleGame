class_name CustomHexagon

var placeable_against_faces: Array
var placeable_against_corners: Array

const string_representation_sep = "_"
## _placeable_against_faces (array of numbers)
## _placeable_against_corners
func _init(_placeable_against_faces: Array, _placeable_against_corners: Array=[]):
	placeable_against_faces = _placeable_against_faces.duplicate()
	placeable_against_corners = _placeable_against_corners.duplicate()
	

static func from_binary_string(string: String) -> CustomHexagon:
#	print("from string got ", string)
#	assert(len(string) > 0, "no hexagons provided")
	if len(string) == 0:
		return CustomHexagon.new([])
	var split_up = string.split(string_representation_sep) as Array[String]
	print("split_up ", split_up)
	var mapped = split_up.map(func(x): return int(x))
#	print("mapped ", mapped)
	var real = []
	print("mapped ", mapped)
	for i in range(Globals.hexagon_side_count):
		if mapped[i] == 1:
			real.append(i)
	var result = CustomHexagon.new(real)
#	print(result)
	return result

func is_used_up() -> bool:
	return placeable_against_faces.size() == 0

func set_as_used_up():
	placeable_against_faces = []

func _to_string():
	var representation = []
	for i in range(Globals.HEX_FACE.size()):
		if i in placeable_against_faces:
			representation.append(1)
		else:
			representation.append(0)
			
	return string_representation_sep.join(representation)


func can_place_here(board: TileMap, pos: Vector2i) -> bool:
	var walkable_around = Globals.get_walkable_around_coords(board, pos)
	var options = []
#	print("face to offset ", Globals.FACE_TO_OFFSET)
#	print("placeable_against_faces ", self.placeable_against_faces)
#	print("pos ", pos)
	for face in placeable_against_faces:
		var combined = Globals.adj6_flat_top[face] + pos
		print("face to offset ", Globals.adj6_flat_top[face])
		print("combined ", combined)
		if combined in walkable_around:
			return true
#	print("all corners to offset ", Globals.CORNER_TO_OFFSET)
#	for corner in placeable_against_corners:
#		var combined = Globals.CORNER_TO_OFFSET[corner] + pos
#		print("corner to offset ", Globals.CORNER_TO_OFFSET[corner])
#		print("combined ", combined)
#		if combined in walkable_around:
#			return true
	return false
	
	
