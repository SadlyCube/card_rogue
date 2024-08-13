extends Node3D

@export var order:int = 0
@export var card_count: int = 1

@export var cursor: PackedScene

var scene: Node3D

var selected: bool = false
var holded: bool = false

var origin_y: float = 0
var desire_y: float
var real_y: float

var origin_size: float
var desire_size: float
var real_size: float

var main_cam: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	scene = get_tree().root.get_child(0)
	main_cam = get_node("../..")
	origin_y = position.y
	desire_y = origin_y
	real_y = origin_y
	
	origin_size = scale.y
	desire_size = origin_size
	real_size = origin_size
	
func mouse_position():
	return get_viewport().get_mouse_position()
	
func get_rotate(main_cam):
	var card_center = main_cam.unproject_position(global_transform.origin)
	var width = get_viewport().size.x
	var x_offset = mouse_position().x - card_center.x
	var y_offset = mouse_position().y - card_center.y
		
	var  magnitude = 0.5
	
	var offset = Vector3(y_offset, x_offset, 0)
	
	return offset.normalized() * magnitude

func rotate_card(selected, main_cam):
	var offset = Vector3(0,0,0)
	if selected:
		offset = get_rotate(main_cam)
	else:
		offset = Vector3(0,0,0)
	rotation = lerp(rotation, offset, 0.1)

func select_card(selected):
	if selected:
		position.z = +1
		desire_size = origin_size + 0.05
		desire_y = origin_y + 0.5
	else:
		position.z = 0
		desire_size = origin_size
		desire_y = origin_y
	real_y = lerp(real_y, desire_y, 0.1)
	real_size = lerp(real_size, desire_size, 0.1)
	scale = Vector3(real_size, real_size, real_size)
	position.y = real_y

func update_cards(order, card_count):
	var new_position = float(order) - float(card_count-1)/2
	position.x = lerp(position.x, new_position, 0.1)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func read_position():
	var ray_lenght = 500.0
	var from = main_cam.project_ray_origin(mouse_position())
	var to = main_cam.project_ray_normal(mouse_position()) * ray_lenght
	var space = get_world_3d().direct_space_state
	var rayQuery = PhysicsRayQueryParameters3D.new()
	rayQuery.exclude = [scene.get_node_or_null("player")]
	#rayQuery.collision_mask = 
	rayQuery.from = from
	rayQuery.to = to
	#print('from ', from, ' to ', to)
	var res = space.intersect_ray(rayQuery)
	if res.size()>1:
		return [true, res.position]
	else:
		return [false, Vector3(0,0,0)]

func process_cursor(pointer, position):
	pointer.position = position
		#else:
			#point.queue_free() 
		


func cursor_operator(selected, holded, scene):
	var hit = read_position()[0]
	var position = read_position()[1]
	if hit:
		var pointer: Node3D
		if not scene.get_node_or_null("cursor"):
			pointer = cursor.instantiate()
			scene.add_child(pointer)
		else:
			pointer = scene.get_node("cursor")
			process_cursor(pointer, position)
	else:
		if scene.get_node_or_null("cursor"):
			scene.get_node("cursor").queue_free() 
	#process_cursor(selected, holded, scene)
	#if selected and holded:
		#pass

func _process(delta):
	rotate_card(selected, main_cam)
	if not holded:
		select_card(selected)
		update_cards(order, card_count)
	cursor_operator(selected, holded, scene)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if selected:
					holded = true
			else:
				holded = false
				selected = false

func _on_area_3d_mouse_entered():
	if not holded:
		selected = true

func _on_area_3d_mouse_exited():
	selected = false
