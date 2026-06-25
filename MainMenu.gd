extends CanvasLayer

func _ready():
	# Memastikan kursor mouse muncul
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Menghubungkan tombol langsung lewat kode (Pengganti klik panel kanan)
	$Control/StartButton.connect("pressed", self, "_on_StartButton_pressed")
	$Control/ExitButton.connect("pressed", self, "_on_ExitButton_pressed")
# Fungsi ini akan berjalan saat tombol Start Game diklik
func _on_StartButton_pressed():
	# Ganti "res://Lobbly.tscn" di bawah ini dengan nama file scene gameplay utamamu!
	get_tree().change_scene("res://Main.tscn")

# Fungsi ini akan berjalan saat tombol Exit diklik
func _on_ExitButton_pressed():
	get_tree().quit() # Perintah untuk menutup/keluar dari game
