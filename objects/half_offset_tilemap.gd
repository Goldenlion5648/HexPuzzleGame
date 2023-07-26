extends TileMap


const label = preload("res://objects/simple_label.tscn")
var alt_to_place = 0
var tile_id_to_place = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	place_labels()

	pass # Replace with function body.

func place_labels():
	var tile_size = Vector2(101, 88)
	var offset = tile_size / 3.0
	print(offset)
	for i in range(-5, 5):
		for j in range(-5, 5):
			var current: Label = label.instantiate()
			current.set_global_position(to_global(map_to_local(Vector2i(i, j))) - offset)
#			print("label position ", current.position)
			current.text = "%d %d" % [i, j]
#			add_sibling.call_deferred(current)
			var white_tile = 2
			set_cell(1, Vector2i(i, j), 1, Vector2i(white_tile, 0), alt_to_place)
			add_child.call_deferred(current)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func place_at_clicked_spot():
	var erase_mode = false
	if Input.is_action_pressed("shift"):
		erase_mode = true
	
	var tile = local_to_map(to_local(get_global_mouse_position()))
	if Input.is_action_just_pressed("right_click"):
		erase_cell(0, tile)
#		print(get_used_cells(0))
#		tile_id_to_place += 1
#		tile_id_to_place %= 3
		
	if Input.is_action_just_pressed("left_click"):
		print("clicked position was ", tile)
		print(tile)
		set_cell(0, tile, 1, Vector2i(tile_id_to_place, 0), alt_to_place)
		
		var had_path = dfs(Vector2i(0, 0), Vector2i(1, -3))
		print("had path ", had_path)
#		tile = map_to_local(tile)
#		var alt = get_cell_source_id(0, tile)
		# the first parameter is the layer
		# the second is the position
		#change the fourth parameter to change what tile is placed
#		if erase_mode:
#			erase_cell(0, tile)
#		else:
		
		print("above are", Globals.get_tile_offsets_in_direction(Globals.DIRECTION.ABOVE))
		print("right are", Globals.get_tile_offsets_in_direction(Globals.DIRECTION.RIGHT))
		print("down are", Globals.get_tile_offsets_in_direction(Globals.DIRECTION.DOWN))
		print("left are", Globals.get_tile_offsets_in_direction(Globals.DIRECTION.LEFT))

func get_existing_cells_around(pos: Vector2i):
	var all_used_cells = get_used_cells(0)
	var all_spots_around = get_surrounding_cells(pos)
	var ret = []
	for spot in all_spots_around:
		if spot in all_used_cells:
			ret.append(spot)
	return ret
	
## returns true if there is a path from "from" -> "to"
## false otherwise
func dfs(from: Vector2i, to: Vector2i):
	print("from ", from, " to ", to)
	var fringe = get_existing_cells_around(from)
	print("starting fringe ", fringe)
	if from == to:
		return true
	var cur = null
	var seen = {}
	while fringe.size() > 0:
		cur = fringe.pop_back()
		print("fringe, ", fringe)
		if cur in seen:
			continue
		seen[cur] = true
		if cur == to:
			return true
		fringe.append_array(get_existing_cells_around(cur))
	return false
		

func _process(delta):
	place_at_clicked_spot()
