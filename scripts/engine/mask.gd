class_name Mask
extends RefCounted

## Represents a person's mask appearance and its associated money value.
## Stores texture paths (not Texture2D) so it's serializable.

enum ColorTier { GREY, GREEN, BLUE, PURPLE, ORANGE, GOLD }
enum Mood { HAPPY, NEUTRAL, SAD }

const TIER_MONEY: Dictionary = {
	ColorTier.GREY: 100,
	ColorTier.GREEN: 200,
	ColorTier.BLUE: 300,
	ColorTier.PURPLE: 500,
	ColorTier.ORANGE: 1000,
	ColorTier.GOLD: 5000,
}

const MOOD_BONUS: Dictionary = {
	Mood.HAPPY: 20,
	Mood.NEUTRAL: 0,
	Mood.SAD: -20,
}

# Visual data
var color_tier: ColorTier
var color: Color
var mask_path: String
var mouth_path: String
var mouth_mood: Mood
var upper_deco_path: String  ## "" = no deco
var upper_deco_color: Color
var lower_deco_path: String  ## "" = no deco
var lower_deco_color: Color
var star_count: int = 0


func _init(
	_color_tier: ColorTier,
	_color: Color,
	_mask_path: String,
	_mouth_path: String,
	_mouth_mood: Mood,
	_upper_deco_path: String,
	_upper_deco_color: Color,
	_lower_deco_path: String,
	_lower_deco_color: Color,
	_star_count: int,
) -> void:
	color_tier = _color_tier
	color = _color
	mask_path = _mask_path
	mouth_path = _mouth_path
	mouth_mood = _mouth_mood
	upper_deco_path = _upper_deco_path
	upper_deco_color = _upper_deco_color
	lower_deco_path = _lower_deco_path
	lower_deco_color = _lower_deco_color
	star_count = _star_count


## Total money value of this mask
func money() -> int:
	var total: int = TIER_MONEY[color_tier]
	total += star_count * 50
	total += MOOD_BONUS[mouth_mood]
	return total


## Alias for compatibility with code that calls get_money_value()
func get_money_value() -> int:
	return money()


## Human-readable tier name
func tier_name() -> String:
	match color_tier:
		ColorTier.GREY: return "Grey"
		ColorTier.GREEN: return "Green"
		ColorTier.BLUE: return "Blue"
		ColorTier.PURPLE: return "Purple"
		ColorTier.ORANGE: return "Orange"
		ColorTier.GOLD: return "Gold"
	return "Unknown"


## Human-readable mood name
func mood_name() -> String:
	match mouth_mood:
		Mood.HAPPY: return "Happy"
		Mood.NEUTRAL: return "Neutral"
		Mood.SAD: return "Sad"
	return "Unknown"
