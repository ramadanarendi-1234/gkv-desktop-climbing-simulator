extends Spatial

var hud = null
var pause_menu = null
var win_screen = null
var intro_tutorial = null

var was_menu_open = false
var _is_clicked = {}
var last_mouse_pos = {}

func _ready():
	# Check if VR mode is active
	var interface = ARVRServer.find_interface("OpenXR")
	if not interface or not interface.is_initialized():
		queue_free()
		return
		
	print("VRUI: Initializing 3D floating UI for OpenXR...")
	
	# 1. Create Viewport
	var vp = Viewport.new()
	vp.name = "VRViewport"
	vp.size = Vector2(1024, 1024)
	vp.transparent_bg = true
	vp.hdr = false
	vp.usage = Viewport.USAGE_2D
	vp.render_target_v_flip = true
	vp.render_target_update_mode = Viewport.UPDATE_ALWAYS
	add_child(vp)
	
	# 2. Create VRUIPlane MeshInstance
	var plane = MeshInstance.new()
	plane.name = "VRUIPlane"
	
	var quad = QuadMesh.new()
	quad.size = Vector2(1.5, 1.5)
	plane.mesh = quad
	
	var mat = SpatialMaterial.new()
	mat.flags_transparent = true
	mat.flags_unshaded = true
	mat.albedo_texture = vp.get_texture()
	plane.set_surface_material(0, mat)
	
	plane.visible = false
	add_child(plane)
	
	# 3. Create StaticBody & CollisionShape for Raycast target
	var body = StaticBody.new()
	body.name = "StaticBody"
	body.collision_layer = 262144 # Layer 19
	body.collision_mask = 0
	plane.add_child(body)
	
	var shape = CollisionShape.new()
	var box = BoxShape.new()
	box.extents = Vector3(0.75, 0.75, 0.01)
	shape.shape = box
	body.add_child(shape)
	
	# 4. Setup controllers
	var left = get_parent().get_node_or_null("LeftHandController")
	var right = get_parent().get_node_or_null("RightHandController")
	_setup_controller_pointer(left)
	_setup_controller_pointer(right)
	
	# 5. Capture CanvasLayers
	call_deferred("_capture_canvas_layers")

func _setup_controller_pointer(controller: ARVRController):
	if not controller:
		return
		
	# Create RayCast
	var ray = RayCast.new()
	ray.name = "UIRayCast"
	ray.enabled = true
	ray.cast_to = Vector3(0, 0, -3.0)
	ray.collision_mask = 262144 # Layer 19
	controller.add_child(ray)
	
	# Create PointerLine MeshInstance using a long thin CubeMesh
	var line = MeshInstance.new()
	line.name = "PointerLine"
	
	var mesh = CubeMesh.new()
	mesh.size = Vector3(0.005, 0.005, 1.0)
	line.mesh = mesh
	
	var mat = SpatialMaterial.new()
	mat.flags_unshaded = true
	mat.albedo_color = Color(0.12, 0.53, 0.90, 0.8) # theme blue laser
	line.set_surface_material(0, mat)
	
	line.visible = false
	ray.add_child(line)

func _capture_canvas_layers():
	var root = get_tree().root
	hud = root.find_node("HUD", true, false)
	pause_menu = root.find_node("PauseMenu", true, false)
	win_screen = root.find_node("WinScreen", true, false)
	intro_tutorial = root.find_node("IntroTutorial", true, false)
	var main_menu = root.find_node("MainMenu", true, false)
	
	var vp = $VRViewport
	if hud:
		hud.custom_viewport = vp
	if pause_menu:
		pause_menu.custom_viewport = vp
	if win_screen:
		win_screen.custom_viewport = vp
	if intro_tutorial:
		intro_tutorial.custom_viewport = vp
	if main_menu:
		main_menu.custom_viewport = vp

