extends Control

# Top bar status labels
@onready var _money_label: Label = $MainMargin/MainVBox/TopBar/TopBarHBox/StatusPanel/MoneyLabel
@onready var _rent_label: Label = $MainMargin/MainVBox/TopBar/TopBarHBox/StatusPanel/RentLabel
@onready var _capacity_label: Label = $MainMargin/MainVBox/TopBar/TopBarHBox/StatusPanel/CapacityLabel
@onready var _day_label: Label = $MainMargin/MainVBox/TopBar/TopBarHBox/StatusPanel/DayLabel

# ID Card labels
@onready var _name_label: Label = $MainMargin/MainVBox/ContentHBox/RightPanel/IDCard/IDCardMargin/IDCardVBox/NameLabel
@onready var _mask_attributes_label: RichTextLabel = $MainMargin/MainVBox/ContentHBox/RightPanel/IDCard/IDCardMargin/IDCardVBox/MaskAttributesLabel
@onready var _money_amount_label: Label = $MainMargin/MainVBox/ContentHBox/RightPanel/IDCard/IDCardMargin/IDCardVBox/MoneyAmountLabel
@onready var _personal_rules_label: RichTextLabel = $MainMargin/MainVBox/ContentHBox/RightPanel/IDCard/IDCardMargin/IDCardVBox/PersonalRulesScroll/PersonalRulesLabel

# Rules panel
@onready var _theme_label: Label = $MainMargin/MainVBox/ContentHBox/RightPanel/RulesPanel/RulesMargin/RulesVBox/ThemeLabel
@onready var _rules_label: RichTextLabel = $MainMargin/MainVBox/ContentHBox/RightPanel/RulesPanel/RulesMargin/RulesVBox/RulesScroll/RulesLabel

# Buttons
@onready var _accept_button: Button = $MainMargin/MainVBox/ContentHBox/RightPanel/ButtonsVBox/DecisionButtonsHBox/AcceptButton
@onready var _reject_button: Button = $MainMargin/MainVBox/ContentHBox/RightPanel/ButtonsVBox/DecisionButtonsHBox/RejectButton

# Mask display layers
@onready var _mask_layer: TextureRect = $MainMargin/MainVBox/ContentHBox/MaskDisplayContainer/MaskDisplay/MaskLayer
@onready var _mouth_layer: TextureRect = $MainMargin/MainVBox/ContentHBox/MaskDisplayContainer/MaskDisplay/MouthLayer
@onready var _upper_deco_layer: TextureRect = $MainMargin/MainVBox/ContentHBox/MaskDisplayContainer/MaskDisplay/UpperDecoLayer
@onready var _lower_deco_layer: TextureRect = $MainMargin/MainVBox/ContentHBox/MaskDisplayContainer/MaskDisplay/LowerDecoLayer

# Club log
@onready var _club_log_popup: AcceptDialog = $ClubLogPopup
@onready var _log_list: VBoxContainer = $ClubLogPopup/ScrollContainer/LogList
var _club_log_entry_scene: PackedScene = preload("res://scenes/club_log_entry.tscn")

# Main menu confirmation
@onready var _main_menu_confirm_popup: ConfirmationDialog = $MainMenuConfirmPopup


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

	_apply_mask(person.mask)
	_display_id_card(person)
	_display_rules_and_theme()
	_update_status()


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


## Display the ID card information for the current person (left-aligned)
func _display_id_card(person: Person) -> void:
	# Name
	_name_label.text = person.name
	
	# Mask attributes
	var mask = person.mask
	if mask == null:
		_mask_attributes_label.text = "No mask"
		_money_amount_label.text = "$0"
		_personal_rules_label.text = "[color=gray]No personal rules[/color]"
		return
	
	# Build mask attributes string (left-aligned)
	var tier_color = _get_tier_color(mask.color_tier)
	var mood_emoji = _get_mood_emoji(mask.mouth_mood)
	var stars_text = ""
	if mask.star_count > 0:
		for i in range(mask.star_count):
			stars_text += "★"
	else:
		stars_text = "None"
	
	_mask_attributes_label.text = "[color=%s]%s[/color] Mask  |  %s %s  |  Stars: %s" % [
		tier_color, mask.tier_name(), mood_emoji, mask.mood_name(), stars_text
	]
	
	# Money amount
	_money_amount_label.text = "$%s" % _format_money(person.money)
	
	# Personal rules (these become tonight's rules if accepted)
	if person.rules.size() > 0:
		var rules_text = ""
		for rule in person.rules:
			rules_text += "• %s [color=red](-$%d)[/color]\n" % [rule.description, abs(rule.penalty)]
		_personal_rules_label.text = rules_text.strip_edges()
	else:
		_personal_rules_label.text = "[color=gray]No personal rules[/color]"


