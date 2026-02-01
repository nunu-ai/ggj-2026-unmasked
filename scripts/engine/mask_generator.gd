class_name MaskGenerator

## Generates randomized Masks with weighted probabilities.
## All weights are relative — they don't need to sum to 100.

# =============================================================================
# COLOR TIERS — determines mask color and base money value
# =============================================================================

const COLOR_TIERS = [
	{ "tier": Mask.ColorTier.GREY,   "weight": 30, "color": Color(0.6, 0.6, 0.6) },
	{ "tier": Mask.ColorTier.GREEN,  "weight": 25, "color": Color(0.2, 0.8, 0.2) },
	{ "tier": Mask.ColorTier.BLUE,   "weight": 20, "color": Color(0.2, 0.4, 0.9) },
	{ "tier": Mask.ColorTier.PURPLE, "weight": 15, "color": Color(0.6, 0.2, 0.8) },
	{ "tier": Mask.ColorTier.ORANGE, "weight": 8,  "color": Color(1.0, 0.6, 0.1) },
	{ "tier": Mask.ColorTier.GOLD,   "weight": 2,  "color": Color(1.0, 0.85, 0.0) },
]

# =============================================================================
# MASK BASE TEXTURES
# =============================================================================

const MASK_BASES = [
	{ "value": "res://assets/masks/full-mask-1.png",  "weight": 25 },
	{ "value": "res://assets/masks/half-mask-1.png",  "weight": 25 },
	{ "value": "res://assets/masks/eye-mask-1.png",   "weight": 25 },
	{ "value": "res://assets/masks/eye-mask-2.png",   "weight": 25 },
]

# =============================================================================
# MOUTH TEXTURES — grouped by mood
# =============================================================================

const MOUTH_MOOD_WEIGHTS = [
	{ "mood": Mask.Mood.HAPPY,   "weight": 30 },
	{ "mood": Mask.Mood.NEUTRAL, "weight": 50 },
	{ "mood": Mask.Mood.SAD,     "weight": 20 },
]

const MOUTHS_HAPPY = [
	{ "value": "res://assets/masks/mouths/happy/1.png", "weight": 100 },
]

const MOUTHS_NEUTRAL = [
	{ "value": "res://assets/masks/mouths/neutral/1.png", "weight": 50 },
	{ "value": "res://assets/masks/mouths/neutral/2.png", "weight": 50 },
]

const MOUTHS_SAD = [
	{ "value": "res://assets/masks/mouths/sad/1.png", "weight": 100 },
]

# =============================================================================
# UPPER DECOS — carneval category
# =============================================================================

## Which upper deco category to use
const UPPER_DECO_CATEGORIES = [
	{ "value": "none",     "weight": 30 },
	{ "value": "carneval", "weight": 40 },
	{ "value": "horns",    "weight": 30 },
	{ "value": "flower",   "weight": 30 }
]

const UPPER_DECOS_CARNEVAL = [
	{ "value": "res://assets/masks/upper_decos/carneval/1.png", "weight": 25 },
	{ "value": "res://assets/masks/upper_decos/carneval/3.png", "weight": 25 },
	{ "value": "res://assets/masks/upper_decos/carneval/6.png", "weight": 25 },
	{ "value": "res://assets/masks/upper_decos/carneval/8.png", "weight": 25 },
]

const UPPER_DECOS_HORNS = [
	{ "value": "res://assets/masks/upper_decos/horns/1.png", "weight": 50 },
	{ "value": "res://assets/masks/upper_decos/horns/2.png", "weight": 50 },
	{ "value": "res://assets/masks/upper_decos/horns/3.png", "weight": 50 },
	{ "value": "res://assets/masks/upper_decos/horns/4.png", "weight": 50 },
]

const UPPER_DECOS_FLOWER = [
	{ "value": "res://assets/masks/upper_decos/flower/1.png", "weight": 50 },
	{ "value": "res://assets/masks/upper_decos/flower/2.png", "weight": 50 },
	{ "value": "res://assets/masks/upper_decos/flower/3.png", "weight": 50 },
	{ "value": "res://assets/masks/upper_decos/flower/4.png", "weight": 50 },
]

# =============================================================================
# LOWER DECOS — roman and stars categories
# Lower deco picks one category first, then picks within it
# =============================================================================

## Which lower deco category to use
const LOWER_DECO_CATEGORIES = [
	{ "value": "none",   "weight": 25 },
	{ "value": "roman",  "weight": 40 },
	{ "value": "stars",  "weight": 35 },
	{ "value": "cards",  "weight": 40 }
]

const LOWER_DECOS_ROMAN = [
	{ "value": "res://assets/masks/lower_decos/roman/1.png", "weight": 20 },
	{ "value": "res://assets/masks/lower_decos/roman/2.png", "weight": 20 },
	{ "value": "res://assets/masks/lower_decos/roman/3.png", "weight": 20 },
	{ "value": "res://assets/masks/lower_decos/roman/4.png", "weight": 15 },
	{ "value": "res://assets/masks/lower_decos/roman/5.png", "weight": 15 },
	{ "value": "res://assets/masks/lower_decos/roman/6.png", "weight": 10 },
]

