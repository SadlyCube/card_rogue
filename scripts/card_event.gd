extends Node3D

@export var order:int = 0
@export var card_count: int = 1

@export var box_pref: PackedScene

var dead_zoned: bool = false

var drop_position
var drop_size: Vector3

var scene: Node3D

var selected: bool = false
var holded: bool = false
var on_hand: bool = true

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
	
	drop_size = scale/5

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

func read_drop(scene: Node3D, selected: bool):
	var pointer = scene.get_node_or_null("cursor")
	if pointer and selected:
		var new_origin_rotation = to_global(rotation)
		var new_origin_position = to_global(position)
		
		get_parent().remove_child(self)
		scene.add_child(self)
		position = new_origin_position
		rotation = new_origin_rotation
		
		on_hand = false
		
		var new_position = pointer.position
		return new_position

		
		#queue_free()

func cast_box(drop_point):
	var box = box_pref.instantiate()
	scene.add_child(box)
	box.position = drop_point

func cast_effect():
	cast_box(drop_position)

func update_selector(holded: bool, pointer: Node3D):
	if pointer:
		if holded:
			pointer.get_node("range_selector").visible = true
		else:
			pointer.get_node("range_selector").visible = false

func drop_card(on_hand: bool, drop_position):
	if not on_hand:
		if drop_position:
			position = lerp(position, drop_position, 0.1)
			scale = lerp(scale, drop_size, 0.1)
			#rotation = lerp(rotation, Vector3(-90,0,0), 1)
			var dist = position.distance_to(drop_position)
			if dist <= 0.1:
				cast_effect()
				queue_free()

func cheack_dead_zone(camera: Camera3D):
	var mpos = mouse_position()
	var hand = get_node("..")
	var x_list = []
	var y_cen
	for card in hand.get_children():
		var projection = camera.unproject_position(card.global_transform.origin)
		x_list.append(projection.x)
		y_cen = projection.y
	var x_min = x_list.min()
	var x_max = x_list.max()
	var y_max = y_cen + 50
	var y_min = y_cen - 50

	if mpos.x < x_max and mpos.x > x_min and mpos.y < y_max and mpos.y > y_min:
		dead_zoned = true
	else:
		dead_zoned = false

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if selected:
					holded = true
			else:
				if not dead_zoned:
					if on_hand:
						drop_position = read_drop(scene, selected)
				holded = false
				selected = false

func _on_area_3d_mouse_entered():
	if not holded:
		selected = true

func _on_area_3d_mouse_exited():
	if not holded:
		selected = false

func _process(delta):
	rotate_card(selected, main_cam)
	if not holded and on_hand:
		select_card(selected)
		update_cards(order, card_count)
	cheack_dead_zone(main_cam)
	drop_card(on_hand, drop_position)
	print(dead_zoned)
