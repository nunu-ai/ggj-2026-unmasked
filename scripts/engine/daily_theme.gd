class_name DailyTheme
extends RefCounted

## Represents a daily theme that modifies mask generation probabilities.
## Each theme boosts the weight of a specific deco category (upper or lower).

enum ThemeType { NONE, CARNEVAL, ROMAN, STARS, HORNS }

const THEME_BONUS_PERCENT: float = 100.0  # +100% weight bonus (will be modifiable later)

const THEMES = [
	{ "type": ThemeType.NONE,     "weight": 20 },
	{ "type": ThemeType.CARNEVAL, "weight": 20 },
	{ "type": ThemeType.ROMAN,    "weight": 20 },
	{ "type": ThemeType.STARS,    "weight": 20 },
	{ "type": ThemeType.HORNS,    "weight": 20 },
]

var type: ThemeType


func _init(_type: ThemeType) -> void:
	type = _type


## Human-readable name
func theme_name() -> String:
	match type:
		ThemeType.CARNEVAL: return "Carneval"
		ThemeType.ROMAN:    return "Roman"
		ThemeType.STARS:    return "Stars"
		ThemeType.HORNS:    return "Horns"
		_: return "No Theme"


## The upper deco category this theme boosts (or "" for none)
func boosted_upper_category() -> String:
	match type:
		ThemeType.CARNEVAL: return "carneval"
		ThemeType.HORNS:    return "horns"
		_: return ""


## The lower deco category this theme boosts (or "" for none)
func boosted_lower_category() -> String:
	match type:
		ThemeType.ROMAN: return "roman"
		ThemeType.STARS: return "stars"
		_: return ""


## Legacy alias — returns the boosted upper category (kept for compatibility)
func boosted_category() -> String:
	return boosted_upper_category()


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
