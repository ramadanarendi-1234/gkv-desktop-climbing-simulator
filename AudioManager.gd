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

var preloaded_music = {}
var preloaded_sfx = {}

func _ready():
	# Allow music to continue playing when the game is paused
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	# Create music player node
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Preload all resources to eliminate load/I/O latency during gameplay
	_preload_resources()
	
	# Load persisted volume settings
	load_settings()
	
	# Apply loaded volumes to the audio buses
	set_music_volume(volume_music)
	set_sfx_volume(volume_sfx)

func _preload_resources():
	for key in music_tracks:
		var path = _resolve_audio_path(music_tracks[key])
		if path != "":
			var stream = load(path)
			if stream:
				preloaded_music[key] = stream
				print("AudioManager: Preloaded music track '", key, "' from ", path)
				
	for key in sfx_files:
		var path = _resolve_audio_path(sfx_files[key])
		if path != "":
			var stream = load(path)
			if stream:
				# Force disable looping for SFX at load time
				if "loop" in stream:
					stream.loop = false
				elif stream.has_method("set_loop"):
					stream.set_loop(false)
				elif "loop_mode" in stream:
					stream.loop_mode = 0 # AudioStreamSample.LOOP_DISABLED
				preloaded_sfx[key] = stream
				print("AudioManager: Preloaded SFX track '", key, "' from ", path)

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

func _resolve_audio_path(path: String) -> String:
	var file = File.new()
	if file.file_exists(path):
		return path
		
	var base_path = path.get_basename()
	
	# Check for .mp3 format
	var mp3_path = base_path + ".mp3"
	if file.file_exists(mp3_path):
		return mp3_path
		
	# Check for .ogg format
	var ogg_path = base_path + ".ogg"
	if file.file_exists(ogg_path):
		return ogg_path
		
	# Check for .wav format
	var wav_path = base_path + ".wav"
	if file.file_exists(wav_path):
		return wav_path
		
	return ""

func play_music(key: String):
	if current_music_key == key:
		return # Already playing this track
	
	current_music_key = key
	if not preloaded_music.has(key):
		music_player.stop()
		return
		
	var stream = preloaded_music[key]
	if stream:
		# Ensure the music loops
		if "loop" in stream:
			stream.loop = true
		elif stream.has_method("set_loop"):
			stream.set_loop(true)
		
		music_player.stream = stream
		music_player.play()

func stop_music():
	current_music_key = ""
	music_player.stop()

var sfx_cooldowns = {
	"grab": 150,
	"release": 150,
	"click": 100,
	"fall": 500,
	"win": 500,
	"menu_open": 200,
	"menu_close": 200
}
var sfx_last_played = {}
var active_sfx_players = {}

func play_sfx(key: String):
	print("DEBUG AudioManager.gd: play_sfx called with key: ", key)
	if not preloaded_sfx.has(key):
		print("AudioManager Error: Unknown or missing SFX key: " + key)
		return
		
	# Rate limit SFX to prevent double/continuous triggering
	var current_time = OS.get_ticks_msec()
	if sfx_last_played.has(key):
		var cooldown = sfx_cooldowns.get(key, 100)
		if current_time - sfx_last_played[key] < cooldown:
			print("DEBUG AudioManager.gd: play_sfx rate limit blocked key: ", key)
			return
	sfx_last_played[key] = current_time
		
	var stream = preloaded_sfx[key]
	if stream:
		# Stop existing sound of same key if already playing to avoid overlap
		stop_sfx(key)
			
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.bus = "SFX"
		player.stream = stream
		player.connect("finished", player, "queue_free")
		player.connect("finished", self, "_on_sfx_finished", [key, player])
		player.play()
		active_sfx_players[key] = player
		print("DEBUG AudioManager.gd: playing ", key)

func stop_sfx(key: String):
	if active_sfx_players.has(key):
		var player = active_sfx_players[key]
		if is_instance_valid(player):
			player.stop()
			player.queue_free()
		active_sfx_players.erase(key)

func _on_sfx_finished(key: String, player: AudioStreamPlayer):
	if active_sfx_players.has(key) and active_sfx_players[key] == player:
		active_sfx_players.erase(key)

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

