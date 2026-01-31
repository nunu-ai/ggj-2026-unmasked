class_name DailyTheme
extends RefCounted

## Represents a daily theme that modifies mask generation probabilities.
## Each theme boosts the weight of a specific upper deco category.

enum ThemeType { NONE, CARNEVAL }

const THEME_BONUS_PERCENT: float = 100.0  # +100% weight bonus (will be modifiable later)

const THEMES = [
	{ "type": ThemeType.NONE,     "weight": 30 },
	{ "type": ThemeType.CARNEVAL, "weight": 70 },
]

var type: ThemeType


func _init(_type: ThemeType) -> void:
	type = _type


## Human-readable name
func theme_name() -> String:
	match type:
		ThemeType.CARNEVAL: return "Carneval"
		_: return "No Theme"


## The upper deco category this theme boosts (or "" for none)
func boosted_category() -> String:
	match type:
		ThemeType.CARNEVAL: return "carneval"
		_: return ""


## The bonus percentage applied to the boosted category's weight
func bonus_percent() -> float:
	if type == ThemeType.NONE:
		return 0.0
	return THEME_BONUS_PERCENT


## Pick a random theme for the day
static func pick_random() -> DailyTheme:
	var total: float = 0.0
	for entry in THEMES:
		total += entry["weight"]

	var roll: float = randf() * total
	var cumulative: float = 0.0

	for entry in THEMES:
		cumulative += entry["weight"]
		if roll <= cumulative:
			return DailyTheme.new(entry["type"])

	return DailyTheme.new(ThemeType.NONE)
