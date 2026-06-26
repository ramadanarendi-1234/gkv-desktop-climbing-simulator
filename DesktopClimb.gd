extends Spatial

export var climb_distance = 1.5
export var climb_speed = 3.0

var left_hand_hold : Spatial = null
var right_hand_hold : Spatial = null

var is_climbing = false
var has_grabbed_once = false

onready var player = get_parent()
onready var camera = player.get_node("ARVRCamera") if player and player.has_node("ARVRCamera") else null

var last_highlighted = null
signal first_grab

var left_hand_mesh = null
var right_hand_mesh = null

func _ready():
	# Disabled by default, VRDesktopSwitch will enable if desktop mode
	set_process(false)
	
	if camera:
		var hand_scene = load("res://player/HandMesh.tscn")
		if hand_scene:
			left_hand_mesh = hand_scene.instance()
			camera.call_deferred("add_child", left_hand_mesh)
			left_hand_mesh.translation = Vector3(-0.3, -0.3, -0.5)
			
			right_hand_mesh = hand_scene.instance()
			camera.call_deferred("add_child", right_hand_mesh)
			right_hand_mesh.translation = Vector3(0.3, -0.3, -0.5)
			right_hand_mesh.scale.x = -1 # mirror for right hand

func _process(delta):
	if not player or not camera:
		return
		
	var handholds_node = get_tree().get_root().find_node("HandHelds", true, false)
	if not handholds_node:
		return
	var handholds = handholds_node.get_children()
	
	var cam_pos = camera.global_transform.origin
	var cam_forward = -camera.global_transform.basis.z.normalized()
	
	var best_hold = null
	var best_score = -1.0
	
	for h in handholds:
		var hold_pos = h.global_transform.origin
		var dist = cam_pos.distance_to(hold_pos)
		
		if dist < climb_distance:
			var dir_to_hold = (hold_pos - cam_pos).normalized()
			var dot = cam_forward.dot(dir_to_hold)
			
			if dot > 0.8: # Looking roughly at it
				var score = dot * 10.0 - dist
				if score > best_score:
					best_score = score
					best_hold = h
					
	if last_highlighted and last_highlighted != best_hold:
		if last_highlighted.has_method("unhighlight") and last_highlighted != left_hand_hold and last_highlighted != right_hand_hold:
			last_highlighted.unhighlight()
			
	if best_hold and best_hold != left_hand_hold and best_hold != right_hand_hold:
		if best_hold.has_method("highlight"):
			best_hold.highlight()
		last_highlighted = best_hold

	# Desktop input
	var q_pressed = Input.is_key_pressed(KEY_Q)
	var e_pressed = Input.is_key_pressed(KEY_E)

	# Hand animation
	if left_hand_mesh:
		if q_pressed:
			left_hand_mesh.grab = 1.0
			left_hand_mesh.translation.z = -0.6
		else:
			left_hand_mesh.grab = 0.0
			left_hand_mesh.translation.z = -0.5
				
	if right_hand_mesh:
		if e_pressed:
			right_hand_mesh.grab = 1.0
			right_hand_mesh.translation.z = -0.6
		else:
			right_hand_mesh.grab = 0.0
			right_hand_mesh.translation.z = -0.5

	if q_pressed:
		if not left_hand_hold and best_hold:
			left_hand_hold = best_hold
			_on_grab()
	elif left_hand_hold:
		if left_hand_hold.has_method("unhighlight"):
			left_hand_hold.unhighlight()
		left_hand_hold = null
		
	if Input.is_key_pressed(KEY_E):
		if not right_hand_hold and best_hold:
			right_hand_hold = best_hold
			_on_grab()
	elif right_hand_hold:
		if right_hand_hold.has_method("unhighlight"):
			right_hand_hold.unhighlight()
		right_hand_hold = null
		
	is_climbing = (left_hand_hold != null or right_hand_hold != null)
	
	var desktop_movement = player.get_node_or_null("DesktopMovement")
	if desktop_movement:
		desktop_movement.is_climbing = is_climbing
		
	if is_climbing:
		var target_pos = Vector3.ZERO
		var holds_count = 0
		
		if left_hand_hold:
			target_pos += left_hand_hold.global_transform.origin
			holds_count += 1
		if right_hand_hold:
			target_pos += right_hand_hold.global_transform.origin
			holds_count += 1
			
		target_pos /= holds_count
		target_pos += Vector3(0, -1.0, 0) # Head offset below hand
		
		var hold_flat = Vector3(target_pos.x, 0, target_pos.z)
		var away_dir = hold_flat.direction_to(Vector3.ZERO)
		if away_dir.length() > 0.01:
			target_pos += away_dir * 0.8
		
		var move_dir = (target_pos - player.global_transform.origin)
		if move_dir.length() > 0.05:
			player.global_transform.origin += move_dir.normalized() * climb_speed * delta

func _on_grab():
	if not has_grabbed_once:
		has_grabbed_once = true
		emit_signal("first_grab")
