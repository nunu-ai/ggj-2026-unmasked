extends Control

@export var name_label: Label
@export var status_label: Label
@export var traits_label: RichTextLabel
@export var accept_button: Button
@export var reject_button: Button
@export var debug_panel: DebugPanel
@export var reaction_particles: ReactionParticles

var last_happiness = null

const ACCEPT_PHRASES: Array[String] = [
	"Welcome",
	"Come in",
	"You're in",
	"Enter",
	"Go ahead",
]

const REJECT_PHRASES: Array[String] = [
	"Get lost",
	"Go home",
	"Not tonight",
	"Beat it",
	"No way",
	"Scram",
]

func _ready() -> void:
	randomize_button_captions()
	update_display()


func randomize_button_captions() -> void:
	accept_button.text = ACCEPT_PHRASES.pick_random()
	reject_button.text = REJECT_PHRASES.pick_random()


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
	var header_parts: Array[String] = []
	var other_traits: Array[String] = []

	var age: Age = null
	var nationality: Nationality = null
	var gender: Gender = null
	var dress_code: DressCode = null

	for t in person.traits:
		if t.hidden():
			continue
		if t is Age:
			age = t
		elif t is Nationality:
			nationality = t
		elif t is Gender:
			gender = t
		elif t is DressCode:
			dress_code = t
		else:
			# Add happiness indicator: [H] for traits that affect happiness
			var happiness_indicator = " [H]" if t.can_affect_happiness() else ""
			var trait_text = "%s%s\n" % [t.description(), happiness_indicator]
			other_traits.append(trait_text)

	if gender != null:
		header_parts.append("%s" % gender.description())
	if age != null:
		header_parts.append("Age: %d" % age.age)
	if nationality != null:
		header_parts.append("%s" % nationality.description())
	if dress_code != null:
		header_parts.append("%s" % dress_code.description())

	var header_line = " | ".join(header_parts)
	var other_lines = ""
	for desc in other_traits:
		other_lines += "- %s\n" % desc

	traits_label.text = "%s\n\n%s" % [header_line, other_lines]


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

	var cur_happiness = SaveState.day.profit()
	if last_happiness == null:
		last_happiness = cur_happiness
	else:
		var delta_happiness = cur_happiness - last_happiness
		last_happiness = cur_happiness

		if delta_happiness > 10:
			reaction_particles.react_happily()
		elif delta_happiness < -10:
			reaction_particles.react_negatively()
		else:
			reaction_particles.react_neutrally()


func _on_accept_button_pressed() -> void:
	SaveState.day.decide_current_person(true)
	randomize_button_captions()
	update_display()


func _on_reject_button_pressed() -> void:
	SaveState.day.decide_current_person(false)
	randomize_button_captions()
	update_display()


func _on_main_menu_button_pressed() -> void:
	SaveState.switch_to_state(SaveStateClass.State.Menu)
