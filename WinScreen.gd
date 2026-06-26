extends CanvasLayer

func _ready():
	# Sembunyikan screen saat pertama kali game jalan
	self.visible = false
	
	# Hubungkan tombol otomatis lewat kode
	$Control/Panel/PlayAgainButton.connect("pressed", self, "_on_PlayAgainButton_pressed")
	$Control/Panel/ExitButton.connect("pressed", self, "_on_ExitButton_pressed")

# Fungsi untuk dipanggil saat pemain menang
func show_win(time_string: String, is_new_pb: bool):
	self.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
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

