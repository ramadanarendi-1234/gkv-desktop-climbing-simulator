extends Spatial

export (NodePath) var left_hand
export (NodePath) var right_hand
export (NodePath) var origin

export var reset_button = 7
export var gravity = 9.8

onready var left_hand_node = get_node(left_hand) if left_hand else null
onready var right_hand_node = get_node(right_hand) if right_hand else null
onready var origin_node = get_node(origin) if origin else null

var left_hand_is_holding = false
var left_hand_last_position : Vector3
var right_hand_is_holding = false
var right_hand_last_position : Vector3
var fall_velocity : float = 0.0

var desktop_mode = false
var has_grabbed_once = false

signal first_grab
signal player_fell
signal player_height_changed(y)

func force_release():
	left_hand_is_holding = false
	right_hand_is_holding = false
	if left_hand_node:
		left_hand_node.is_holding = false
	if right_hand_node:
		right_hand_node.is_holding = false

func reset_position(teleport = true):
	if origin_node and teleport:
		origin_node.global_transform.origin = Vector3.ZERO
	fall_velocity = 0.0
	has_grabbed_once = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if origin_node:
		emit_signal("player_height_changed", origin_node.global_transform.origin.y)
		
	var delta_movement : Vector3
	var hands_holding = 0
	
	# check our left hand first
	if left_hand_node:
		var is_holding = left_hand_node.get_is_holding()
		if left_hand_is_holding != is_holding:
			left_hand_is_holding = is_holding
		elif left_hand_is_holding:
			# we skip the first frame we're holding because we don't have our last position
			delta_movement += left_hand_node.global_transform.origin - left_hand_last_position
			hands_holding = hands_holding + 1

	# check our right hand first
	if right_hand_node:
		var is_holding = right_hand_node.get_is_holding()
		if right_hand_is_holding != is_holding:
			right_hand_is_holding = is_holding
		elif right_hand_is_holding:
			# we skip the first frame we're holding because we don't have our last position
			delta_movement += right_hand_node.global_transform.origin - right_hand_last_position
			hands_holding = hands_holding + 1

	if desktop_mode:
		# In desktop mode, DesktopMovement handles gravity and DesktopClimb handles climbing
		# We just need to check for falls below -5.0 or hitting the ground
		if origin_node and origin_node.global_transform.origin.y < -5.0:
			emit_signal("player_fell")
		return

	if origin_node:
		# are we holding atleast one hand? then adjust our origin point accordingly
		if hands_holding > 0:
			# get our average
			delta_movement = delta_movement / hands_holding
		
			# move our origin
			origin_node.global_transform.origin -= delta_movement
			
			# move any hand anchor that is currently holding
			if left_hand_is_holding:
				if not has_grabbed_once:
					has_grabbed_once = true
					emit_signal("first_grab")
				var anchor = left_hand_node.get_node("HandAnchor")
				if anchor:
					anchor.global_transform.origin += delta_movement

			if right_hand_is_holding:
				if not has_grabbed_once:
					has_grabbed_once = true
					emit_signal("first_grab")
				var anchor = right_hand_node.get_node("HandAnchor")
				if anchor:
					anchor.global_transform.origin += delta_movement
			
			fall_velocity = 0.0
		else:
			# apply gravity to our origin point
			var y = origin_node.global_transform.origin.y
			
			fall_velocity += delta * gravity
			y -= fall_velocity * delta
			if y < -5.0:
				emit_signal("player_fell")
			
			origin_node.global_transform.origin.y = y


	if left_hand_is_holding:
		left_hand_last_position = left_hand_node.global_transform.origin

	if right_hand_is_holding:
		right_hand_last_position = right_hand_node.global_transform.origin

func _on_RightHandController_button_pressed(button):
	if button == reset_button:
		$RecenterTimer.start()

func _on_RightHandController_button_release(button):
	if button == reset_button:
		$RecenterTimer.stop()

func _on_RecenterTimer_timeout():
	ARVRServer.center_on_hmd(ARVRServer.RESET_BUT_KEEP_TILT, true)
