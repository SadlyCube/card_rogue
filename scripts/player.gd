extends CharacterBody3D

@export var card_pref: PackedScene

const SPEED = 7.0
const JUMP_VELOCITY = 0.0
var card_count: int = 7
var hand: Node3D

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
	for i in range(new_count):
		cards[i].order = i
		cards[i].card_count = new_count

func _ready():
	hand = get_node("main_cam/hand")
	for no in range(card_count):
		spawn_card(card_pref, no, hand)
	
func _process(delta):
	check_hand(hand)

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
