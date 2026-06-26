extends CanvasLayer

func _ready():
	# Memastikan kursor mouse muncul
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Start menu background music
	AudioManager.play_music("menu")
	
	# Menghubungkan tombol langsung lewat kode (Pengganti klik panel kanan)
	$Control/StartButton.connect("pressed", self, "_on_StartButton_pressed")
	$Control/SettingsButton.connect("pressed", self, "_on_SettingsButton_pressed")
	$Control/ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
	
	# Connect settings menu closed signal
	$Control/SettingsMenu.connect("closed", self, "_on_SettingsMenu_closed")
	
	if RunHistory:
		var pb = RunHistory.get_personal_best()
		if pb < 0:
			$Control/PBLabel.text = "Personal Best: No runs yet"
		else:
			var mins = int(pb) / 60
			var secs = int(pb) % 60
			var msecs = int((pb - int(pb)) * 100)
			$Control/PBLabel.text = "Personal Best: %02d:%02d.%02d" % [mins, secs, msecs]
			
		$Control/AttemptLabel.text = "Total Attempts: " + str(RunHistory.get_run_count())
	
	# Apply teal/blue theme
	$Control/Background.color = Color(0.93, 0.95, 0.98, 1.0)
	UITheme.style_label($Control/TitleLabel, 48, UITheme.COLOR_TEXT_DARK)
	UITheme.style_label($Control/SubtitleLabel, 22, UITheme.COLOR_TEXT_MUTED)
	UITheme.style_label($Control/PBLabel, 18, UITheme.COLOR_TEXT_MUTED)
	UITheme.style_label($Control/AttemptLabel, 18, UITheme.COLOR_TEXT_MUTED)
	UITheme.style_button($Control/StartButton)
	UITheme.style_button($Control/SettingsButton)
	UITheme.style_button($Control/ExitButton)

# Fungsi ini akan berjalan saat tombol Start Game diklik
func _on_StartButton_pressed():
	AudioManager.play_sfx("click")
	# Ganti "res://Lobbly.tscn" di bawah ini dengan nama file scene gameplay utamamu!
	get_tree().change_scene("res://Main.tscn")

# Fungsi ini akan berjalan saat tombol Settings diklik
func _on_SettingsButton_pressed():
	AudioManager.play_sfx("click")
	# Hide menu buttons, show settings panel
	$Control/TitleLabel.visible = false
	$Control/SubtitleLabel.visible = false
	$Control/PBLabel.visible = false
	$Control/AttemptLabel.visible = false
	$Control/StartButton.visible = false
	$Control/SettingsButton.visible = false
	$Control/ExitButton.visible = false
	
	$Control/SettingsMenu.visible = true

# Fungsi ini akan berjalan saat tombol Back di menu settings diklik
func _on_SettingsMenu_closed():
	$Control/SettingsMenu.visible = false
	
	# Show menu buttons again
	$Control/TitleLabel.visible = true
	$Control/SubtitleLabel.visible = true
	$Control/PBLabel.visible = true
	$Control/AttemptLabel.visible = true
	$Control/StartButton.visible = true
	$Control/SettingsButton.visible = true
	$Control/ExitButton.visible = true

# Fungsi ini akan berjalan saat tombol Exit diklik
func _on_ExitButton_pressed():
	AudioManager.play_sfx("click")
	get_tree().quit() # Perintah untuk menutup/keluar dari game

