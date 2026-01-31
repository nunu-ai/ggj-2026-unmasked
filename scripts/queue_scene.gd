extends Control

@export var name_label: Label
@export var status_label: Label
@export var mask_label: RichTextLabel
@export var rules_label: RichTextLabel
@export var accept_button: Button
@export var reject_button: Button
@export var reroll_button: Button
@export var end_day_button: Button

@onready var _mask_layer: TextureRect = $VBoxContainer/HBox/VBox1/MaskLayer
@onready var _mouth_layer: TextureRect = $VBoxContainer/HBox/VBox1/MouthLayer
@onready var _upper_deco_layer: TextureRect = $VBoxContainer/HBox/VBox1/UpperDecoLayer
@onready var _lower_deco_layer: TextureRect = $VBoxContainer/HBox/VBox1/LowerDecoLayer

<<<<<<< HEAD
var _mask_textures: Array[Texture2D] = [
	preload("res://assets/masks/full-mask-1.png"),
	preload("res://assets/masks/half-mask-1.png"),
	preload("res://assets/masks/eye-mask-1.png"),
	preload("res://assets/masks/eye-mask-2.png"),
]

var _upper_deco_textures: Array[Texture2D] = [
	null,
	preload("res://assets/masks/upper_decos/carneval/3.png"),
	preload("res://assets/masks/upper_decos/carneval/4.png"),
	preload("res://assets/masks/upper_decos/carneval/8.png"),
]

var _lower_deco_textures: Array[Texture2D] = [
	null,
	preload("res://assets/masks/lower_decos/roman/1.png"),
	preload("res://assets/masks/lower_decos/roman/2.png"),
	preload("res://assets/masks/lower_decos/roman/3.png"),
	preload("res://assets/masks/lower_decos/roman/4.png"),
	preload("res://assets/masks/lower_decos/roman/5.png"),
	preload("res://assets/masks/lower_decos/roman/6.png"),
	preload("res://assets/masks/lower_decos/stars/1.png"),
	preload("res://assets/masks/lower_decos/stars/2.png"),
	preload("res://assets/masks/lower_decos/stars/3.png"),
]

func _ready() -> void:
	_randomize_appearance()
=======
# Club log
@onready var _club_log_popup: AcceptDialog = $ClubLogPopup
@onready var _log_list: VBoxContainer = $ClubLogPopup/ScrollContainer/LogList
var _club_log_entry_scene: PackedScene = preload("res://scenes/club_log_entry.tscn")


func _ready() -> void:
	randomize_button_captions()
>>>>>>> 31f099b (random mask generation and log)
	update_display()


func update_display() -> void:
	# Check if day exists (might be null if scene is run directly)
	if SaveState.day == null:
		push_warning("QueueScene: No day initialized, returning to menu")
		SaveState.switch_to_state(SaveStateClass.State.Menu)
		return

	var person = SaveState.day.current_person()
	if person == null:
		# This shouldn't happen with infinite queue, but handle it
		push_warning("QueueScene: No current person, generating new one")
		SaveState.day.reroll()
		person = SaveState.day.current_person()

	name_label.text = person.name
<<<<<<< HEAD
	display_mask(person)
	display_rules()
	update_status()


func display_mask(person: Person) -> void:
	var mask = person.mask
	var mask_text = "Mask: %s" % mask.color.capitalize()
	if mask.decoration != "none":
		mask_text += " with %s" % mask.decoration
	mask_text += "\nMoney: $%d" % person.money
	
	# Show personal rules if any
	if person.rules.size() > 0:
		mask_text += "\n\n[color=yellow]Personal Rules:[/color]"
		for rule in person.rules:
			mask_text += "\n- %s (penalty: $%d)" % [rule.description, rule.penalty]
	
	mask_label.text = mask_text
=======
	_apply_mask(person.mask)
	display_traits(person)
	update_status()


