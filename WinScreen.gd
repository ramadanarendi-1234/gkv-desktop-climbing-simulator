extends CanvasLayer

var is_minimized = false

func _ready():
	# Sembunyikan screen saat pertama kali game jalan
	self.visible = false
	
	# Hubungkan tombol otomatis lewat kode
	$Control/Panel/PlayAgainButton.connect("pressed", self, "_on_PlayAgainButton_pressed")
	$Control/Panel/ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
	$Control/Panel/MinimizeButton.connect("pressed", self, "_on_MinimizeButton_pressed")
	
	# Apply teal/blue theme
	UITheme.style_panel_dark($Control/Panel)
	UITheme.style_label($Control/Panel/WinLabel, 30)
	UITheme.style_label($Control/Panel/SubWinLabel, 20, UITheme.COLOR_TEXT_LIGHT)
	UITheme.style_label($Control/Panel/TimeLabel, 24)
	UITheme.style_label($Control/Panel/PBLabel, 18, UITheme.COLOR_TEXT_LIGHT)
	UITheme.style_label($Control/Panel/HideHintLabel, 14, UITheme.COLOR_TEXT_LIGHT)
	UITheme.style_button($Control/Panel/PlayAgainButton)
	UITheme.style_button($Control/Panel/ExitButton)
	UITheme.style_button($Control/Panel/MinimizeButton, 16)
	UITheme.style_label($Control/MinimizedHintLabel, 16, UITheme.COLOR_TEXT_LIGHT)

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
	AudioManager.play_sfx("click")
	self.visible = false
	if get_parent() and get_parent().has_method("reset_run"):
		get_parent().reset_run(true)
	else:
		get_tree().reload_current_scene()

func _on_ExitButton_pressed():
	AudioManager.play_sfx("click")
	get_tree().change_scene("res://MainMenu.tscn")

func _on_MinimizeButton_pressed():
	AudioManager.play_sfx("click")
	is_minimized = true
	_update_ui_state()




