extends Control

@export var name_label: Label
@export var status_label: Label
@export var traits_label: Label
@export var accept_button: Button
@export var reject_button: Button

func _ready() -> void:
	update_display()


func update_display() -> void:
	# Check if day exists (might be null if scene is run directly)
	if SaveState.day == null:
		push_warning("QueueScene: No day initialized, returning to menu")
		SaveState.switch_to_state(SaveStateClass.State.Menu)
		return

	var person = SaveState.day.current_person()
	if person == null:
		# Queue empty - end day
		SaveState.end_day()
		return

	name_label.text = person.name
	display_traits(person)
	update_status()


func display_traits(person: Person) -> void:
	var traits_text = ""
	for t in person.traits:
		if not t.hidden():
			traits_text += "- %s\n" % t.description()
	traits_label.text = traits_text


func update_status() -> void:
	var day = SaveState.day
	var club = SaveState.club
	status_label.text = "Queue: %d | In Club: %d/%d" % [
		day.queue.size(), day.in_club.size(), club.capacity
	]
	# Disable accept if club is full
	accept_button.disabled = day.is_club_full(club.capacity)

	# Update debug view
	update_debug_view()


func update_debug_view() -> void:
	var day = SaveState.day

	# Calculate total happiness/score
	var total_happiness = day.profit() - day.in_club.size() * 50  # Remove base profit to show just happiness
	$DebugPanel/VBoxContainer/TotalHappinessLabel.text = "Total Happiness: %d (Profit: $%.0f)" % [total_happiness / 10, day.profit()]

	# Clear existing entries
	var members_list = $DebugPanel/VBoxContainer/ClubMembersScroll/ClubMembersList
	for child in members_list.get_children():
		child.queue_free()

	# Build club members list with individual happiness
	if day.in_club.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No members yet"
		empty_label.add_theme_font_size_override("font_size", 12)
		members_list.add_child(empty_label)
	else:
		# Create combined trait set of all club members for accurate scoring
		var all_traits: Array[Trait] = []
		for person in day.in_club:
			all_traits.append_array(person.traits)
		var combined_trait_set = TraitSet.new(all_traits)

		for person in day.in_club:
			# Calculate individual happiness contribution using the combined trait set
			var individual_score = 0
			var trait_scores: Array[Dictionary] = []

			for t in person.traits:
				var score = t.calc_score(combined_trait_set)
				individual_score += score
				if score != 0:
					trait_scores.append({"trait": t, "score": score})

			# Create expandable entry for this person
			var entry = _create_person_debug_entry(person, individual_score, trait_scores)
			members_list.add_child(entry)


## Creates a clickable debug entry for a person with expandable trait breakdown
func _create_person_debug_entry(person: Person, total_score: int, trait_scores: Array[Dictionary]) -> Control:
	var container = VBoxContainer.new()

	# Header button showing person name and total score
	var header_btn = Button.new()
	var score_prefix = "+" if total_score > 0 else ""
	header_btn.text = "%s (%s%d)" % [person.name, score_prefix, total_score]
	header_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header_btn.add_theme_font_size_override("font_size", 12)

	# Color code based on score
	if total_score > 0:
		header_btn.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	elif total_score < 0:
		header_btn.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

	container.add_child(header_btn)

	# Details panel (hidden by default)
	var details_panel = PanelContainer.new()
	details_panel.visible = false
	details_panel.name = "DetailsPanel"

	var details_vbox = VBoxContainer.new()
	details_panel.add_child(details_vbox)

	if trait_scores.is_empty():
		var no_effect_label = Label.new()
		no_effect_label.text = "  No trait effects"
		no_effect_label.add_theme_font_size_override("font_size", 10)
		no_effect_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		details_vbox.add_child(no_effect_label)
	else:
		for ts in trait_scores:
			var trait_label = Label.new()
			var t: Trait = ts["trait"]
			var score: int = ts["score"]
			var prefix = "+" if score > 0 else ""
			trait_label.text = "  %s: %s%d" % [t.display_value(), prefix, score]
			trait_label.add_theme_font_size_override("font_size", 10)

			if score > 0:
				trait_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
			else:
				trait_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))

			details_vbox.add_child(trait_label)

	container.add_child(details_panel)

	# Connect button to toggle details visibility
	header_btn.pressed.connect(func(): details_panel.visible = not details_panel.visible)

	return container


func _on_accept_button_pressed() -> void:
	SaveState.day.decide_current_person(true)
	update_display()


func _on_reject_button_pressed() -> void:
	SaveState.day.decide_current_person(false)
	update_display()


func _on_main_menu_button_pressed() -> void:
	SaveState.switch_to_state(SaveStateClass.State.Menu)
