extends Control


func _ready() -> void:
	# Only show Continue button if there's a save file
	$VBoxContainer/ContinueButton.visible = SaveState.has_save()


func _on_new_game_button_pressed() -> void:
	SaveState.new_game()


func _on_continue_button_pressed() -> void:
	SaveState.load()
	SaveState.switch_to_state(SaveStateClass.State.Manage)
