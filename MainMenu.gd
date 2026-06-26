extends CanvasLayer

func _ready():
	# Memastikan kursor mouse muncul
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Menghubungkan tombol langsung lewat kode (Pengganti klik panel kanan)
	$Control/StartButton.connect("pressed", self, "_on_StartButton_pressed")
	$Control/ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
	
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

# Fungsi ini akan berjalan saat tombol Start Game diklik
func _on_StartButton_pressed():
	# Ganti "res://Lobbly.tscn" di bawah ini dengan nama file scene gameplay utamamu!
	get_tree().change_scene("res://Main.tscn")

# Fungsi ini akan berjalan saat tombol Exit diklik
func _on_ExitButton_pressed():
	get_tree().quit() # Perintah untuk menutup/keluar dari game