## Apply a Mask's visual data to the texture layers
func _apply_mask(mask: Mask) -> void:
	# Mask base
	_mask_layer.texture = load(mask.mask_path)
	_mask_layer.modulate = mask.color

	# Mouth
	_mouth_layer.texture = load(mask.mouth_path)

	# Upper deco
	if mask.upper_deco_path != "":
		_upper_deco_layer.texture = load(mask.upper_deco_path)
		_upper_deco_layer.modulate = mask.upper_deco_color
	else:
		_upper_deco_layer.texture = null

	# Lower deco
	if mask.lower_deco_path != "":
		_lower_deco_layer.texture = load(mask.lower_deco_path)
		_lower_deco_layer.modulate = mask.lower_deco_color
	else:
		_lower_deco_layer.texture = null


func display_traits(person: Person) -> void:
	var header_parts: Array[String] = []
	var other_traits: Array[String] = []
>>>>>>> 31f099b (random mask generation and log)


<<<<<<< HEAD
func display_rules() -> void:
	var day = SaveState.day
	var rules_text = "[b]Today's Rules:[/b]\n"
	
	if day.global_rules.size() == 0:
		rules_text += "No special rules today."
	else:
		for rule in day.global_rules:
			var violated = rule.is_violated(day.in_club)
			var status = "[color=red]VIOLATED[/color]" if violated else "[color=green]OK[/color]"
			rules_text += "- %s (%s, penalty: $%d)\n" % [rule.description, status, rule.penalty]
	
	rules_label.text = rules_text
=======
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

	# Mask info
	if person.mask != null:
		header_parts.append("%s Mask" % person.mask.tier_name())
		header_parts.append("%s" % person.mask.mood_name())
		if person.mask.star_count > 0:
			header_parts.append("%d Star%s" % [person.mask.star_count, "s" if person.mask.star_count > 1 else ""])
		header_parts.append("$%d" % person.mask.money())

	var header_line = " | ".join(header_parts)
	var other_lines = ""
	for desc in other_traits:
		other_lines += "- %s\n" % desc

	traits_label.text = "%s\n\n%s" % [header_line, other_lines]
>>>>>>> 31f099b (random mask generation and log)


func update_status() -> void:
	var day = SaveState.day
	var club = SaveState.club
	status_label.text = "In Club: %d/%d | Money: $%d" % [
		day.in_club.size(), club.capacity, club.money
	]
	
	# Disable accept if club is full
	accept_button.disabled = day.is_club_full(club.capacity)
	
	# Disable reroll if not enough money
	reroll_button.disabled = club.money < Constants.REROLL_COST
	reroll_button.text = "Reroll ($%d)" % Constants.REROLL_COST


func _on_accept_button_pressed() -> void:
	SaveState.day.decide_current_person(true)
<<<<<<< HEAD
	_randomize_appearance()
=======
	randomize_button_captions()
>>>>>>> 31f099b (random mask generation and log)
	update_display()


func _on_reject_button_pressed() -> void:
	SaveState.day.decide_current_person(false)
<<<<<<< HEAD
	_randomize_appearance()
=======
	randomize_button_captions()
>>>>>>> 31f099b (random mask generation and log)
	update_display()


func _on_reroll_button_pressed() -> void:
	if SaveState.club.money >= Constants.REROLL_COST:
		SaveState.club.money -= Constants.REROLL_COST
		SaveState.day.reroll()
		_randomize_appearance()
		update_display()


func _on_end_day_button_pressed() -> void:
	SaveState.end_day()


func _on_main_menu_button_pressed() -> void:
	SaveState.switch_to_state(SaveStateClass.State.Menu)


func _on_log_button_pressed() -> void:
	# Clear old entries
	for child in _log_list.get_children():
		child.queue_free()

	# Add entry for each person currently in the club
	for person in SaveState.day.in_club:
		var entry = _club_log_entry_scene.instantiate()
		_log_list.add_child(entry)
		entry.setup(person)

	_club_log_popup.popup_centered()
