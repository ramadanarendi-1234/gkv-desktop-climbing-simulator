extends Node

var is_vr_mode = false

func _ready():
	var interface = ARVRServer.find_interface("OpenXR")
	if interface and interface.initialize():
		is_vr_mode = true
		get_viewport().arvr = true
		
		print("VR mode active")
		
		var parent = get_parent()
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
		var look = parent.get_node_or_null("DesktopLook")
		if look:
			look.set_process(true)
			look.set_process_input(true)
			
		var move = parent.get_node_or_null("DesktopMovement")
		if move:
			move.set_process(true)
			
		var climb = parent.get_node_or_null("DesktopClimb")
		if climb:
			climb.set_process(true)
			
		var mc = parent.get_node_or_null("MovementControl")
		if mc:
			mc.desktop_mode = true
			
		call_deferred("_update_hud", true)

func _update_hud(show_crosshair):
	var hud = get_tree().get_root().find_node("HUD", true, false)
	if hud:
		var crosshair = hud.get_node_or_null("Control/Crosshair")
		if crosshair:
			crosshair.visible = show_crosshair
