extends Panel


func _ready() -> void:
	# Only show Continue button if there's a save file
	$VBoxContainer/ContinueButton.disabled = !SaveState.has_save()


func _on_new_game_button_pressed() -> void:
	SaveState.new_game()


func _on_continue_button_pressed() -> void:
	SaveState.load()
	SaveState.switch_to_state(SaveStateClass.State.Manage)

func _on_settings_button_pressed() -> void:
	pass

func _on_exit_button_pressed() -> void:
	get_tree().quit()
