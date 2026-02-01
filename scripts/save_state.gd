class_name SaveStateClass
extends Node

const SAVE_FILE_PATH: String = "user://save_game.json"

enum State {
	Menu,
	Queue,
	Manage,
	GameOver,
}

const menu_scene: PackedScene = preload("res://scenes/main_menu.tscn")
const queue_scene: PackedScene = preload("res://scenes/queue_scene.tscn")
const manage_scene: PackedScene = preload("res://scenes/manage_scene.tscn")
const game_over_scene: PackedScene = preload("res://scenes/game_over.tscn")

# Management vars
var state: State = State.Menu

# Game state vars
var club: Club
var day: Day
var next_theme: DailyTheme  # Pre-generated theme for the upcoming day

func load_scene(scene: PackedScene):
	get_tree().call_deferred("change_scene_to_packed", scene)


func switch_to_state(new_state: State):
	self.state = new_state

	# Switch music based on scene
	# Club music plays in Manage and Queue (won't restart if already playing)
	if state == State.Manage or state == State.Queue:
		MusicManager.play_track(MusicManager.Track.CLUB)
	else:
		MusicManager.play_track(MusicManager.Track.MENU)

	if state == State.Menu:
		load_scene(menu_scene)
	elif state == State.Queue:
		load_scene(queue_scene)
	elif state == State.Manage:
		load_scene(manage_scene)
	elif state == State.GameOver:
		load_scene(game_over_scene)


func new_game():
	self.club = Club.new(5, 500)
	self.next_theme = DailyTheme.pick_random()
	switch_to_state(State.Manage)


func start_day():
	self.club.day += 1
	self.day = Day.new(self.club.day, next_theme)
	switch_to_state(State.Queue)


func end_day():
	self.club.money += int(self.day.profit(self.club.capacity))
	self.club.money -= self.club.rent()

	# Check for game over (bankruptcy)
	if self.club.money < 0:
		delete_save()  # Game is over, remove save file
		switch_to_state(State.GameOver)
	else:
		self.next_theme = DailyTheme.pick_random()
		switch_to_state(State.Manage)
		self.save()

## Loads the game state from a file.
## Returns true if successful, false otherwise.
func load() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return false

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to open save file: %s" % FileAccess.get_open_error())
		return false

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse save file: %s" % json.get_error_message())
		return false

	var data: Dictionary = json.data
	if not data.has("club"):
		push_error("Save file missing 'club' data")
		return false

	self.club = Club.load(data["club"])
	self.next_theme = DailyTheme.pick_random()

	return true


## Saves the game state to a file.
## Returns true if successful, false otherwise.
func save() -> bool:
	if self.club == null:
		push_error("Cannot save: no club data")
		return false

	var data: Dictionary = { }

	data["club"] = self.club.save()

	var json_string = JSON.stringify(data, "\t")

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Failed to open save file for writing: %s" % FileAccess.get_open_error())
		return false

	file.store_string(json_string)
	file.close()

	return true


## Returns true if a save file exists.
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)


## Deletes the save file (used when game is over).
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
