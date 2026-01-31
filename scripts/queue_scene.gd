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
			traits_text += "- %s\n" % t.display_value()
	$VBoxContainer/TraitsLabel.text = traits_text


func update_status() -> void:
	var day = SaveState.day
	var club = SaveState.club
	$VBoxContainer/StatusLabel.text = "Queue: %d | In Club: %d/%d" % [
		day.queue.size(), day.in_club.size(), club.capacity
	]
	# Disable accept if club is full
	$VBoxContainer/HBoxContainer/AcceptButton.disabled = day.is_club_full(club.capacity)
	
	# Update debug view
	update_debug_view()


func update_debug_view() -> void:
	var day = SaveState.day
	
	# Calculate total happiness/score
	var total_happiness = day.profit() - day.in_club.size() * 50  # Remove base profit to show just happiness
	$DebugPanel/VBoxContainer/TotalHappinessLabel.text = "Total Happiness: %d (Profit: $%.0f)" % [total_happiness / 10, day.profit()]
	
	# Build club members list with individual happiness
	if day.in_club.is_empty():
		$DebugPanel/VBoxContainer/ClubMembersLabel.text = "No members yet"
	else:
		var members_text = ""
		for person in day.in_club:
			# Calculate individual happiness contribution
			var trait_set = TraitSet.new(person.traits)
			var individual_score = 0
			for t in person.traits:
				individual_score += t.calc_score(trait_set)
			members_text += "%s (score: %d)\n" % [person.name, individual_score]
		$DebugPanel/VBoxContainer/ClubMembersLabel.text = members_text.strip_edges()


func _on_accept_button_pressed() -> void:
	SaveState.day.decide_current_person(true)
	update_display()


func _on_reject_button_pressed() -> void:
	SaveState.day.decide_current_person(false)
	update_display()


func _on_main_menu_button_pressed() -> void:
	SaveState.switch_to_state(SaveStateClass.State.Menu)
