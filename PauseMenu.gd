extends CanvasLayer

func _ready():
	# Sembunyikan menu saat pertama kali game jalan
	self.visible = false
	
	# Hubungkan tombol otomatis lewat kode
	$Control/Panel/ResumeButton.connect("pressed", self, "_on_ResumeButton_pressed")
	$Control/Panel/RestartButton.connect("pressed", self, "_on_RestartButton_pressed")
	$Control/Panel/SettingsButton.connect("pressed", self, "_on_SettingsButton_pressed")
	$Control/Panel/ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
	
	# Hubungkan signal closed settings
	$Control/SettingsMenu.connect("closed", self, "_on_SettingsMenu_closed")

func _input(event):
	# Jika menekan tombol ESC (ui_cancel)
	if event.is_action_pressed("ui_cancel"):
		# Check if settings menu is open, close it first
		if visible and $Control/SettingsMenu.visible:
			_on_SettingsMenu_closed()
			get_tree().set_input_as_handled()
		else:
			toggle_pause()

func toggle_pause():
	# Block pause if intro tutorial is open
	var intro = get_parent().get_node_or_null("IntroTutorial")
	if intro and intro.visible:
		return
	
	# Blokir pause jika sedang di screen kemenangan
	if get_parent() and "state" in get_parent() and "GameState" in get_parent():
		if get_parent().state == get_parent().GameState.SUMMIT:
			return

	# Membalikkan status pause game
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	self.visible = new_pause_state
	
	# Tampilkan mouse jika sedang pause
	if new_pause_state:
		AudioManager.play_sfx("menu_open")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		AudioManager.play_sfx("menu_close")
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		# Reset menu states
		$Control/Panel.visible = true
		$Control/SettingsMenu.visible = false

func _on_ResumeButton_pressed():
	AudioManager.play_sfx("click")
	toggle_pause() # Lanjutkan game

func _on_RestartButton_pressed():
	AudioManager.play_sfx("click")
	get_tree().paused = false
	self.visible = false
	if get_parent() and get_parent().has_method("reset_run"):
		get_parent().reset_run(true)
	else:
		get_tree().reload_current_scene() # Ulangi level

func _on_SettingsButton_pressed():
	AudioManager.play_sfx("click")
	$Control/Panel.visible = false
	$Control/SettingsMenu.visible = true

func _on_SettingsMenu_closed():
	$Control/SettingsMenu.visible = false
	$Control/Panel.visible = true

func _on_ExitButton_pressed():
	AudioManager.play_sfx("click")
	get_tree().paused = false
	get_tree().change_scene("res://MainMenu.tscn") # Balik ke menu utama

