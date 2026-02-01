extends Panel


func _ready() -> void:
	# Only show Continue button if there's a save file
	$VBoxContainer/ContinueButton.disabled = !SaveState.has_save()


func _on_new_game_button_pressed() -> void:
	SaveState.new_game()


func _on_continue_button_pressed() -> void:
	if SaveState.load():
		# Check if player has already lost (money < 0)
		if SaveState.club.money < 0:
			SaveState.delete_save()
			SaveState.switch_to_state(SaveStateClass.State.GameOver)
		else:
			SaveState.switch_to_state(SaveStateClass.State.Manage)

func _on_settings_button_pressed() -> void:
	pass

func _on_exit_button_pressed() -> void:
	get_tree().quit()
