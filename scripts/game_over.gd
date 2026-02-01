extends Control


func _ready() -> void:
	var days_survived = SaveState.club.day
	$VBoxContainer/DaysSurvivedLabel.text = "You survived %d day%s" % [days_survived, "s" if days_survived != 1 else ""]
	$VBoxContainer/FinalMoneyLabel.text = "Final Balance: $%d" % SaveState.club.money


func _on_main_menu_button_pressed() -> void:
	MusicManager.play_button_sfx()
	SaveState.switch_to_state(SaveStateClass.State.Menu)
