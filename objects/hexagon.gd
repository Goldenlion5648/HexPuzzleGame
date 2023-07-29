class_name CustomHexagon

var placeable_against_faces: Array[int]
var placeable_against_corners: Array[int]

## _placeable_against_faces
## _placeable_against_corners
func _init(_placeable_against_faces: Array[int], _placeable_against_corners: Array[int]):
	placeable_against_faces = _placeable_against_faces.duplicate()
	placeable_against_corners = _placeable_against_corners.duplicate()

func can_place_here(board: TileMap, pos: Vector2i) -> bool:
	var walkable_around = Globals.get_walkable_around_coords(board, pos)
	var options = []
	print("face to offset ", Globals.FACE_TO_OFFSET)
	print("placeable_against_faces ", self.placeable_against_faces)
	print("pos ", pos)
	for face in placeable_against_faces:
		var combined = Globals.FACE_TO_OFFSET[face] + pos
		print("face to offset ", Globals.FACE_TO_OFFSET[face])
		print("combined ", combined)
		if combined in walkable_around:
			return true
	return false
	
	
