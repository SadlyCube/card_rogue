extends CharacterBody3D

@export var card_pref: PackedScene
@export var cursor: PackedScene

var card_selected: bool = false

const SPEED = 7.0
const JUMP_VELOCITY = 0.0
var card_count: int = 10
var hand: Node3D
var main_cam: Camera3D


func spawn_card(pref, card_no: int, hand_object):
	var card = pref.instantiate()
	
	card.order = card_no
	card.card_count = card_count
	card.position = Vector3(0,0,0)
	hand_object.add_child(card)
	
	#card.position = lerp(card.position, card_position, 0.1)

func check_hand(hand):
	var cards = hand.get_children()
	var new_count = len(cards)
	var selection_list = []
	for i in range(new_count):
		cards[i].order = i
		cards[i].card_count = new_count
		selection_list.append(cards[i].selected)
	if true in selection_list:
		card_selected = true
	else:
		card_selected = false

func _ready():
	main_cam = get_node("main_cam")
	hand = main_cam.get_node("hand")
	for no in range(card_count):
		spawn_card(card_pref, no, hand)
	
func _process(delta):
	check_hand(hand)
	cursor_operator(get_tree().root.get_child(0))

func process_cursor(pointer, position):
	pointer.position = position
	if card_selected:
		pointer.get_node("range_selector").visible = true
	else:
		pointer.get_node("range_selector").visible = false

func mouse_position():
	return get_viewport().get_mouse_position()

func read_position():
	var ray_lenght = 500.0
	var from = main_cam.project_ray_origin(mouse_position())
	var to = main_cam.project_ray_normal(mouse_position()) * ray_lenght
	var space = get_world_3d().direct_space_state
	var rayQuery = PhysicsRayQueryParameters3D.new()
	rayQuery.exclude = [self]
	rayQuery.from = from
	rayQuery.to = to
	var res = space.intersect_ray(rayQuery)
	if res.size()>1:
		return [true, res.position]
	else:
		return [false, Vector3(0,0,0)]
		
func cursor_operator(scene):
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

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
