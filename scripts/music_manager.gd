extends Node

const SETTINGS_FILE_PATH: String = "user://settings.json"

enum Track {
	MENU,
	CLUB,
}

enum SFX {
	BUTTON,
	REROLL,
}

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var current_track: Track = Track.MENU
var volume_db: float = 0.0

var tracks: Dictionary = {
	Track.MENU: "res://assets/audio/Unmasked_menu.mp3",
	Track.CLUB: "res://assets/audio/Unmasked_club.mp3",
}

var sfx: Dictionary = {
	SFX.BUTTON: "res://assets/audio/button.mp3",
	SFX.REROLL: "res://assets/audio/reroll.mp3",
}

func _ready() -> void:
	# Load saved settings
	_load_settings()
	
	# Calculate actual volume (mute at minimum slider value)
	var actual_volume: float = -80.0 if volume_db <= -39.9 else volume_db
	
	# Create the audio player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	music_player.volume_db = actual_volume
	add_child(music_player)
	
	# Create the SFX player
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	sfx_player.volume_db = actual_volume
	add_child(sfx_player)
	
	# Connect to the finished signal to loop the music
	music_player.finished.connect(_on_music_finished)
	
	# Start with menu music
	play_track(Track.MENU)

func _on_music_finished() -> void:
	# Loop the music
	music_player.play()

func play_track(track: Track) -> void:
	if current_track == track and music_player.playing:
		return  # Already playing this track
	
	current_track = track
	var music = load(tracks[track])
	if music:
		music_player.stream = music
		music_player.play()

func set_volume(new_volume_db: float) -> void:
	volume_db = new_volume_db
	# At minimum slider value (-40 dB), mute completely
	# Otherwise use the actual dB value
	var actual_volume: float = -80.0 if volume_db <= -39.9 else volume_db
	music_player.volume_db = actual_volume
	sfx_player.volume_db = actual_volume
	_save_settings()

func play_sfx(sound: SFX) -> void:
	var audio = load(sfx[sound])
	if audio:
		sfx_player.stream = audio
		sfx_player.play()

func play_button_sfx() -> void:
	play_sfx(SFX.BUTTON)

func play_reroll_sfx() -> void:
	play_sfx(SFX.REROLL)

func get_volume() -> float:
	return volume_db

func stop() -> void:
	music_player.stop()

func play() -> void:
	if not music_player.playing:
		music_player.play()

func _save_settings() -> void:
	var data = {
		"volume_db": volume_db
	}
	var json_string = JSON.stringify(data)
	var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()

func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		return
	
	var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
	if not file:
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) == OK:
		var data = json.data
		if data.has("volume_db"):
			volume_db = data["volume_db"]