func _process(delta):
	# Determine if any interactive menu is open
	var menu_open = false
	if pause_menu and pause_menu.visible:
		menu_open = true
	if win_screen and win_screen.visible:
		menu_open = true
	if intro_tutorial and intro_tutorial.visible:
		menu_open = true
	var main_menu = get_tree().root.find_node("MainMenu", true, false)
	if main_menu and main_menu.visible:
		menu_open = true
		
	if menu_open != was_menu_open:
		was_menu_open = menu_open
		if menu_open:
			_spawn_ui_in_front()
		else:
			$VRUIPlane.visible = false
			_hide_pointers()
			
	if not $VRUIPlane.visible:
		return
		
	# Process pointer input from active controllers
	var left = get_parent().get_node_or_null("LeftHandController")
	var right = get_parent().get_node_or_null("RightHandController")
	
	_process_pointer(left)
	_process_pointer(right)

func _spawn_ui_in_front():
	var cam = get_parent().get_node_or_null("ARVRCamera")
	if not cam:
		return
		
	$VRUIPlane.visible = true
	
	# Spawn 1.4m in front of camera
	var cam_transform = cam.global_transform
	var forward = -cam_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	
	var spawn_pos = cam_transform.origin + forward * 1.4
	spawn_pos.y = cam_transform.origin.y - 0.1 # slightly lower than eyes
	
	$VRUIPlane.global_transform.origin = spawn_pos
	
	# Rotate to face player (QuadMesh faces +Z)
	$VRUIPlane.look_at(cam_transform.origin, Vector3.UP)
	$VRUIPlane.rotate_object_local(Vector3.UP, PI)

func _hide_pointers():
	var left = get_parent().get_node_or_null("LeftHandController/UIRayCast/PointerLine")
	if left:
		left.visible = false
	var right = get_parent().get_node_or_null("RightHandController/UIRayCast/PointerLine")
	if right:
		right.visible = false

func _process_pointer(controller: ARVRController):
	if not controller or not controller.get_is_active():
		return
		
	var raycast = controller.get_node_or_null("UIRayCast")
	var line = controller.get_node_or_null("UIRayCast/PointerLine")
	if not raycast or not line:
		return
		
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var col_point = raycast.get_collision_point()
		var col_obj = raycast.get_collider()
		
		if col_obj == $VRUIPlane/StaticBody:
			line.visible = true
			
			# Align line length
			var dist = raycast.global_transform.origin.distance_to(col_point)
			line.scale.z = dist
			line.translation.z = -dist / 2.0
			
			# Map local coords
			var local_point = $VRUIPlane.to_local(col_point)
			var w = 1.5
			var h = 1.5
			var u = (local_point.x / w) + 0.5
			var v = 0.5 - (local_point.y / h)
			
			var vp = $VRViewport
			var pixel_pos = Vector2(u * vp.size.x, v * vp.size.y)
			
			# Mouse Motion
			var controller_id = controller.controller_id
			if not last_mouse_pos.has(controller_id):
				last_mouse_pos[controller_id] = Vector2()
				
			if pixel_pos != last_mouse_pos[controller_id]:
				var motion = InputEventMouseMotion.new()
				motion.position = pixel_pos
				motion.global_position = pixel_pos
				vp.input(motion)
				last_mouse_pos[controller_id] = pixel_pos
				
			# Mouse Button Click (trigger button is 15 in OpenXR, or check axis/grip)
			var is_trigger_pressed = controller.is_button_pressed(15) or controller.is_button_pressed(1)
			if not _is_clicked.has(controller_id):
				_is_clicked[controller_id] = false
				
			if is_trigger_pressed != _is_clicked[controller_id]:
				_is_clicked[controller_id] = is_trigger_pressed
				var click = InputEventMouseButton.new()
				click.position = pixel_pos
				click.global_position = pixel_pos
				click.button_index = BUTTON_LEFT
				click.pressed = is_trigger_pressed
				vp.input(click)
			return
			
	# Not pointing at UI: draw full laser pointing forward
	line.visible = true
	line.scale.z = 3.0
	line.translation.z = -1.5
