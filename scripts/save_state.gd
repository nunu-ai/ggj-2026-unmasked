class_name SaveStateClass
extends Node

const SAVE_FILE_PATH: String = "user://save_game.json"

enum State {
	Menu,
	Queue,
	Manage,
}

const menu_scene: PackedScene = preload("res://scenes/main_menu.tscn")
const queue_scene: PackedScene = preload("res://scenes/queue_scene.tscn")
const manage_scene: PackedScene = preload("res://scenes/manage_scene.tscn")

# Management vars
var state: State = State.Menu

# Game state vars
var club: Club
var day: Day


class Club:
	var day: int = 1
	var money: int
	var capacity: int


	func _init(_capacity: int, _money: int):
		self.capacity = _capacity
		self.money = _money


	func rent() -> int:
		return int(capacity * 200 * (1.3 ** day))


	static func load(data: Dictionary):
		var me = Club.new(data["capacity"], data["money"])

		return me


	func save():
		var data = Dictionary()
		data["capacity"] = self.capacity
		data["money"] = self.money

		return data


func load_scene(scene: PackedScene):
	get_tree().call_deferred("change_scene_to_packed", scene)


func switch_to_state(new_state: State):
	self.state = new_state

	if state == State.Menu:
		load_scene(menu_scene)
	elif state == State.Queue:
		load_scene(queue_scene)
	elif state == State.Manage:
		load_scene(manage_scene)


func new_game():
	self.club = Club.new(5, 100)
	switch_to_state(State.Manage)


func start_day():
	self.club.day += 1
	self.day = Day.new(self.club.day)
	switch_to_state(State.Queue)


func end_day():
	self.club.money += self.day.profit()
	self.club.money -= self.day.rent()
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
