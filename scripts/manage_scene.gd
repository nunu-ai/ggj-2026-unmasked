extends Control

const CAPACITY_UPGRADE_COST: int = 1000
const CAPACITY_UPGRADE_AMOUNT: int = 1

# Current state labels
@onready var _money_label: Label = $MainMargin/MainVBox/ContentHBox/LeftPanel/CurrentStateCard/StateMargin/StateVBox/MoneyLabel
@onready var _capacity_label: Label = $MainMargin/MainVBox/ContentHBox/LeftPanel/CurrentStateCard/StateMargin/StateVBox/CapacityLabel
@onready var _day_label: Label = $MainMargin/MainVBox/ContentHBox/LeftPanel/CurrentStateCard/StateMargin/StateVBox/DayLabel

# Upgrade button
@onready var _capacity_upgrade_button: Button = $MainMargin/MainVBox/ContentHBox/LeftPanel/UpgradesCard/UpgradesMargin/UpgradesVBox/UpgradesList/CapacityUpgradeRow/CapacityUpgradeButton
@onready var _undo_button: Button = $MainMargin/MainVBox/ContentHBox/LeftPanel/UpgradesCard/UpgradesMargin/UpgradesVBox/UndoButton

# Tomorrow's info
@onready var _tomorrow_title: Label = $MainMargin/MainVBox/ContentHBox/RightPanel/TomorrowCard/TomorrowMargin/TomorrowVBox/TomorrowTitle
@onready var _theme_label: Label = $MainMargin/MainVBox/ContentHBox/RightPanel/TomorrowCard/TomorrowMargin/TomorrowVBox/ThemeLabel
@onready var _rent_label: Label = $MainMargin/MainVBox/ContentHBox/RightPanel/TomorrowCard/TomorrowMargin/TomorrowVBox/RentLabel

# Day results button + popup
@onready var _day_results_button: Button = $MainMargin/MainVBox/TopBar/TopBarHBox/DayResultsButton
@onready var _day_results_popup: AcceptDialog = $DayResultsPopup
@onready var _popup_day_label: Label = $DayResultsPopup/MarginContainer/VBoxContainer/PopupDayLabel
@onready var _starting_money_label: Label = $DayResultsPopup/MarginContainer/VBoxContainer/StartingMoneyLabel
@onready var _guest_money_label: Label = $DayResultsPopup/MarginContainer/VBoxContainer/GuestMoneyLabel
@onready var _rules_money_label: Label = $DayResultsPopup/MarginContainer/VBoxContainer/RulesMoneyLabel
@onready var _rent_label_popup: Label = $DayResultsPopup/MarginContainer/VBoxContainer/RentLabel
@onready var _final_money_label: Label = $DayResultsPopup/MarginContainer/VBoxContainer/FinalMoneyLabel

# Initial state snapshot (captured once on scene load)
var _initial_money: int
var _initial_capacity: int

# Day results (calculated once when scene loads, before upgrades)
var _day_starting_money: int = 0
var _day_guest_money: int = 0
var _day_rules_money: int = 0
var _day_rent: int = 0
var _day_final_money: int = 0

# Undo stack - stores purchases that can be undone
# Each entry is a dictionary: { "type": "capacity", "cost": 1000, "amount": 1 }
var _purchase_history: Array = []


func _ready() -> void:
	# Snapshot initial state
	_initial_money = SaveState.club.money
	_initial_capacity = SaveState.club.capacity

	# Calculate day results (before any upgrades can change capacity)
	_calculate_day_results()

	_capacity_upgrade_button.text = "$%s" % _format_money(CAPACITY_UPGRADE_COST)
	update_display()

	# Auto-open day results popup when arriving at manage scene (skip day 0)
	if SaveState.club.day > 0:
		_on_day_results_button_pressed()


## Calculate and store day results for the popup
func _calculate_day_results() -> void:
	if SaveState.day == null or SaveState.club.day == 0:
		return
	
	# Money at end of day (current state when arriving at manage)
	_day_final_money = _initial_money
	
	# Calculate money earned from guests (sum of all accepted people)
	_day_guest_money = 0
	for person in SaveState.day.in_club:
		_day_guest_money += person.money
	
	# Calculate money from rules (bonuses - penalties)
	_day_rules_money = int(SaveState.day.profit(_initial_capacity))
	
	# Calculate rent that was paid (uses capacity at end of day)
	_day_rent = int(_initial_capacity * 200 * (1.3 ** SaveState.club.day))
	
	# Back-calculate starting money
	# final = starting + guests + rules - rent
	# starting = final - guests - rules + rent
	_day_starting_money = _day_final_money - _day_guest_money - _day_rules_money + _day_rent


