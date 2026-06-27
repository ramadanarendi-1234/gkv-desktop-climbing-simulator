extends Node

var is_vr_mode = false

func _ready():
	var interface = ARVRServer.find_interface("OpenXR")
	if interface and interface.initialize():
		is_vr_mode = true
		get_viewport().arvr = true
		
		print("VR mode active")
		
		var parent = get_parent()
		
		# Setup VR 3D Floating UI
		var vrui_script = load("res://player/VRUI.gd")
		var vrui = Spatial.new()
		vrui.name = "VRUI"
		vrui.set_script(vrui_script)
		parent.add_child(vrui)
		
		# Setup camera fade
		var camera = parent.get_node_or_null("ARVRCamera")
		if camera:
			_setup_camera_fade(camera)
			
		var look = parent.get_node_or_null("DesktopLook")
		if look:
			look.set_process(false)
			look.set_process_input(false)
			
		var move = parent.get_node_or_null("DesktopMovement")
		if move:
			move.set_process(false)
			
		var climb = parent.get_node_or_null("DesktopClimb")
		if climb:
			climb.set_process(false)
			
		var mc = parent.get_node_or_null("MovementControl")
		if mc:
			mc.desktop_mode = false
			
		call_deferred("_update_hud", false)
	else:
		is_vr_mode = false
		get_viewport().arvr = false
		
		print("Desktop mode - no VR headset detected")
		
		var parent = get_parent()
		var is_main_menu = get_tree().current_scene.name == "MainMenu"
		
		# Setup camera fade
		var camera = parent.get_node_or_null("ARVRCamera")
		if camera:
			_setup_camera_fade(camera)
			
		var look = parent.get_node_or_null("DesktopLook")
		if look:
			look.set_process(not is_main_menu)
			look.set_process_input(not is_main_menu)
			
		var move = parent.get_node_or_null("DesktopMovement")
		if move:
			move.set_process(not is_main_menu)
			
		var climb = parent.get_node_or_null("DesktopClimb")
		if climb:
			climb.set_process(not is_main_menu)
			
		var mc = parent.get_node_or_null("MovementControl")
		if mc:
			mc.desktop_mode = true
			
		call_deferred("_update_hud", not is_main_menu)

func _update_hud(show_crosshair):
	var hud = get_tree().get_root().find_node("HUD", true, false)
	if hud:
		var crosshair = hud.get_node_or_null("Control/Crosshair")
		if crosshair:
			crosshair.visible = show_crosshair

func _setup_camera_fade(camera: Camera):
	if not camera:
		return
		
	# Create MeshInstance for fade overlay
	var fade_mesh = MeshInstance.new()
	fade_mesh.name = "CameraFade"
	
	var quad = QuadMesh.new()
	quad.size = Vector2(1.0, 1.0)
	fade_mesh.mesh = quad
	
	var mat = SpatialMaterial.new()
	mat.flags_transparent = true
	mat.flags_unshaded = true
	mat.albedo_color = Color(0, 0, 0, 1.0) # Start fully black
	fade_mesh.set_surface_material(0, mat)
	
	camera.add_child(fade_mesh)
	fade_mesh.translation = Vector3(0, 0, -0.1) # 10cm in front of camera
	
	# Fade out black to transparent over 1.5s
	var tween = Tween.new()
	fade_mesh.add_child(tween)
	tween.interpolate_property(mat, "albedo_color:a", 1.0, 0.0, 1.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
	
	# Clean up after fade is complete
	yield(get_tree().create_timer(1.6), "timeout")
	if is_instance_valid(fade_mesh):
		fade_mesh.queue_free()

