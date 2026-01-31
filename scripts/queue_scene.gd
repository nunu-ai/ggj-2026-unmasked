extends Control

@export var name_label: Label
@export var status_label: Label
@export var traits_label: Label
@export var accept_button: Button
@export var reject_button: Button
@export var debug_panel: DebugPanel

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
			# Add happiness indicator: [H] for traits that affect happiness
			var happiness_indicator = " [H]" if t.can_affect_happiness() else ""
			traits_text += "- %s%s\n" % [t.description(), happiness_indicator]
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
	if debug_panel:
		debug_panel.update_view()


func _on_accept_button_pressed() -> void:
	SaveState.day.decide_current_person(true)
	update_display()


func _on_reject_button_pressed() -> void:
	SaveState.day.decide_current_person(false)
	update_display()


func _on_main_menu_button_pressed() -> void:
	SaveState.switch_to_state(SaveStateClass.State.Menu)
