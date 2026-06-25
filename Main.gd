extends Spatial

enum GameState { WAITING, CLIMBING, SUMMIT, FELL }
var state = GameState.WAITING

onready var player = $Player
onready var movement_control = $Player/MovementControl
onready var hud = $HUD

func _ready():
	if movement_control:
		movement_control.connect("first_grab", self, "_on_first_grab")
		movement_control.connect("player_fell", self, "_on_player_fell")
		movement_control.connect("player_height_changed", self, "_on_player_height_changed")
		
	var desktop_climb = $Player.get_node_or_null("DesktopClimb")
	if desktop_climb:
		desktop_climb.connect("first_grab", self, "_on_first_grab")
		
	var summit_zone = get_node_or_null("SummitZone")
	if summit_zone:
		summit_zone.connect("summit_reached", self, "_on_summit_reached")

func _process(delta):
	# Fall detection for desktop mode (hitting the ground while climbing)
	if state == GameState.CLIMBING:
		var desktop_move = $Player.get_node_or_null("DesktopMovement")
		if desktop_move and desktop_move.is_grounded:
			var desktop_climb = $Player.get_node_or_null("DesktopClimb")
			if desktop_climb and not desktop_climb.is_climbing:
				_on_player_fell()

func _input(event):
	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		get_tree().quit()
		
	if event is InputEventKey and event.scancode == KEY_R and event.pressed:
		reset_run()
		
	if event is InputEventJoypadButton and event.button_index == 1 and event.pressed:
		reset_run()

func _on_first_grab():
	if state == GameState.WAITING:
		state = GameState.CLIMBING
		if hud:
			hud.start_timer()

func _on_player_height_changed(y):
	if hud:
		hud.update_height(y)

func _on_player_fell():
	if state == GameState.CLIMBING:
		state = GameState.FELL
		RunHistory.save_run(hud.current_time, false)
		reset_run()

func _on_summit_reached():
	if state == GameState.CLIMBING:
		state = GameState.SUMMIT
		if hud:
			hud.stop_timer()
			var prev_pb = RunHistory.get_personal_best()
			RunHistory.save_run(hud.current_time, true)
			var new_pb = RunHistory.get_personal_best()
			var is_new_pb = (prev_pb < 0) or (new_pb < prev_pb)
			hud.show_results(is_new_pb)

func reset_run():
	state = GameState.WAITING
	if movement_control:
		movement_control.force_release()
		movement_control.reset_position()
	
	var desktop_climb = $Player.get_node_or_null("DesktopClimb")
	if desktop_climb:
		desktop_climb.has_grabbed_once = false
		desktop_climb.left_hand_hold = null
		desktop_climb.right_hand_hold = null
		
	if hud:
		hud.reset_timer()
