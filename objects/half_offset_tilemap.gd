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
			add_child.call_deferred(current)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func place_at_clicked_spot():
	var erase_mode = false
	if Input.is_action_pressed("shift"):
		erase_mode = true
	
	if Input.is_action_just_pressed("right_click"):
		tile_id_to_place += 1
		tile_id_to_place %= 3
		
	if Input.is_action_just_pressed("left_click"):
		var tile = local_to_map(to_local(get_global_mouse_position()))
		print("clicked position was ", tile)
#		tile = map_to_local(tile)
#		var alt = get_cell_source_id(0, tile)
		# the first parameter is the layer
		# the second is the position
		#change the fourth parameter to change what tile is placed
		if erase_mode:
			erase_cell(0, tile)
		else:
			set_cell(0, tile, 1, Vector2i(tile_id_to_place, 0), alt_to_place)
		
		print("above are", Globals.get_tile_offsets_in_direction(Globals.DIRECTION.ABOVE))
		print("right are", Globals.get_tile_offsets_in_direction(Globals.DIRECTION.RIGHT))
		print("down are", Globals.get_tile_offsets_in_direction(Globals.DIRECTION.DOWN))
		print("left are", Globals.get_tile_offsets_in_direction(Globals.DIRECTION.LEFT))


func _process(delta):
	place_at_clicked_spot()
