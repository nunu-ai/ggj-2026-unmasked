extends Panel

@onready var _settings_popup: PopupPanel = $SettingsPopup
@onready var _volume_slider: HSlider = $SettingsPopup/SettingsMargin/SettingsVBox/VolumeHBox/VolumeSlider
@onready var _volume_value_label: Label = $SettingsPopup/SettingsMargin/SettingsVBox/VolumeHBox/VolumeValue


func _ready() -> void:
	# Only show Continue button if there's a save file
	$VBoxContainer/ContinueButton.disabled = !SaveState.has_save()
	
	# Initialize volume slider from saved settings
	_volume_slider.value = MusicManager.get_volume()
	_update_volume_label(_volume_slider.value)


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
	_settings_popup.popup_centered()


func _on_settings_close_pressed() -> void:
	_settings_popup.hide()


func _on_volume_slider_value_changed(value: float) -> void:
	MusicManager.set_volume(value)
	_update_volume_label(value)


func _update_volume_label(volume_db: float) -> void:
	# Convert dB to percentage (0 dB = 100%, -40 dB = 0%)
	var percentage = int(((volume_db + 40.0) / 40.0) * 100.0)
	_volume_value_label.text = "%d%%" % percentage


func _on_exit_button_pressed() -> void:
	get_tree().quit()
