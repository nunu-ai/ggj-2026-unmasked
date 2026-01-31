class_name DebugPanel
extends PanelContainer


## Updates the debug view with current day data
func update_view() -> void:
	var day = SaveState.day

	# Calculate total happiness/score
	var total_happiness = day.profit() - day.in_club.size() * 50  # Remove base profit to show just happiness
	$VBoxContainer/TotalHappinessLabel.text = "Total Happiness: %d (Profit: $%.0f)" % [total_happiness / 10, day.profit()]

	# Clear existing entries
	var members_list = $VBoxContainer/ClubMembersScroll/ClubMembersList
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
			var trait_data: Array[Dictionary] = []

			for t in person.traits:
				var score = t.calc_score(combined_trait_set)
				var explanations = t.explain_score(combined_trait_set, day.in_club)
				individual_score += score
				trait_data.append({
					"trait": t,
					"score": score,
					"explanations": explanations
				})

			# Create expandable entry for this person
			var entry = _create_person_debug_entry(person, individual_score, trait_data)
			members_list.add_child(entry)


## Creates a clickable debug entry for a person with expandable trait breakdown
func _create_person_debug_entry(person: Person, total_score: int, trait_data: Array[Dictionary]) -> Control:
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

	# Show ALL traits, grouped by whether they affect score
	if trait_data.is_empty():
		var no_traits_label = Label.new()
		no_traits_label.text = "  No traits"
		no_traits_label.add_theme_font_size_override("font_size", 10)
		no_traits_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		details_vbox.add_child(no_traits_label)
	else:
		for td in trait_data:
			var t: Trait = td["trait"]
			var score: int = td["score"]
			var explanations: Array = td["explanations"]
			
			# Create entry for this trait
			var trait_entry = _create_trait_entry(t, score, explanations)
			details_vbox.add_child(trait_entry)

	container.add_child(details_panel)

	# Connect button to toggle details visibility
	header_btn.pressed.connect(func(): details_panel.visible = not details_panel.visible)

	return container


## Creates a trait entry, expandable if it has score effects
func _create_trait_entry(t: Trait, score: int, explanations: Array) -> Control:
	var has_effect = score != 0
	
	if not has_effect:
		# Simple label for traits without score effects
		var trait_label = Label.new()
		trait_label.text = "  %s" % t.display_value()
		trait_label.add_theme_font_size_override("font_size", 10)
		trait_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		return trait_label
	
	# Expandable entry for traits with score effects
	var trait_container = VBoxContainer.new()
	
	var trait_btn = Button.new()
	var prefix = "+" if score > 0 else ""
	trait_btn.text = "  %s: %s%d" % [t.display_value(), prefix, score]
	trait_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	trait_btn.add_theme_font_size_override("font_size", 10)
	trait_btn.flat = true
	
	if score > 0:
		trait_btn.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
	else:
		trait_btn.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	
	trait_container.add_child(trait_btn)
	
	# Explanation panel (hidden by default)
	var explain_panel = PanelContainer.new()
	explain_panel.visible = false
	
	var explain_vbox = VBoxContainer.new()
	explain_panel.add_child(explain_vbox)
	
	if explanations.is_empty():
		var no_explain_label = Label.new()
		no_explain_label.text = "      (no details available)"
		no_explain_label.add_theme_font_size_override("font_size", 9)
		no_explain_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		explain_vbox.add_child(no_explain_label)
	else:
		for expl in explanations:
			var reason: String = expl["reason"]
			var expl_score: int = expl["score"]
			var triggered_by = expl["triggered_by"]  # Person or null
			
			var explain_label = Label.new()
			var expl_prefix = "+" if expl_score > 0 else ""
			
			if triggered_by != null:
				explain_label.text = "      %s%d: %s (→ %s)" % [expl_prefix, expl_score, reason, triggered_by.name]
			else:
				explain_label.text = "      %s%d: %s" % [expl_prefix, expl_score, reason]
			
			explain_label.add_theme_font_size_override("font_size", 9)
			
			if expl_score > 0:
				explain_label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
			else:
				explain_label.add_theme_color_override("font_color", Color(0.8, 0.4, 0.4))
			
			explain_vbox.add_child(explain_label)
	
	trait_container.add_child(explain_panel)
	
	# Connect button to toggle explanation visibility
	trait_btn.pressed.connect(func(): explain_panel.visible = not explain_panel.visible)
	
	return trait_container
