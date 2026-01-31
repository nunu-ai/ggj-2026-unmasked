extends Control


func _ready() -> void:
	update_display()


func update_display() -> void:
	var person = SaveState.day.current_person()
	if person == null:
		# Queue empty - end day
		SaveState.end_day()
		return
	
	$VBoxContainer/NameLabel.text = person.name
	display_traits(person)
	update_status()


func display_traits(person: Person) -> void:
	var traits_text = ""
	for t in person.traits:
		if not t.hidden():
			traits_text += "- %s\n" % t.description()
	$VBoxContainer/TraitsLabel.text = traits_text


func update_status() -> void:
	var day = SaveState.day
	var club = SaveState.club
	$VBoxContainer/StatusLabel.text = "Queue: %d | In Club: %d/%d" % [
		day.queue.size(), day.in_club.size(), club.capacity
	]
	# Disable accept if club is full
	$VBoxContainer/HBoxContainer/AcceptButton.disabled = day.is_club_full(club.capacity)


func _on_accept_button_pressed() -> void:
	SaveState.day.decide_current_person(true)
	update_display()


func _on_reject_button_pressed() -> void:
	SaveState.day.decide_current_person(false)
	update_display()


func _on_main_menu_button_pressed() -> void:
	SaveState.switch_to_state(SaveStateClass.State.Menu)
