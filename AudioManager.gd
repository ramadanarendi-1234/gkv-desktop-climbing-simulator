extends Node

var volume_music: float = 70.0
var volume_sfx: float = 70.0

var music_player: AudioStreamPlayer
var current_music_key: String = ""

var music_tracks = {
	"menu": "res://audio/music/menu_music.ogg",
	"game": "res://audio/music/gameplay_music.ogg"
}

var sfx_files = {
	"grab": "res://audio/sfx/grab.wav",
	"release": "res://audio/sfx/release.wav",
	"fall": "res://audio/sfx/fall.wav",
	"win": "res://audio/sfx/win.wav",
	"click": "res://audio/sfx/button_click.wav",
	"menu_open": "res://audio/sfx/menu_open.wav",
	"menu_close": "res://audio/sfx/menu_close.wav"
}

func _ready():
	# Allow music to continue playing when the game is paused
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	# Create music player node
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Load persisted volume settings
	load_settings()
	
	# Apply loaded volumes to the audio buses
	set_music_volume(volume_music)
	set_sfx_volume(volume_sfx)

func set_music_volume(value: float):
	volume_music = clamp(value, 0.0, 100.0)
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		if volume_music <= 0.0:
			AudioServer.set_bus_mute(bus_idx, true)
		else:
			AudioServer.set_bus_mute(bus_idx, false)
			# Convert 0-100 linear range to decibels
			var db = linear2db(volume_music / 100.0)
			AudioServer.set_bus_volume_db(bus_idx, db)
	save_settings()

func set_sfx_volume(value: float):
	volume_sfx = clamp(value, 0.0, 100.0)
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		if volume_sfx <= 0.0:
			AudioServer.set_bus_mute(bus_idx, true)
		else:
			AudioServer.set_bus_mute(bus_idx, false)
			# Convert 0-100 linear range to decibels
			var db = linear2db(volume_sfx / 100.0)
			AudioServer.set_bus_volume_db(bus_idx, db)
	save_settings()

func play_music(key: String):
	if current_music_key == key:
		return # Already playing this track
	
	current_music_key = key
	if not music_tracks.has(key):
		music_player.stop()
		return
		
	var path = music_tracks[key]
	var file = File.new()
	if not file.file_exists(path):
		print("AudioManager Warning: Music file not found at " + path)
		music_player.stop()
		return
		
	var stream = load(path)
	if stream:
		# Ensure the music loops
		if stream is AudioStreamOGGVorbis:
			stream.loop = true
		elif stream.has_method("set_loop"):
			stream.set_loop(true)
		
		music_player.stream = stream
		music_player.play()

func stop_music():
	current_music_key = ""
	music_player.stop()

func play_sfx(key: String):
	if not sfx_files.has(key):
		print("AudioManager Error: Unknown SFX key: " + key)
		return
		
	var path = sfx_files[key]
	var file = File.new()
	if not file.file_exists(path):
		# Quietly print warning so developers know, but don't crash the game
		print("AudioManager Warning: SFX file not found at " + path)
		return
		
	var stream = load(path)
	if stream:
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.bus = "SFX"
		player.stream = stream
		player.connect("finished", player, "queue_free")
		player.play()

func save_settings():
	var file = File.new()
	if file.open("user://settings.json", File.WRITE) == OK:
		var data = {
			"music_volume": volume_music,
			"sfx_volume": volume_sfx
		}
		file.store_string(JSON.print(data, "  "))
		file.close()

func load_settings():
	var file = File.new()
	if file.file_exists("user://settings.json"):
		if file.open("user://settings.json", File.READ) == OK:
			var text = file.get_as_text()
			file.close()
			var res = JSON.parse(text)
			if res.error == OK and typeof(res.result) == TYPE_DICTIONARY:
				var data = res.result
				if data.has("music_volume"):
					volume_music = float(data.music_volume)
				if data.has("sfx_volume"):
					volume_sfx = float(data.sfx_volume)
