extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("rotate_right", on_rotate_right)
	pass # Replace with function body.


func on_rotate_right():
	rotate(deg_to_rad(Globals.rotation_increment))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if Input.is_action_just_pressed("rotate_grid_right"):
#		rotated_right.emit()
	
	pass
