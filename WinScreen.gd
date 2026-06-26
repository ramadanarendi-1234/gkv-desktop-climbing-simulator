extends CanvasLayer

func _ready():
	# Memastikan mouse muncul saat menang agar bisa klik tombol
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Hubungkan tombol otomatis lewat kode
	$Control/Panel/PlayAgainButton.connect("pressed", self, "_on_PlayAgainButton_pressed")
	$Control/Panel/ExitButton.connect("pressed", self, "_on_ExitButton_pressed")

# Fungsi untuk dipanggil saat pemain menang (untuk mengirim hasil waktu)
func set_final_time(time_string):
	$Control/Panel/TimeLabel.text = "Final Time: " + time_string

func _on_PlayAgainButton_pressed():
	# Ganti "res://Gameplay.tscn" dengan nama scene memanjatmu!
	get_tree().change_scene("res://Gameplay.tscn")

func _on_ExitButton_pressed():
	get_tree().change_scene("res://MainMenu.tscn")
