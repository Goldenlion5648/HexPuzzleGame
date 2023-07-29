class_name CustomHexagon

var placeable_against_faces: Array
var placeable_against_corners: Array

const string_representation_sep = "_"
## _placeable_against_faces (array of numbers)
## _placeable_against_corners
func _init(_placeable_against_faces: Array, _placeable_against_corners: Array=[]):
	placeable_against_faces = _placeable_against_faces.duplicate()
	placeable_against_corners = _placeable_against_corners.duplicate()

func from_string(string: String) -> CustomHexagon:
	return CustomHexagon.new((string.split(string_representation_sep) as Array[String]).map(func(x): return int(x)))

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
	
	