func update_display() -> void:
	# Current state with icons (like queue scene)
	_money_label.text = "💰 $%s" % _format_money(SaveState.club.money)
	_capacity_label.text = "👥 Capacity: %d" % SaveState.club.capacity
	_day_label.text = "📅 Day %d" % SaveState.club.day

	# Tomorrow's info
	var tomorrow_day = SaveState.club.day + 1
	_tomorrow_title.text = "Tomorrow: Day %d" % tomorrow_day
	
	# Theme display
	var next_theme = SaveState.next_theme
	if next_theme != null and next_theme.type != DailyTheme.ThemeType.NONE:
		_theme_label.text = "🎭 Theme: %s (+%d%%)" % [next_theme.theme_name(), int(next_theme.bonus_percent())]
	else:
		_theme_label.text = "🎭 Theme: None"
	
	# Rent for tomorrow (calculated with tomorrow's day number)
	var tomorrow_rent = _calculate_rent_for_day(tomorrow_day)
	_rent_label.text = "🏠 Rent Due: $%s" % _format_money(tomorrow_rent)

	# Day results button - hide on day 0, show otherwise
	_day_results_button.visible = SaveState.club.day > 0
	_day_results_button.text = "📋 Day %d Results" % SaveState.club.day

	# Disable upgrade button if can't afford
	_capacity_upgrade_button.disabled = SaveState.club.money < CAPACITY_UPGRADE_COST

	# Disable undo button if no purchases to undo
	_undo_button.disabled = _purchase_history.is_empty()


## Calculate rent for a specific day number
func _calculate_rent_for_day(day_number: int) -> int:
	return int(SaveState.club.capacity * 200 * (1.3 ** day_number))


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


func _on_capacity_upgrade_button_pressed() -> void:
	MusicManager.play_button_sfx()
	if SaveState.club.money < CAPACITY_UPGRADE_COST:
		return

	# Apply the upgrade
	SaveState.club.money -= CAPACITY_UPGRADE_COST
	SaveState.club.capacity += CAPACITY_UPGRADE_AMOUNT
	
	# Record in history for undo
	_purchase_history.append({
		"type": "capacity",
		"cost": CAPACITY_UPGRADE_COST,
		"amount": CAPACITY_UPGRADE_AMOUNT
	})
	
	update_display()


func _on_undo_button_pressed() -> void:
	MusicManager.play_button_sfx()
	if _purchase_history.is_empty():
		return
	
	# Pop the last purchase and reverse it
	var last_purchase = _purchase_history.pop_back()
	
	if last_purchase["type"] == "capacity":
		SaveState.club.money += last_purchase["cost"]
		SaveState.club.capacity -= last_purchase["amount"]
	
	update_display()


func _on_day_results_button_pressed() -> void:
	MusicManager.play_button_sfx()

	_popup_day_label.text = "📅 Day %d Results" % SaveState.club.day
	
	# Starting money (gray, muted)
	_starting_money_label.text = "💰 Starting: $%s" % _format_money(_day_starting_money)
	
	# Guest money (green for positive)
	_guest_money_label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
	_guest_money_label.text = "🎭 Guests: +$%s" % _format_money(_day_guest_money)
	
	# Rules money (green for positive, red for negative)
	if _day_rules_money >= 0:
		_rules_money_label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
		_rules_money_label.text = "📋 Rules: +$%s" % _format_money(_day_rules_money)
	else:
		_rules_money_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
		_rules_money_label.text = "📋 Rules: -$%s" % _format_money(abs(_day_rules_money))
	
	# Rent (red)
	_rent_label_popup.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	_rent_label_popup.text = "🏠 Rent: -$%s" % _format_money(_day_rent)
	
	# Final money (orange accent)
	_final_money_label.text = "💰 End of Day: $%s" % _format_money(_day_final_money)

	_day_results_popup.popup_centered()


func _on_start_day_button_pressed() -> void:
	MusicManager.play_button_sfx()
	SaveState.start_day()


func _on_main_menu_button_pressed() -> void:
	MusicManager.play_button_sfx()
	SaveState.switch_to_state(SaveStateClass.State.Menu)
