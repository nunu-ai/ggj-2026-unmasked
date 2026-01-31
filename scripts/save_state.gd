class_name SaveStateClass
extends Node

enum State {
	Menu,
	Queue,
	Manage,
}

var menu_scene: PackedScene = preload("res://scenes/main_menu.tscn")
var queue_scene: PackedScene = preload("res://scenes/queue_scene.tscn")
var manage_scene: PackedScene = preload("res://scenes/manage_scene.tscn")

var state: State = State.Menu

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


## Loads the game state from a file.
func load():
	pass


## Saves the game state to a file.
func save():
	pass
