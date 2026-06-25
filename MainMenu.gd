extends CanvasLayer

func _ready():
	# Memastikan kursor mouse muncul dan bisa diklik di Main Menu
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Menghubungkan tombol secara otomatis lewat kode
	$Control/StartButton.connect("pressed", self, "_on_StartButton_pressed")
	$Control/ExitButton.connect("pressed", self, "_on_ExitButton_pressed")

# Fungsi ini akan berjalan saat tombol Start Game diklik
func _on_StartButton_pressed():
	# TUGAS: Ganti "res://Gameplay.tscn" di bawah ini dengan nama file scene memanjatmu!
	get_tree().change_scene("res://Gameplay.tscn")

# Fungsi ini akan berjalan saat tombol Exit diklik
func _on_ExitButton_pressed():
	get_tree().quit() # Mengeluarkan pemain dari game
