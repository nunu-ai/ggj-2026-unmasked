extends Control


func _ready() -> void:
	update_display()


func update_display() -> void:
	$VBoxContainer/DayLabel.text = "Day: %d" % SaveState.club.day
	$VBoxContainer/MoneyLabel.text = "Money: $%d" % SaveState.club.money
	$VBoxContainer/CapacityLabel.text = "Capacity: %d" % SaveState.club.capacity


func _on_start_day_button_pressed() -> void:
	SaveState.start_day()


func _on_main_menu_button_pressed() -> void:
	SaveState.switch_to_state(SaveStateClass.State.Menu)
