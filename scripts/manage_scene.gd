extends Control

const CAPACITY_UPGRADE_COST: int = 1000
const CAPACITY_UPGRADE_AMOUNT: int = 5

# Daily overview labels
@onready var _day_label: Label = $VBoxContainer/ManageContent/RightPane/DailyOverview/VBoxContainer/DayLabel
@onready var _money_label: Label = $VBoxContainer/ManageContent/RightPane/DailyOverview/VBoxContainer/MoneyLabel
@onready var _capacity_label: Label = $VBoxContainer/ManageContent/RightPane/DailyOverview/VBoxContainer/CapacityLabel

# Upgrade button
@onready var _capacity_upgrade_button: Button = $VBoxContainer/ManageContent/RightPane/Upgrades/MarginContainer/VBoxContainer/CapacityUpgrade/UpgradeButton

# Checkout overview labels
@onready var _cost_label: Label = $VBoxContainer/ManageContent/RightPane/CheckoutOverview/VBoxContainer/CostLabel
@onready var _money_after_label: Label = $VBoxContainer/ManageContent/RightPane/CheckoutOverview/VBoxContainer/MoneyAfterLabel
@onready var _capacity_after_label: Label = $VBoxContainer/ManageContent/RightPane/CheckoutOverview/VBoxContainer/CapacityAfterLabel
@onready var _confirm_button: Button = $VBoxContainer/ManageContent/RightPane/CheckoutOverview/VBoxContainer/ConfirmButton

# Pending upgrade totals
var _pending_cost: int = 0
var _pending_capacity: int = 0


func _ready() -> void:
	_capacity_upgrade_button.text = "$%d" % CAPACITY_UPGRADE_COST
	update_display()


func update_display() -> void:
	# Current state
	_day_label.text = "Day: %d" % SaveState.club.day
	_money_label.text = "Money: $%d" % SaveState.club.money
	_capacity_label.text = "Capacity: %d" % SaveState.club.capacity

	# Checkout preview
	_cost_label.text = "Cost: $%d" % _pending_cost
	_money_after_label.text = "Money: $%d" % (SaveState.club.money - _pending_cost)
	_capacity_after_label.text = "New Capacity: %d" % (SaveState.club.capacity + _pending_capacity)

	# Disable upgrade button if can't afford with pending costs
	_capacity_upgrade_button.disabled = (SaveState.club.money - _pending_cost) < CAPACITY_UPGRADE_COST

	# Disable confirm button if nothing to confirm
	_confirm_button.disabled = _pending_cost == 0


func _on_upgrade_button_pressed() -> void:
	if (SaveState.club.money - _pending_cost) < CAPACITY_UPGRADE_COST:
		return

	_pending_cost += CAPACITY_UPGRADE_COST
	_pending_capacity += CAPACITY_UPGRADE_AMOUNT
	update_display()


func _on_confirm_button_pressed() -> void:
	if _pending_cost == 0:
		return

	SaveState.club.money -= _pending_cost
	SaveState.club.capacity += _pending_capacity
	_pending_cost = 0
	_pending_capacity = 0
	update_display()


func _on_start_day_button_pressed() -> void:
	SaveState.start_day()


func _on_main_menu_button_pressed() -> void:
	SaveState.switch_to_state(SaveStateClass.State.Menu)
