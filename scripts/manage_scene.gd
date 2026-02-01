extends Control

const BASE_UPGRADE_COST: int = 250  # First upgrade costs 250, then 500, 750, etc.
const INITIAL_CAPACITY: int = 5  # Starting capacity (to calculate upgrade count)
const CAPACITY_UPGRADE_AMOUNT: int = 1
const REROLL_DISCOUNT_UPGRADE_COST: int = 500  # Cost to reduce "Next" price by $25
const REROLL_DISCOUNT_AMOUNT: int = 25  # How much each upgrade reduces the cost
const TIER_LUCK_UPGRADE_COST: int = 750  # Cost to increase chance of higher tier masks
const TIER_LUCK_UPGRADE_AMOUNT: int = 1  # Each upgrade adds +1 tier luck bonus

# Current state labels
@onready var _money_label: Label = $MainMargin/MainVBox/ContentHBox/LeftPanel/CurrentStateCard/StateMargin/StateVBox/MoneyLabel
@onready var _capacity_label: Label = $MainMargin/MainVBox/ContentHBox/LeftPanel/CurrentStateCard/StateMargin/StateVBox/CapacityLabel
@onready var _day_label: Label = $MainMargin/MainVBox/ContentHBox/LeftPanel/CurrentStateCard/StateMargin/StateVBox/DayLabel
@onready var _reroll_cost_label: Label = $MainMargin/MainVBox/ContentHBox/LeftPanel/CurrentStateCard/StateMargin/StateVBox/RerollCostLabel

# Upgrade buttons
@onready var _capacity_upgrade_button: Button = $MainMargin/MainVBox/ContentHBox/LeftPanel/UpgradesCard/UpgradesMargin/UpgradesVBox/UpgradesList/CapacityUpgradeRow/CapacityUpgradeButton
@onready var _reroll_discount_upgrade_button: Button = $MainMargin/MainVBox/ContentHBox/LeftPanel/UpgradesCard/UpgradesMargin/UpgradesVBox/UpgradesList/RerollDiscountUpgradeRow/RerollDiscountUpgradeButton
@onready var _reroll_discount_row: HBoxContainer = $MainMargin/MainVBox/ContentHBox/LeftPanel/UpgradesCard/UpgradesMargin/UpgradesVBox/UpgradesList/RerollDiscountUpgradeRow
@onready var _tier_luck_upgrade_button: Button = $MainMargin/MainVBox/ContentHBox/LeftPanel/UpgradesCard/UpgradesMargin/UpgradesVBox/UpgradesList/TierLuckUpgradeRow/TierLuckUpgradeButton
@onready var _tier_luck_row: HBoxContainer = $MainMargin/MainVBox/ContentHBox/LeftPanel/UpgradesCard/UpgradesMargin/UpgradesVBox/UpgradesList/TierLuckUpgradeRow
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
	
	# Calculate rent that was paid
	_day_rent = int(1000 * (1.5 ** SaveState.club.day))
	
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
	
	# Calculate and display tomorrow's reroll cost
	var tomorrow_base_reroll_cost = 25 + (tomorrow_day - 1) * 25
	var tomorrow_reroll_cost = maxi(tomorrow_base_reroll_cost - SaveState.club.reroll_discount, 25)
	_reroll_cost_label.text = "🔄 Next Cost: $%s" % _format_money(tomorrow_reroll_cost)
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

	# Calculate current upgrade cost (250 * upgrade_number, where upgrade_number = capacity - 4)
	var current_upgrade_cost = _get_upgrade_cost()
	_capacity_upgrade_button.text = "$%s" % _format_money(current_upgrade_cost)
	
	# Disable upgrade button if can't afford
	_capacity_upgrade_button.disabled = SaveState.club.money < current_upgrade_cost
	
	# Reroll discount upgrade - only available if "Next" price for tomorrow is $50+
	# Only show/enable this upgrade if tomorrow's "Next" price would be $50 or more
	var upgrade_available = tomorrow_reroll_cost >= 50
	var can_afford = SaveState.club.money >= REROLL_DISCOUNT_UPGRADE_COST
	_reroll_discount_upgrade_button.text = "$%s" % _format_money(REROLL_DISCOUNT_UPGRADE_COST)
	_reroll_discount_upgrade_button.disabled = not (upgrade_available and can_afford)
	_reroll_discount_row.visible = upgrade_available
	
	# Tier luck upgrade - increases chances of higher tier masks
	# Cap at 10 upgrades (enough to significantly shift probabilities)
	var tier_luck_available = SaveState.club.tier_luck_bonus < 10
	var can_afford_tier_luck = SaveState.club.money >= TIER_LUCK_UPGRADE_COST
	_tier_luck_upgrade_button.text = "$%s" % _format_money(TIER_LUCK_UPGRADE_COST)
	_tier_luck_upgrade_button.disabled = not (tier_luck_available and can_afford_tier_luck)
	_tier_luck_row.visible = tier_luck_available

	# Disable undo button if no purchases to undo
	_undo_button.disabled = _purchase_history.is_empty()


