extends Node

const SETTINGS_FILE_PATH: String = "user://settings.json"

enum Track {
	MENU,
	CLUB,
}

var music_player: AudioStreamPlayer
var current_track: Track = Track.MENU
var volume_db: float = 0.0

var tracks: Dictionary = {
	Track.MENU: "res://assets/audio/Unmasked_menu.mp3",
	Track.CLUB: "res://assets/audio/Unmasked_club.mp3",
}

func _ready() -> void:
	# Load saved settings
	_load_settings()
	
	# Create the audio player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	music_player.volume_db = volume_db
	add_child(music_player)
	
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
	music_player.volume_db = volume_db
	_save_settings()

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