## Display theme and all rules (left-aligned with status indicators)
func _display_rules_and_theme() -> void:
	var day = SaveState.day
	var club = SaveState.club
	
	# Theme display
	if day.theme != null and day.theme.type != DailyTheme.ThemeType.NONE:
		_theme_label.text = "Active theme: %s" % day.theme.theme_name()
	else:
		_theme_label.text = "Active theme: None"
	
	# Rules display - left-aligned with status and money
	var rules_text = ""
	
	# Global rules (penalties)
	for rule in day.global_rules:
		var violated = rule.is_violated(day.in_club)
		if violated:
			rules_text += "[color=red]✗[/color] %s [color=red](-$%d)[/color]\n" % [rule.description, abs(rule.penalty)]
		else:
			rules_text += "[color=green]✓[/color] %s [color=gray](-$%d if broken)[/color]\n" % [rule.description, abs(rule.penalty)]
	
	# Bonus rules (rewards)
	for rule in day.bonus_rules:
		var achieved = rule.is_achieved(day.in_club, club.capacity)
		if achieved:
			rules_text += "[color=gold]✓[/color] %s [color=gold](+$%d)[/color]\n" % [rule.description, rule.penalty]
		else:
			rules_text += "[color=gray]○[/color] %s [color=gray](+$%d)[/color]\n" % [rule.description, rule.penalty]
	
	if rules_text == "":
		_rules_label.text = "[color=gray]No rules tonight[/color]"
	else:
		_rules_label.text = rules_text.strip_edges()


# Reroll/reject cost: $100 base + $25 per day after day 1
const REROLL_BASE_COST = 25
const REROLL_COST_INCREMENT = 25


func _get_reroll_cost() -> int:
	return REROLL_BASE_COST + (SaveState.day.day_number - 1) * REROLL_COST_INCREMENT


func _update_status() -> void:
	var day = SaveState.day
	var club = SaveState.club
	var reroll_cost = _get_reroll_cost()
	var rent = club.rent()
	
	# Update top bar labels
	_money_label.text = "💰 $%s" % _format_money(club.money)
	_rent_label.text = "🏠 Rent: $%s" % _format_money(rent)
	_capacity_label.text = "👥 Club: %d/%d" % [day.in_club.size(), club.capacity]
	_day_label.text = "📅 Day %d" % day.day_number

	# Disable accept if club is full
	_accept_button.disabled = day.is_club_full(club.capacity)
	if _accept_button.disabled:
		_accept_button.text = "Club Full"
	else:
		_accept_button.text = "✓ Accept"

	# Disable reject/reroll if not enough money
	_reject_button.disabled = club.money < reroll_cost
	_reject_button.text = "✗ Reject ($%d)" % reroll_cost


## Helper to format money with thousands separator
func _format_money(amount: int) -> String:
	var s = str(abs(amount))
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	if amount < 0:
		result = "-" + result
	return result


## Helper to get color code for mask tier
func _get_tier_color(tier: Mask.ColorTier) -> String:
	match tier:
		Mask.ColorTier.GREY: return "#888888"
		Mask.ColorTier.GREEN: return "#44aa44"
		Mask.ColorTier.BLUE: return "#4488ff"
		Mask.ColorTier.PURPLE: return "#aa44aa"
		Mask.ColorTier.ORANGE: return "#ff8844"
		Mask.ColorTier.GOLD: return "#ffdd44"
	return "#ffffff"


## Helper to get emoji for mood
func _get_mood_emoji(mood: Mask.Mood) -> String:
	match mood:
		Mask.Mood.HAPPY: return "😊"
		Mask.Mood.NEUTRAL: return "😐"
		Mask.Mood.SAD: return "😢"
	return ""


func _on_accept_button_pressed() -> void:
	var person = SaveState.day.current_person()
	
	# Give money immediately when accepting
	if person != null:
		SaveState.club.money += person.money
	
	# Add personal rules to tonight's rules when accepting
	# Then clear them from the person so they're not counted twice in profit
	if person != null and person.rules.size() > 0:
		for rule in person.rules:
			SaveState.day.global_rules.append(rule)
		person.rules.clear()
	
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
	_main_menu_confirm_popup.popup_centered()


func _on_main_menu_confirm_popup_confirmed() -> void:
	# End the day (calculate profits/rent) then go to main menu
	SaveState.club.money += int(SaveState.day.profit(SaveState.club.capacity))
	SaveState.club.money -= SaveState.club.rent()
	
	# Check for game over (bankruptcy)
	if SaveState.club.money < 0:
		SaveState.delete_save()
		SaveState.switch_to_state(SaveStateClass.State.GameOver)
	else:
		SaveState.next_theme = DailyTheme.pick_random()
		SaveState.save()
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
