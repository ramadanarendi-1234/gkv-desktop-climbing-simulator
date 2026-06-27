extends CanvasLayer

func _ready():
	# Memastikan kursor mouse muncul
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Menghubungkan tombol langsung lewat kode
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
	
	# Apply background color and theme styles to existing elements
	$Control/Background.color = Color(0.93, 0.95, 0.98, 1.0)
	
	# Check if VR mode is active
	var vr_active = false
	if has_node("Player/VRDesktopSwitch"):
		vr_active = get_node("Player/VRDesktopSwitch").is_vr_mode
	if vr_active:
		$Control/Background.visible = false
		
	UITheme.style_label($Control/PBLabel, 18, UITheme.COLOR_TEXT_MUTED)
	UITheme.style_label($Control/AttemptLabel, 18, UITheme.COLOR_TEXT_MUTED)
	UITheme.style_button($Control/StartButton)
	UITheme.style_button($Control/SettingsButton)
	UITheme.style_button($Control/ExitButton)

	if UITheme.is_first_boot:
		UITheme.is_first_boot = false
		
		# Hide menu elements for loading screen
		$Control/GameLogo.visible = false
		$Control/PBLabel.visible = false
		$Control/AttemptLabel.visible = false
		$Control/StartButton.visible = false
		$Control/SettingsButton.visible = false
		$Control/ExitButton.visible = false
		$Control/DevLogoMain.visible = false
		
		# Start loading screen fade in & out using a Tween (5 seconds total)
		$Control/LoadingScreen.visible = true
		$Control/LoadingScreen.modulate.a = 0.0
		
		var tween = Tween.new()
		add_child(tween)
		# Fade in from 0 to 1 over 1.0s
		tween.interpolate_property($Control/LoadingScreen, "modulate:a", 0.0, 1.0, 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
		# Fade out from 1 to 0 over 1.0s starting at 4.0s
		tween.interpolate_property($Control/LoadingScreen, "modulate:a", 1.0, 0.0, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 4.0)
		tween.start()
		
		# Create a 5s timer for loading complete
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 5.0
		add_child(timer)
		timer.connect("timeout", self, "_on_loading_complete")
		timer.start()
	else:
		# Directly show menu elements
		$Control/LoadingScreen.visible = false
		$Control/GameLogo.visible = true
		$Control/PBLabel.visible = true
		$Control/AttemptLabel.visible = true
		$Control/StartButton.visible = true
		$Control/SettingsButton.visible = true
		$Control/ExitButton.visible = true
		$Control/DevLogoMain.visible = true
		
		# Start music directly
		AudioManager.play_music("menu")

func _on_loading_complete():
	# Hide loading screen completely
	$Control/LoadingScreen.visible = false
	
	# Show menu elements
	$Control/GameLogo.visible = true
	$Control/PBLabel.visible = true
	$Control/AttemptLabel.visible = true
	$Control/StartButton.visible = true
	$Control/SettingsButton.visible = true
	$Control/ExitButton.visible = true
	$Control/DevLogoMain.visible = true
	
	# Start menu background music
	AudioManager.play_music("menu")

# Fungsi ini akan berjalan saat tombol Start Game diklik
func _on_StartButton_pressed():
	AudioManager.play_sfx("click")
	
	# Create a black ColorRect overlay for fading out
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.anchor_right = 1.0
	fade_rect.anchor_bottom = 1.0
	fade_rect.modulate.a = 0.0
	$Control.add_child(fade_rect)
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(fade_rect, "modulate:a", 0.0, 1.0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(tween, "tween_all_completed")
	get_tree().change_scene("res://Main.tscn")

# Fungsi ini akan berjalan saat tombol Settings diklik
func _on_SettingsButton_pressed():
	AudioManager.play_sfx("click")
	$Control/GameLogo.visible = false
	$Control/PBLabel.visible = false
	$Control/AttemptLabel.visible = false
	$Control/StartButton.visible = false
	$Control/SettingsButton.visible = false
	$Control/ExitButton.visible = false
	$Control/DevLogoMain.visible = false
	
	$Control/SettingsMenu.visible = true

# Fungsi ini akan berjalan saat tombol Back di menu settings diklik
func _on_SettingsMenu_closed():
	$Control/SettingsMenu.visible = false
	
	# Show menu buttons again
	$Control/GameLogo.visible = true
	$Control/PBLabel.visible = true
	$Control/AttemptLabel.visible = true
	$Control/StartButton.visible = true
	$Control/SettingsButton.visible = true
	$Control/ExitButton.visible = true
	$Control/DevLogoMain.visible = true

# Fungsi ini akan berjalan saat tombol Exit diklik
func _on_ExitButton_pressed():
	AudioManager.play_sfx("click")
	get_tree().quit()