## Calculate the cost for the next capacity upgrade
## Cost increases by 250 every 5 capacity levels:
## Capacity 5-9: $250, Capacity 10-14: $500, Capacity 15-19: $750, etc.
func _get_upgrade_cost() -> int:
	@warning_ignore("INTEGER_DIVISION")
	var price_tier = SaveState.club.capacity / 5  # Integer division: 5-9 = 1, 10-14 = 2, etc.
	return BASE_UPGRADE_COST * price_tier


## Calculate rent for a specific day number
func _calculate_rent_for_day(day_number: int) -> int:
	return int(1000 * (1.5 ** day_number))


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
	var upgrade_cost = _get_upgrade_cost()
	if SaveState.club.money < upgrade_cost:
		return

	# Apply the upgrade
	SaveState.club.money -= upgrade_cost
	SaveState.club.capacity += CAPACITY_UPGRADE_AMOUNT
	
	# Record in history for undo
	_purchase_history.append({
		"type": "capacity",
		"cost": upgrade_cost,
		"amount": CAPACITY_UPGRADE_AMOUNT
	})
	
	update_display()


func _on_reroll_discount_upgrade_button_pressed() -> void:
	MusicManager.play_button_sfx()
	if SaveState.club.money < REROLL_DISCOUNT_UPGRADE_COST:
		return
	
	# Apply the upgrade
	SaveState.club.money -= REROLL_DISCOUNT_UPGRADE_COST
	SaveState.club.reroll_discount += REROLL_DISCOUNT_AMOUNT
	
	# Record in history for undo
	_purchase_history.append({
		"type": "reroll_discount",
		"cost": REROLL_DISCOUNT_UPGRADE_COST,
		"amount": REROLL_DISCOUNT_AMOUNT
	})
	
	update_display()


func _on_tier_luck_upgrade_button_pressed() -> void:
	MusicManager.play_button_sfx()
	if SaveState.club.money < TIER_LUCK_UPGRADE_COST:
		return
	if SaveState.club.tier_luck_bonus >= 10:
		return
	
	# Apply the upgrade
	SaveState.club.money -= TIER_LUCK_UPGRADE_COST
	SaveState.club.tier_luck_bonus += TIER_LUCK_UPGRADE_AMOUNT
	
	# Record in history for undo
	_purchase_history.append({
		"type": "tier_luck",
		"cost": TIER_LUCK_UPGRADE_COST,
		"amount": TIER_LUCK_UPGRADE_AMOUNT
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
	elif last_purchase["type"] == "reroll_discount":
		SaveState.club.money += last_purchase["cost"]
		SaveState.club.reroll_discount -= last_purchase["amount"]
	elif last_purchase["type"] == "tier_luck":
		SaveState.club.money += last_purchase["cost"]
		SaveState.club.tier_luck_bonus -= last_purchase["amount"]
	
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
