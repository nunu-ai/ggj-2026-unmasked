extends Control

const CAPACITY_UPGRADE_COST: int = 1000
const CAPACITY_UPGRADE_AMOUNT: int = 1

# Current state panel labels
@onready var _day_label: Label = $VBoxContainer/ManageContent/RightPane/CurrentState/MarginContainer/VBoxContainer/DayLabel
@onready var _money_label: Label = $VBoxContainer/ManageContent/RightPane/CurrentState/MarginContainer/VBoxContainer/MoneyLabel
@onready var _capacity_label: Label = $VBoxContainer/ManageContent/RightPane/CurrentState/MarginContainer/VBoxContainer/CapacityLabel

# Upgrade button
@onready var _capacity_upgrade_button: Button = $VBoxContainer/ManageContent/RightPane/Upgrades/MarginContainer/VBoxContainer/CapacityUpgrade/UpgradeButton

# Checkout labels
@onready var _cost_label: Label = $VBoxContainer/ManageContent/RightPane/CheckoutOverview/MarginContainer/VBoxContainer/CostLabel
@onready var _money_after_label: Label = $VBoxContainer/ManageContent/RightPane/CheckoutOverview/MarginContainer/VBoxContainer/MoneyAfterLabel
@onready var _capacity_after_label: Label = $VBoxContainer/ManageContent/RightPane/CheckoutOverview/MarginContainer/VBoxContainer/CapacityAfterLabel

# Checkout buttons
@onready var _reset_cart_button: Button = $VBoxContainer/ManageContent/RightPane/CheckoutOverview/MarginContainer/VBoxContainer/ButtonRow/ResetCartButton
@onready var _reset_to_initial_button: Button = $VBoxContainer/ManageContent/RightPane/CheckoutOverview/MarginContainer/VBoxContainer/ButtonRow/ResetToInitialButton
@onready var _confirm_button: Button = $VBoxContainer/ManageContent/RightPane/CheckoutOverview/MarginContainer/VBoxContainer/ButtonRow/ConfirmButton

# Theme label
@onready var _theme_label: Label = $VBoxContainer/ManageContent/LeftPane/RulesPanel/MarginContainer/VBoxContainer/ThemeLabel

# Day results button + popup
@onready var _day_results_button: Button = $VBoxContainer/ManageContent/LeftPane/ButtonPanel/ButtonContainer/DayResultsButton
@onready var _day_results_popup: AcceptDialog = $DayResultsPopup
@onready var _popup_day_label: Label = $DayResultsPopup/MarginContainer/VBoxContainer/PopupDayLabel
@onready var _popup_initial_money_label: Label = $DayResultsPopup/MarginContainer/VBoxContainer/PopupInitialMoneyLabel
@onready var _popup_initial_capacity_label: Label = $DayResultsPopup/MarginContainer/VBoxContainer/PopupInitialCapacityLabel
@onready var _popup_current_money_label: Label = $DayResultsPopup/MarginContainer/VBoxContainer/PopupCurrentMoneyLabel
@onready var _popup_current_capacity_label: Label = $DayResultsPopup/MarginContainer/VBoxContainer/PopupCurrentCapacityLabel
@onready var _popup_money_spent_label: Label = $DayResultsPopup/MarginContainer/VBoxContainer/PopupMoneySpentLabel

# Initial state snapshot (captured once on scene load)
var _initial_money: int
var _initial_capacity: int

# Pending upgrade totals (cart)
var _pending_cost: int = 0
var _pending_capacity: int = 0


func _ready() -> void:
	# Snapshot initial state
	_initial_money = SaveState.club.money
	_initial_capacity = SaveState.club.capacity

	_capacity_upgrade_button.text = "$%d" % CAPACITY_UPGRADE_COST
	update_display()

	# Auto-open day results popup when arriving at manage scene
	_on_day_results_button_pressed()


func update_display() -> void:
	# Current state panel
	_day_label.text = "Day: %d" % SaveState.club.day
	_money_label.text = "Money: $%d" % SaveState.club.money
	_capacity_label.text = "Capacity: %d" % SaveState.club.capacity

	# Cart preview
	_cost_label.text = "Cost: $%d" % _pending_cost
	_money_after_label.text = "Money After: $%d" % (SaveState.club.money - _pending_cost)
	_capacity_after_label.text = "Capacity After: %d" % (SaveState.club.capacity + _pending_capacity)

	# Theme display
	var theme = SaveState.next_theme
	if theme != null and theme.type != DailyTheme.ThemeType.NONE:
		_theme_label.text = "%s (+%d%%)" % [theme.theme_name(), int(theme.bonus_percent())]
	else:
		_theme_label.text = "No Theme"

	# Day results button text
	_day_results_button.text = "Day %d Results" % SaveState.club.day

	# Disable upgrade button if can't afford with pending costs
	_capacity_upgrade_button.disabled = (SaveState.club.money - _pending_cost) < CAPACITY_UPGRADE_COST

	# Disable cart buttons when cart is empty
	var cart_empty: bool = _pending_cost == 0
	_reset_cart_button.disabled = cart_empty
	_confirm_button.disabled = cart_empty

	# Disable reset all when already at initial state and cart is empty
	var at_initial: bool = SaveState.club.money == _initial_money and SaveState.club.capacity == _initial_capacity
	_reset_to_initial_button.disabled = at_initial and cart_empty


func _on_upgrade_button_pressed() -> void:
	MusicManager.play_button_sfx()
	if (SaveState.club.money - _pending_cost) < CAPACITY_UPGRADE_COST:
		return

	_pending_cost += CAPACITY_UPGRADE_COST
	_pending_capacity += CAPACITY_UPGRADE_AMOUNT
	update_display()


func _on_confirm_button_pressed() -> void:
	MusicManager.play_button_sfx()
	if _pending_cost == 0:
		return

	SaveState.club.money -= _pending_cost
	SaveState.club.capacity += _pending_capacity
	_pending_cost = 0
	_pending_capacity = 0
	update_display()


func _on_reset_cart_button_pressed() -> void:
	MusicManager.play_button_sfx()
	_pending_cost = 0
	_pending_capacity = 0
	update_display()


func _on_reset_to_initial_button_pressed() -> void:
	MusicManager.play_button_sfx()
	SaveState.club.money = _initial_money
	SaveState.club.capacity = _initial_capacity
	_pending_cost = 0
	_pending_capacity = 0
	update_display()


func _on_day_results_button_pressed() -> void:
	MusicManager.play_button_sfx()
	var money_spent: int = _initial_money - SaveState.club.money

	_popup_day_label.text = "Day %d Results" % SaveState.club.day
	_popup_initial_money_label.text = "Starting Money: $%d" % _initial_money
	_popup_initial_capacity_label.text = "Starting Capacity: %d" % _initial_capacity
	_popup_current_money_label.text = "Current Money: $%d" % SaveState.club.money
	_popup_current_capacity_label.text = "Current Capacity: %d" % SaveState.club.capacity
	_popup_money_spent_label.text = "Money Spent: $%d" % money_spent

	_day_results_popup.popup_centered()


func _on_start_day_button_pressed() -> void:
	MusicManager.play_button_sfx()
	SaveState.start_day()


func _on_main_menu_button_pressed() -> void:
	MusicManager.play_button_sfx()
	SaveState.switch_to_state(SaveStateClass.State.Menu)