const LOWER_DECOS_CARDS = [
	{ "value": "res://assets/masks/lower_decos/cards/clubs.png", "weight": 20},
	{ "value": "res://assets/masks/lower_decos/cards/diamond.png", "weight": 20},
	{ "value": "res://assets/masks/lower_decos/cards/heart.png", "weight": 20},
	{ "value": "res://assets/masks/lower_decos/cards/spades.png", "weight": 20},
]

## Stars — each star adds 50 money
const LOWER_DECOS_STARS = [
	{ "value": "res://assets/masks/lower_decos/stars/1.png", "weight": 50, "stars": 1 },
	{ "value": "res://assets/masks/lower_decos/stars/2.png", "weight": 35, "stars": 2 },
	{ "value": "res://assets/masks/lower_decos/stars/3.png", "weight": 15, "stars": 3 },
]


# =============================================================================
# GENERATION
# =============================================================================

## Generate a fully randomized Mask, optionally influenced by a DailyTheme
static func generate(theme: DailyTheme = null) -> Mask:
	# Pick color tier
	var tier_entry = _weighted_pick(COLOR_TIERS)
	var color_tier: Mask.ColorTier = tier_entry["tier"]
	var color: Color = tier_entry["color"]

	# Pick mask base
	var mask_path: String = _weighted_pick(MASK_BASES)["value"]

	# Pick mouth mood, then mouth texture
	var mood_entry = _weighted_pick(MOUTH_MOOD_WEIGHTS)
	var mood: Mask.Mood = mood_entry["mood"]
	var mouth_path: String
	match mood:
		Mask.Mood.HAPPY:
			mouth_path = _weighted_pick(MOUTHS_HAPPY)["value"]
		Mask.Mood.SAD:
			mouth_path = _weighted_pick(MOUTHS_SAD)["value"]
		_:
			mouth_path = _weighted_pick(MOUTHS_NEUTRAL)["value"]

	# Pick upper deco category, then pick within it
	# Apply theme bonus to the boosted category's weight
	var upper_categories = _apply_theme_bonus(UPPER_DECO_CATEGORIES, theme)
	var upper_category: String = _weighted_pick(upper_categories)["value"]
	var upper_deco_path: String = ""
	var upper_deco_color: Color = Color(randf(), randf(), randf())

	match upper_category:
		"carneval":
			upper_deco_path = _weighted_pick(UPPER_DECOS_CARNEVAL)["value"]
		"horns":
			upper_deco_path = _weighted_pick(UPPER_DECOS_HORNS)["value"]
		"flower":
			upper_deco_path = _weighted_pick(UPPER_DECOS_FLOWER)["value"]

		_:  # "none"
			upper_deco_path = ""

	# Pick lower deco category, then pick within it
	# Apply theme bonus to the boosted lower category's weight
	var lower_categories = _apply_theme_bonus(LOWER_DECO_CATEGORIES, theme, true)
	var lower_category: String = _weighted_pick(lower_categories)["value"]
	var lower_deco_path: String = ""
	var lower_deco_color: Color = Color(randf(), randf(), randf())
	var star_count: int = 0

	match lower_category:
		"roman":
			lower_deco_path = _weighted_pick(LOWER_DECOS_ROMAN)["value"]
		"stars":
			var star_entry = _weighted_pick(LOWER_DECOS_STARS)
			lower_deco_path = star_entry["value"]
			star_count = star_entry["stars"]
		"cards":
			lower_deco_path = _weighted_pick(LOWER_DECOS_CARDS)["value"]
		_:  # "none"
			lower_deco_path = ""

	return Mask.new(
		color_tier,
		color,
		mask_path,
		mouth_path,
		mood,
		upper_deco_path,
		upper_deco_color,
		lower_deco_path,
		lower_deco_color,
		star_count,
	)


# =============================================================================
# WEIGHTED RANDOM HELPER
# =============================================================================

## Returns a copy of categories with the theme-boosted category's weight increased.
## If no theme or no matching category, returns the original array unchanged.
## Set is_lower to true when applying to lower deco categories.
static func _apply_theme_bonus(categories: Array, theme: DailyTheme, is_lower: bool = false) -> Array:
	if theme == null:
		return categories

	var boosted: String
	if is_lower:
		boosted = theme.boosted_lower_category()
	else:
		boosted = theme.boosted_upper_category()

	if boosted == "":
		return categories

	var bonus: float = theme.bonus_percent() / 100.0  # e.g. 100% -> 1.0 multiplier

	var result: Array = []
	for entry in categories:
		if entry["value"] == boosted:
			var modified = entry.duplicate()
			modified["weight"] = entry["weight"] * (1.0 + bonus)
			result.append(modified)
		else:
			result.append(entry)
	return result


## Pick a random entry from an array of dictionaries with "weight" keys.
## Returns the full dictionary entry.
static func _weighted_pick(entries: Array) -> Dictionary:
	var total_weight: float = 0.0
	for entry in entries:
		total_weight += entry["weight"]

	var roll: float = randf() * total_weight
	var cumulative: float = 0.0

	for entry in entries:
		cumulative += entry["weight"]
		if roll <= cumulative:
			return entry

	# Fallback (shouldn't happen)
	return entries[entries.size() - 1]
