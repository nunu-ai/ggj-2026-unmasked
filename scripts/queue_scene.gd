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
@onready var _upper_deco_layer: TextureRect = $VBoxContainer/HBox/VBox1/UpperDecoLayer
@onready var _lower_deco_layer: TextureRect = $VBoxContainer/HBox/VBox1/LowerDecoLayer

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


func _randomize_appearance() -> void:
	# Randomize mask
	_mask_layer.texture = _mask_textures.pick_random()
	_mask_layer.modulate = Color(randf(), randf(), randf(), 1.0)

	# Randomize upper deco (can be null = no deco)
	_upper_deco_layer.texture = _upper_deco_textures.pick_random()
	_upper_deco_layer.modulate = Color(randf(), randf(), randf(), 1.0)

	# Randomize lower deco (can be null = no deco)
	_lower_deco_layer.texture = _lower_deco_textures.pick_random()
	_lower_deco_layer.modulate = Color(randf(), randf(), randf(), 1.0)


func _on_accept_button_pressed() -> void:
	SaveState.day.decide_current_person(true)
	_randomize_appearance()
	update_display()


func _on_reject_button_pressed() -> void:
	SaveState.day.decide_current_person(false)
	_randomize_appearance()
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
