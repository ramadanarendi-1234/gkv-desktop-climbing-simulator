extends Spatial

export(NodePath) var Player

var walk_speed = 5.0
var sprint_speed = 10.0

var jump_force = 5.0
var gravity = 12.0
var velocity_y = 0.0
var is_grounded = true

var is_climbing = false

func _ready():
	# Disabled by default, VRDesktopSwitch will enable if desktop mode
	set_process(false)

func _process(delta):
	if Player == null:
		return

	if is_climbing:
		is_grounded = false
		velocity_y = 0
		return

	var player = get_node(Player)

	var direction = Vector3()

	if Input.is_key_pressed(KEY_W):
		direction -= player.global_transform.basis.z

	if Input.is_key_pressed(KEY_S):
		direction += player.global_transform.basis.z

	if Input.is_key_pressed(KEY_A):
		direction -= player.global_transform.basis.x

	if Input.is_key_pressed(KEY_D):
		direction += player.global_transform.basis.x

	direction.y = 0

	var current_speed = walk_speed

	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = sprint_speed

	if direction.length() > 0:
		direction = direction.normalized()
		player.translation += direction * current_speed * delta

# Jump
	if Input.is_key_pressed(KEY_SPACE) and is_grounded:
		velocity_y = jump_force
		is_grounded = false

	# Gravity
	velocity_y -= gravity * delta
	player.translation.y += velocity_y * delta

	# Ground check
	if player.translation.y <= 0:
		player.translation.y = 0
		velocity_y = 0
		is_grounded = true
	else:
		is_grounded = false
