extends Control

@export var name_label: Label
@export var status_label: Label
@export var mask_label: RichTextLabel
@export var rules_label: RichTextLabel
@export var accept_button: Button
@export var reject_button: Button  # Also serves as reroll (costs money)
@export var end_day_button: Button

@onready var _mask_layer: TextureRect = $VBoxContainer/HBox/VBox1/MaskLayer
@onready var _mouth_layer: TextureRect = $VBoxContainer/HBox/VBox1/MouthLayer
@onready var _upper_deco_layer: TextureRect = $VBoxContainer/HBox/VBox1/UpperDecoLayer
@onready var _lower_deco_layer: TextureRect = $VBoxContainer/HBox/VBox1/LowerDecoLayer

# Club log
@onready var _club_log_popup: AcceptDialog = $ClubLogPopup
@onready var _log_list: VBoxContainer = $ClubLogPopup/ScrollContainer/LogList
var _club_log_entry_scene: PackedScene = preload("res://scenes/club_log_entry.tscn")


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
		# This shouldn't happen with infinite queue, but handle it
		push_warning("QueueScene: No current person, generating new one")
		SaveState.day.reroll()
		person = SaveState.day.current_person()

	name_label.text = person.name
	_apply_mask(person.mask)
	display_mask(person)
	display_rules()
	update_status()


## Apply a Mask's visual data to the texture layers
func _apply_mask(mask: Mask) -> void:
	if mask == null:
		return

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


func display_mask(person: Person) -> void:
	var mask = person.mask
	if mask == null:
		mask_label.text = "No mask"
		return

	var mask_text = "Mask: %s" % mask.tier_name()
	mask_text += " | %s" % mask.mood_name()
	if mask.star_count > 0:
		mask_text += " | %d Star%s" % [mask.star_count, "s" if mask.star_count > 1 else ""]
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


# Reroll/reject cost: $100 base + $25 per day after day 1
const REROLL_BASE_COST = 100
const REROLL_COST_INCREMENT = 25

func _get_reroll_cost() -> int:
	return REROLL_BASE_COST + (SaveState.day.day_number - 1) * REROLL_COST_INCREMENT


func update_status() -> void:
	var day = SaveState.day
	var club = SaveState.club
	var reroll_cost = _get_reroll_cost()
	
	status_label.text = "In Club: %d/%d | Money: $%d" % [
		day.in_club.size(), club.capacity, club.money
	]

	# Disable accept if club is full
	accept_button.disabled = day.is_club_full(club.capacity)

	# Disable reject/reroll if not enough money
	reject_button.disabled = club.money < reroll_cost
	reject_button.text = "Reject ($%d)" % reroll_cost


func _on_accept_button_pressed() -> void:
	SaveState.day.decide_current_person(true)
	update_display()


func _on_reject_button_pressed() -> void:
	var reroll_cost = _get_reroll_cost()
	if SaveState.club.money >= reroll_cost:
		SaveState.club.money -= reroll_cost
		SaveState.day.decide_current_person(false)
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
