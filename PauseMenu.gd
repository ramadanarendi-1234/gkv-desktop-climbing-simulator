extends CanvasLayer

func _ready():
	# Sembunyikan menu saat pertama kali game jalan
	self.visible = false
	
	# Hubungkan tombol otomatis lewat kode
	$Control/Panel/ResumeButton.connect("pressed", self, "_on_ResumeButton_pressed")
	$Control/Panel/RestartButton.connect("pressed", self, "_on_RestartButton_pressed")
	$Control/Panel/ExitButton.connect("pressed", self, "_on_ExitButton_pressed")

func _input(event):
	# Jika menekan tombol ESC (ui_cancel)
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
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
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_ResumeButton_pressed():
	toggle_pause() # Lanjutkan game

func _on_RestartButton_pressed():
	get_tree().paused = false
	self.visible = false
	if get_parent() and get_parent().has_method("reset_run"):
		get_parent().reset_run(true)
	else:
		get_tree().reload_current_scene() # Ulangi level

func _on_ExitButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://MainMenu.tscn") # Balik ke menu utama
