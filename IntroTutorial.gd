extends CanvasLayer

signal tutorial_closed

var current_page = 0
var pages = []

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	self.visible = false
	_setup_pages()
	
	$Control/Panel/NextButton.connect("pressed", self, "_on_NextButton_pressed")
	$Control/Panel/BackButton.connect("pressed", self, "_on_BackButton_pressed")
	$Control/Panel/SkipButton.connect("pressed", self, "_on_SkipButton_pressed")
	
	# Apply teal/blue theme
	UITheme.style_panel_dark($Control/Panel)
	UITheme.style_label_with_pill($Control/Panel/TitleLabel, UITheme.COLOR_TITLE_PILL, 26)
	UITheme.style_label_with_pill($Control/Panel/BodyLabel, UITheme.COLOR_BODY_PILL, 17)
	UITheme.style_label($Control/Panel/PageLabel, 18, UITheme.COLOR_TEXT_MUTED)
	$Control/Panel/Separator.visible = false
	UITheme.style_button($Control/Panel/NextButton, 18)
	UITheme.style_button($Control/Panel/BackButton, 18)
	UITheme.style_button($Control/Panel/SkipButton, 14)

func _setup_pages():
	pages = [
		{
			"title": "Selamat Datang di Cliffer Climbing",
			"body": "Anda akan mempelajari teknik dasar panjat tebing sebelum memulai simulasi.\n\nIkuti setiap langkah dengan baik agar memahami cara memanjat secara aman dan efisien."
		},
		{
			"title": "Tujuan Simulasi",
			"body": "Pada simulasi ini Anda harus mencapai puncak tebing dengan:\n\n•  Memilih pegangan yang tepat.\n•  Mengatur pergerakan secara efisien.\n•  Menghemat stamina selama pendakian.\n\nKeberhasilan bergantung pada strategi, bukan hanya kecepatan."
		},
		{
			"title": "Persiapan Sebelum Memanjat",
			"body": "Sebelum memulai pendakian:\n\n•  Pastikan posisi awal sudah benar.\n•  Amati jalur pegangan yang tersedia.\n•  Rencanakan rute menuju puncak.\n\nPerencanaan yang baik akan mengurangi kesalahan saat memanjat."
		},
		{
			"title": "Mengenali Hand Hold",
			"body": "Hand Hold merupakan titik pegangan yang digunakan untuk menopang tubuh saat memanjat.\n\nGunakan pegangan yang berada dalam jangkauan agar perpindahan lebih stabil."
		},
		{
			"title": "Three-Point Contact",
			"body": "Selalu usahakan tiga titik tubuh tetap menopang tubuh.\n\nContohnya:\n•  Dua tangan dan satu kaki\n•  Dua kaki dan satu tangan\n\nTeknik ini membantu menjaga keseimbangan selama pendakian."
		},
		{
			"title": "Teknik Perpindahan",
			"body": "Saat berpindah:\n\n•  Pastikan pegangan berikutnya aman.\n•  Pindahkan satu anggota tubuh terlebih dahulu.\n•  Jaga keseimbangan sebelum melanjutkan.\n\nHindari bergerak terlalu cepat."
		},
		{
			"title": "Capai Puncak",
			"body": "Lanjutkan pendakian hingga mencapai titik akhir.\n\nKeberhasilan ditentukan oleh kemampuan memilih jalur dan menjaga keseimbangan.\n\nSelamat mencoba!"
		}
	]

func show_tutorial():
	current_page = 0
	self.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_update_page()
	
	# Fade in the tutorial panel smoothly after the camera fade-in has progressed (1.2s delay)
	$Control.modulate.a = 0.0
	var tween = Tween.new()
	tween.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(tween)
	tween.interpolate_property($Control, "modulate:a", 0.0, 1.0, 0.6, Tween.TRANS_SINE, Tween.EASE_OUT, 1.2)
	tween.start()

func _update_page():
	var page = pages[current_page]
	$Control/Panel/TitleLabel.text = page["title"]
	$Control/Panel/BodyLabel.text = page["body"]
	$Control/Panel/PageLabel.text = str(current_page + 1) + " / " + str(pages.size())
	
	# Show/hide Back button
	$Control/Panel/BackButton.visible = current_page > 0
	
	# Change Next button text on last page
	if current_page == pages.size() - 1:
		$Control/Panel/NextButton.text = "Mulai!"
	else:
		$Control/Panel/NextButton.text = "Next >"

func _on_NextButton_pressed():
	AudioManager.play_sfx("click")
	if current_page < pages.size() - 1:
		current_page += 1
		_update_page()
	else:
		_close_tutorial()

func _on_BackButton_pressed():
	AudioManager.play_sfx("click")
	if current_page > 0:
		current_page -= 1
		_update_page()

func _on_SkipButton_pressed():
	AudioManager.play_sfx("click")
	_close_tutorial()

func _close_tutorial():
	# Fade out the tutorial panel smoothly
	var tween = Tween.new()
	tween.pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(tween)
	tween.interpolate_property($Control, "modulate:a", $Control.modulate.a, 0.0, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	tween.queue_free()
	
	self.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("tutorial_closed")
