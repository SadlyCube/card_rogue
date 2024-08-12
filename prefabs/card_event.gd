extends Node3D

var origin_y: float
var desire_y: float
var real_y: float

var origin_size: float
var desire_size: float
var real_size: float

# Called when the node enters the scene tree for the first time.
func _ready():
	origin_y = position.y
	desire_y = origin_y
	real_y = origin_y
	
	origin_size = scale.y
	desire_size = origin_size
	real_size = origin_size
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	real_y = lerp(real_y, desire_y, 0.1)
	real_size = lerp(real_size, desire_size, 0.1)
	scale.y = real_size
	scale.x = real_size
	scale.y = real_size
	position.y = real_y
	#print(get_viewport().get_mouse_position())

#func _input(event):
	#print(event.position)

func _on_area_3d_mouse_entered():
	position.z = -1
	desire_size = origin_size + 0.05
	desire_y = origin_y + 0.5


func _on_area_3d_mouse_exited():
	position.z = -2
	desire_size = origin_size
	desire_y = origin_y
