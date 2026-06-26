extends CanvasLayer

var is_minimized = false

func _ready():
	# Sembunyikan screen saat pertama kali game jalan
	self.visible = false
	
	# Hubungkan tombol otomatis lewat kode
	$Control/Panel/PlayAgainButton.connect("pressed", self, "_on_PlayAgainButton_pressed")
	$Control/Panel/ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
	$Control/Panel/MinimizeButton.connect("pressed", self, "_on_MinimizeButton_pressed")

func _input(event):
	# Jika screen kemenangan sedang aktif, izinkan toggle dengan tombol H atau TAB
	if visible and event is InputEventKey and event.pressed:
		if event.scancode == KEY_H or event.scancode == KEY_TAB:
			is_minimized = !is_minimized
			_update_ui_state()

func _update_ui_state():
	$Control/Panel.visible = !is_minimized
	$Control/BackgroundOverlay.visible = !is_minimized
	$Control/MinimizedHintLabel.visible = is_minimized
	
	if get_parent() and "hud" in get_parent() and get_parent().hud:
		get_parent().hud.results_panel.visible = !is_minimized
		
	if is_minimized:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Fungsi untuk dipanggil saat pemain menang
func show_win(time_string: String, is_new_pb: bool):
	self.visible = true
	is_minimized = false
	_update_ui_state()
	
	$Control/Panel/TimeLabel.text = "Final Time: " + time_string
	
	if is_new_pb:
		$Control/Panel/PBLabel.text = "⭐ New PB!"
	else:
		var pb = RunHistory.get_personal_best()
		if pb < 0:
			$Control/Panel/PBLabel.text = "PB: --:--.--"
		else:
			var mins = int(pb) / 60
			var secs = int(pb) % 60
			var msecs = int((pb - int(pb)) * 100)
			$Control/Panel/PBLabel.text = "PB: %02d:%02d.%02d" % [mins, secs, msecs]

func _on_PlayAgainButton_pressed():
	self.visible = false
	if get_parent() and get_parent().has_method("reset_run"):
		get_parent().reset_run(true)
	else:
		get_tree().reload_current_scene()

func _on_ExitButton_pressed():
	get_tree().change_scene("res://MainMenu.tscn")

func _on_MinimizeButton_pressed():
	is_minimized = true
	_update_ui_state()




