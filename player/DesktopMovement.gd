extends Spatial

export(NodePath) var Player

var walk_speed = 5.0
var sprint_speed = 10.0

var jump_force = 5.0
var gravity = 12.0
var velocity_y = 0.0
var is_grounded = true

var is_climbing = false
var kb : KinematicBody = null

func _ready():
	# Disabled by default, VRDesktopSwitch will enable if desktop mode
	set_process(false)

func _setup_kb(player):
	if kb: return
	kb = KinematicBody.new()
	var shape = CollisionShape.new()
	var cap = CapsuleShape.new()
	cap.radius = 0.4
	cap.height = 1.0
	shape.shape = cap
	shape.translation.y = 0.9 # Offset so bottom is at Y=0
	shape.rotation_degrees.x = 90
	kb.add_child(shape)
	kb.collision_mask = 1
	kb.collision_layer = 1
	get_tree().current_scene.add_child(kb)
	kb.global_transform.origin = player.global_transform.origin

func _process(delta):
	if Player == null:
		return

	var player = get_node(Player)
	
	if not kb:
		_setup_kb(player)

	if is_climbing:
		is_grounded = false
		velocity_y = 0
		kb.global_transform.origin = player.global_transform.origin
		return

	var current_speed = walk_speed
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = sprint_speed

	# Movement direction based on player camera facing
	var camera = player.get_node_or_null("ARVRCamera")
	var forward = Vector3(0, 0, 1)
	var right = Vector3(1, 0, 0)
	
	if camera:
		var cam_basis = camera.global_transform.basis
		forward = -cam_basis.z
		forward.y = 0
		if forward.length() > 0:
			forward = forward.normalized()
		
		right = cam_basis.x
		right.y = 0
		if right.length() > 0:
			right = right.normalized()

	var velocity = Vector3()
	if Input.is_key_pressed(KEY_W):
		velocity += forward
	if Input.is_key_pressed(KEY_S):
		velocity -= forward
	if Input.is_key_pressed(KEY_A):
		velocity -= right
	if Input.is_key_pressed(KEY_D):
		velocity += right
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * current_speed

	if Input.is_action_just_pressed("ui_select") and is_grounded:
		velocity_y = jump_force
		is_grounded = false

	# Gravity
	velocity_y -= gravity * delta

	# Sync kb to player before move
	kb.global_transform.origin = player.global_transform.origin

	var final_vel = Vector3(velocity.x, velocity_y, velocity.z)
	final_vel = kb.move_and_slide(final_vel, Vector3.UP)

	# Update player position to where kb successfully moved
	player.global_transform.origin = kb.global_transform.origin
	velocity_y = final_vel.y
	is_grounded = kb.is_on_floor()
