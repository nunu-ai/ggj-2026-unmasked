class_name Rule
extends RefCounted

# Rule types enum - add more as game expands
enum RuleType {
	MAX_COLOR_COUNT,      # e.g., "max 3 blue masks"
	MIN_COLOR_COUNT,      # e.g., "at least 2 gold masks"
	EXACT_COLOR_COUNT,    # e.g., "exactly 2 blue masks"
	MIN_TOTAL_STARS,      # e.g., "minimum 5 total stars"
	MAX_TOTAL_STARS,      # e.g., "maximum 8 total stars"
	EQUAL_MOOD_COUNT,     # e.g., "equal happy and sad people"
	NO_UPPER_DECO_TYPE,   # e.g., "no horns present"
	NO_LOWER_DECO_TYPE,   # e.g., "no roman numbers"
	ODD_ROMAN_TOTAL,      # e.g., "odd total of roman numbers"
	EVEN_ROMAN_TOTAL,     # e.g., "even total of roman numbers"
	MIN_MOOD_COUNT,       # e.g., "at least 3 happy people"
	MAX_MOOD_COUNT,       # e.g., "maximum 2 sad people"
	NO_MOOD_TYPE,         # e.g., "no sad people allowed"
	MIN_CARD_SUIT,        # e.g., "at least 2 hearts"
	MAX_CARD_SUIT,        # e.g., "maximum 1 spades"
	# Bonus rule types (positive rewards when achieved)
	BONUS_MIN_CARNEVAL,       # e.g., "Have 5+ carneval masks"
	BONUS_ALL_COLORS,         # e.g., "Have all mask colors"
	BONUS_ALL_MOODS,          # e.g., "Have all three moods"
	BONUS_MIN_UPPER_DECO,     # e.g., "Have 4+ upper decorations"
	BONUS_HIGH_STAR_TOTAL,    # e.g., "Have 10+ total stars"
	BONUS_FULL_CAPACITY,      # e.g., "Club at full capacity"
	BONUS_CARD_FLUSH,         # e.g., "Have 4+ of same card suit"
	BONUS_ROMAN_SUM,          # e.g., "Roman numbers total exactly X"
	BONUS_NO_GREY,            # e.g., "No grey masks (VIP night)"
	BONUS_MOOD_MAJORITY,      # e.g., "Majority happy people"
}

var type: RuleType
var params: Dictionary  # e.g., {"color": "blue", "max": 3}
var penalty: int  # Negative money if violated (or positive for bonus rules)
var description: String
var is_bonus: bool = false  # True for bonus rules that give rewards

func _init(_type: RuleType, _params: Dictionary, _penalty: int, _desc: String, _is_bonus: bool = false):
	type = _type
	params = _params
	penalty = _penalty
	description = _desc
	is_bonus = _is_bonus

# Helper to count masks by color tier
static func _count_by_color(club_people: Array, color_name: String) -> int:
	var count = 0
	for person in club_people:
		if person.mask != null and person.mask.tier_name().to_lower() == color_name:
			count += 1
	return count

# Helper to count total stars in club
static func _count_total_stars(club_people: Array) -> int:
	var total = 0
	for person in club_people:
		if person.mask != null:
			total += person.mask.star_count
	return total

# Helper to count people by mood
static func _count_by_mood(club_people: Array, mood: Mask.Mood) -> int:
	var count = 0
	for person in club_people:
		if person.mask != null and person.mask.mouth_mood == mood:
			count += 1
	return count

# Helper to check if upper deco contains specific type
static func _count_upper_deco_type(club_people: Array, deco_type: String) -> int:
	var count = 0
	for person in club_people:
		if person.mask != null and person.mask.upper_deco_path.contains(deco_type):
			count += 1
	return count

# Helper to check if lower deco contains specific type
static func _count_lower_deco_type(club_people: Array, deco_type: String) -> int:
	var count = 0
	for person in club_people:
		if person.mask != null and person.mask.lower_deco_path.contains(deco_type):
			count += 1
	return count

# Helper to sum roman numbers (files are 1.png through 6.png)
static func _sum_roman_numbers(club_people: Array) -> int:
	var total = 0
	for person in club_people:
		if person.mask != null and person.mask.lower_deco_path.contains("roman"):
			# Extract number from path like "res://assets/masks/lower_decos/roman/3.png"
			var path = person.mask.lower_deco_path
			var filename = path.get_file().get_basename()
			if filename.is_valid_int():
				total += filename.to_int()
	return total

# Helper to count card suits
static func _count_card_suit(club_people: Array, suit: String) -> int:
	var count = 0
	for person in club_people:
		if person.mask != null and person.mask.lower_deco_path.contains("cards/" + suit):
			count += 1
	return count

# Helper to count distinct colors present in club
static func _count_distinct_colors(club_people: Array) -> int:
	var colors_present: Dictionary = {}
	for person in club_people:
		if person.mask != null:
			var color_name = person.mask.tier_name().to_lower()
			colors_present[color_name] = true
	return colors_present.size()

# Helper to get all distinct colors present
static func _get_colors_present(club_people: Array) -> Array:
	var colors_present: Dictionary = {}
	for person in club_people:
		if person.mask != null:
			var color_name = person.mask.tier_name().to_lower()
			colors_present[color_name] = true
	return colors_present.keys()

# Helper to count distinct moods present
static func _count_distinct_moods(club_people: Array) -> int:
	var moods_present: Dictionary = {}
	for person in club_people:
		if person.mask != null:
			moods_present[person.mask.mouth_mood] = true
	return moods_present.size()

# Helper to count people with upper decorations
static func _count_with_upper_deco(club_people: Array) -> int:
	var count = 0
	for person in club_people:
		if person.mask != null and person.mask.upper_deco_path != "":
			count += 1
	return count

# Helper to get max count of any single card suit
static func _get_max_card_suit_count(club_people: Array) -> int:
	var suits = ["heart", "spades", "diamond", "clubs"]
	var max_count = 0
	for suit in suits:
		var count = _count_card_suit(club_people, suit)
		if count > max_count:
			max_count = count
	return max_count

# Check if rule is violated based on current club state
func is_violated(club_people: Array) -> bool:
	match type:
		RuleType.MAX_COLOR_COUNT:
			var count = _count_by_color(club_people, params["color"])
			return count > params["max"]
		
		RuleType.MIN_COLOR_COUNT:
			var count = _count_by_color(club_people, params["color"])
			return count < params["min"]
		
		RuleType.EXACT_COLOR_COUNT:
			var count = _count_by_color(club_people, params["color"])
			return count != params["count"]
		
		RuleType.MIN_TOTAL_STARS:
			var total = _count_total_stars(club_people)
			return total < params["min"]
		
		RuleType.MAX_TOTAL_STARS:
			var total = _count_total_stars(club_people)
			return total > params["max"]
		
		RuleType.EQUAL_MOOD_COUNT:
			var mood1_count = _count_by_mood(club_people, params["mood1"])
			var mood2_count = _count_by_mood(club_people, params["mood2"])
			return mood1_count != mood2_count
		
		RuleType.NO_UPPER_DECO_TYPE:
			var count = _count_upper_deco_type(club_people, params["deco_type"])
			return count > 0
		
		RuleType.NO_LOWER_DECO_TYPE:
			var count = _count_lower_deco_type(club_people, params["deco_type"])
			return count > 0
		
		RuleType.ODD_ROMAN_TOTAL:
			var total = _sum_roman_numbers(club_people)
			return total % 2 == 0  # Violated if even
		
		RuleType.EVEN_ROMAN_TOTAL:
			var total = _sum_roman_numbers(club_people)
			return total % 2 != 0  # Violated if odd
		
		RuleType.MIN_MOOD_COUNT:
			var count = _count_by_mood(club_people, params["mood"])
			return count < params["min"]
		
		RuleType.MAX_MOOD_COUNT:
			var count = _count_by_mood(club_people, params["mood"])
			return count > params["max"]
		
		RuleType.NO_MOOD_TYPE:
			var count = _count_by_mood(club_people, params["mood"])
			return count > 0
		
		RuleType.MIN_CARD_SUIT:
			var count = _count_card_suit(club_people, params["suit"])
			return count < params["min"]
		
		RuleType.MAX_CARD_SUIT:
			var count = _count_card_suit(club_people, params["suit"])
			return count > params["max"]
	
	return false

# Get the penalty amount (returns negative number for penalties, positive for bonuses)
func get_penalty() -> int:
	return penalty

# Check if bonus rule is achieved (only for bonus rules)
func is_achieved(club_people: Array, club_capacity: int = 0) -> bool:
	if not is_bonus:
		return false
	
	match type:
		RuleType.BONUS_MIN_CARNEVAL:
			var count = _count_upper_deco_type(club_people, "carneval")
			return count >= params["min"]
		
		RuleType.BONUS_ALL_COLORS:
			var colors = _get_colors_present(club_people)
			var required = params.get("colors", ["gold", "blue", "green", "grey"])
			for color in required:
				if color not in colors:
					return false
			return true
		
		RuleType.BONUS_ALL_MOODS:
			var mood_count = _count_distinct_moods(club_people)
			return mood_count >= 3  # Happy, Sad, Neutral
		
		RuleType.BONUS_MIN_UPPER_DECO:
			var count = _count_with_upper_deco(club_people)
			return count >= params["min"]
		
		RuleType.BONUS_HIGH_STAR_TOTAL:
			var total = _count_total_stars(club_people)
			return total >= params["min"]
		
		RuleType.BONUS_FULL_CAPACITY:
			return club_capacity > 0 and club_people.size() >= club_capacity
		
		RuleType.BONUS_CARD_FLUSH:
			var max_suit = _get_max_card_suit_count(club_people)
			return max_suit >= params["min"]
		
		RuleType.BONUS_ROMAN_SUM:
			var total = _sum_roman_numbers(club_people)
			return total == params["target"]
		
		RuleType.BONUS_NO_GREY:
			var grey_count = _count_by_color(club_people, "grey")
			return club_people.size() > 0 and grey_count == 0
		
		RuleType.BONUS_MOOD_MAJORITY:
			var mood = params["mood"]
			var mood_count = _count_by_mood(club_people, mood)
			var half = club_people.size() / 2.0
			return mood_count > half
	
	return false

# Get bonus amount (only returns value if achieved)
func get_bonus(club_people: Array, club_capacity: int = 0) -> int:
	if is_bonus and is_achieved(club_people, club_capacity):
		return penalty  # For bonus rules, penalty is positive (the reward)
	return 0

# Get all available rules (for personal rules on people)
static func get_available_rules() -> Array[Rule]:
	var all_rules: Array[Rule] = []
	all_rules.append_array(get_easy_rules())
	all_rules.append_array(get_medium_rules())
	return all_rules  # Exclude hard rules for personal rules

# All available rules (categorized by difficulty)
static func get_easy_rules() -> Array[Rule]:
	return [
		# Color limits
		Rule.new(RuleType.MAX_COLOR_COUNT, {"color": "blue", "max": 3}, -100, "Maximum of 3 blue masks"),
		Rule.new(RuleType.MAX_COLOR_COUNT, {"color": "green", "max": 3}, -100, "Maximum of 3 green masks"),
		Rule.new(RuleType.MAX_COLOR_COUNT, {"color": "grey", "max": 4}, -100, "Maximum of 4 grey masks"),
		Rule.new(RuleType.MIN_COLOR_COUNT, {"color": "gold", "min": 1}, -100, "At least 1 gold mask required"),
		
		# Mood rules
		Rule.new(RuleType.MAX_MOOD_COUNT, {"mood": Mask.Mood.SAD, "max": 2}, -100, "Maximum of 2 sad people"),
		Rule.new(RuleType.MIN_MOOD_COUNT, {"mood": Mask.Mood.HAPPY, "min": 2}, -100, "At least 2 happy people"),
	]

static func get_medium_rules() -> Array[Rule]:
	return [
		# Exact color counts
		Rule.new(RuleType.EXACT_COLOR_COUNT, {"color": "blue", "count": 2}, -125, "Exactly 2 blue masks required"),
		Rule.new(RuleType.EXACT_COLOR_COUNT, {"color": "purple", "count": 1}, -125, "Exactly 1 purple mask required"),
		
		# Star rules
		Rule.new(RuleType.MIN_TOTAL_STARS, {"min": 5}, -150, "Minimum 5 total stars"),
		Rule.new(RuleType.MIN_TOTAL_STARS, {"min": 3}, -100, "Minimum 3 total stars"),
		Rule.new(RuleType.MAX_TOTAL_STARS, {"max": 6}, -125, "Maximum 6 total stars"),
		
		# Mood balance
		Rule.new(RuleType.EQUAL_MOOD_COUNT, {"mood1": Mask.Mood.HAPPY, "mood2": Mask.Mood.SAD}, -150, "Equal number of happy and sad people"),
		
		# No specific decorations
		Rule.new(RuleType.NO_UPPER_DECO_TYPE, {"deco_type": "horns"}, -125, "No horns allowed"),
		Rule.new(RuleType.NO_UPPER_DECO_TYPE, {"deco_type": "carneval"}, -125, "No carnival decorations"),
		
		# Card suits
		Rule.new(RuleType.MIN_CARD_SUIT, {"suit": "heart", "min": 1}, -100, "At least 1 heart card"),
		Rule.new(RuleType.MAX_CARD_SUIT, {"suit": "spades", "max": 1}, -100, "Maximum 1 spades card"),
	]

static func get_hard_rules() -> Array[Rule]:
	return [
		# Roman number rules
		Rule.new(RuleType.ODD_ROMAN_TOTAL, {}, -175, "Odd total of roman numbers"),
		Rule.new(RuleType.EVEN_ROMAN_TOTAL, {}, -175, "Even total of roman numbers"),
		Rule.new(RuleType.NO_LOWER_DECO_TYPE, {"deco_type": "roman"}, -150, "No roman numbers allowed"),
		
		# Strict mood rules
		Rule.new(RuleType.NO_MOOD_TYPE, {"mood": Mask.Mood.SAD}, -200, "No sad people allowed"),
		Rule.new(RuleType.MIN_MOOD_COUNT, {"mood": Mask.Mood.HAPPY, "min": 3}, -150, "At least 3 happy people"),
		
		# Strict color rules
		Rule.new(RuleType.MIN_COLOR_COUNT, {"color": "purple", "min": 2}, -175, "At least 2 purple masks"),
		Rule.new(RuleType.MIN_COLOR_COUNT, {"color": "orange", "min": 1}, -200, "At least 1 orange mask"),
		Rule.new(RuleType.EXACT_COLOR_COUNT, {"color": "green", "count": 3}, -150, "Exactly 3 green masks"),
		
		# High star requirements
		Rule.new(RuleType.MIN_TOTAL_STARS, {"min": 8}, -200, "Minimum 8 total stars"),
		
		# Complex card rules
		Rule.new(RuleType.MIN_CARD_SUIT, {"suit": "diamond", "min": 2}, -150, "At least 2 diamond cards"),
		Rule.new(RuleType.NO_LOWER_DECO_TYPE, {"deco_type": "cards"}, -125, "No playing cards allowed"),
		Rule.new(RuleType.NO_LOWER_DECO_TYPE, {"deco_type": "stars"}, -125, "No star decorations allowed"),
	]

# =============================================================================
# BONUS RULES - Positive rewards for achieving goals
# =============================================================================

static func get_easy_bonus_rules() -> Array[Rule]:
	return [
		Rule.new(RuleType.BONUS_ALL_MOODS, {}, 150, "Mood Variety: Have all 3 mood types", true),
		Rule.new(RuleType.BONUS_MIN_UPPER_DECO, {"min": 3}, 100, "Decorated Party: 3+ upper decorations", true),
		Rule.new(RuleType.BONUS_MOOD_MAJORITY, {"mood": Mask.Mood.HAPPY}, 120, "Happy Hour: Majority happy people", true),
	]

static func get_medium_bonus_rules() -> Array[Rule]:
	return [
		Rule.new(RuleType.BONUS_MIN_CARNEVAL, {"min": 3}, 200, "Carnival Night: 3+ carneval masks", true),
		Rule.new(RuleType.BONUS_HIGH_STAR_TOTAL, {"min": 8}, 180, "Star Studded: 8+ total stars", true),
		Rule.new(RuleType.BONUS_CARD_FLUSH, {"min": 3}, 150, "Card Flush: 3+ same card suit", true),
		Rule.new(RuleType.BONUS_NO_GREY, {}, 200, "VIP Night: No grey masks", true),
		Rule.new(RuleType.BONUS_ALL_COLORS, {"colors": ["gold", "blue", "green"]}, 175, "Color Trio: Gold, Blue & Green masks", true),
	]

static func get_hard_bonus_rules() -> Array[Rule]:
	return [
		Rule.new(RuleType.BONUS_MIN_CARNEVAL, {"min": 5}, 400, "Grand Carnival: 5+ carneval masks", true),
		Rule.new(RuleType.BONUS_ALL_COLORS, {"colors": ["gold", "blue", "green", "grey", "purple"]}, 350, "Rainbow Club: 5 different mask colors", true),
		Rule.new(RuleType.BONUS_HIGH_STAR_TOTAL, {"min": 12}, 300, "Constellation: 12+ total stars", true),
		Rule.new(RuleType.BONUS_FULL_CAPACITY, {}, 250, "Full House: Club at full capacity", true),
		Rule.new(RuleType.BONUS_CARD_FLUSH, {"min": 4}, 300, "Royal Flush: 4+ same card suit", true),
		Rule.new(RuleType.BONUS_ROMAN_SUM, {"target": 10}, 350, "Perfect Ten: Roman numbers sum to 10", true),
	]

# Get bonus rules for a specific day
static func get_day_bonus_rules(day: int) -> Array[Rule]:
	var easy = get_easy_bonus_rules()
	var medium = get_medium_bonus_rules()
	var hard = get_hard_bonus_rules()
	
	# Shuffle for variety
	easy.shuffle()
	medium.shuffle()
	hard.shuffle()
	
	var rules: Array[Rule] = []
	
	match day:
		1:
			# Day 1: 1 easy bonus
			rules.append(easy[0])
		2:
			# Day 2: 1 easy bonus
			rules.append(easy[0])
		3:
			# Day 3: 1 easy, 1 medium bonus
			rules.append(easy[0])
			rules.append(medium[0])
		4:
			# Day 4: 1 medium bonus
			rules.append(medium[0])
		5:
			# Day 5: 1 medium, 1 hard bonus
			rules.append(medium[0])
			rules.append(hard[0])
		6:
			# Day 6: 2 medium bonuses
			rules.append(medium[0])
			rules.append(medium[1])
		7:
			# Day 7: 1 medium, 1 hard bonus
			rules.append(medium[0])
			rules.append(hard[0])
		_:
			# Day 8+: 2 hard bonuses
			rules.append(hard[0])
			if hard.size() > 1:
				rules.append(hard[1])
	
	return rules

# Get global rules for a specific day
static func get_day_rules(day: int) -> Array[Rule]:
	var easy = get_easy_rules()
	var medium = get_medium_rules()
	var hard = get_hard_rules()
	
	# Shuffle all rule pools for variety
	easy.shuffle()
	medium.shuffle()
	hard.shuffle()
	
	var rules: Array[Rule] = []
	
	match day:
		1:
			# Day 1: 1 easy rule
			rules.append(easy[0])
		2:
			# Day 2: 2 easy rules
			rules.append(easy[0])
			rules.append(easy[1])
		3:
			# Day 3: 1 easy, 1 medium
			rules.append(easy[0])
			rules.append(medium[0])
		4:
			# Day 4: 2 medium rules
			rules.append(medium[0])
			rules.append(medium[1])
		5:
			# Day 5: 1 medium, 1 hard
			rules.append(medium[0])
			rules.append(hard[0])
		6:
			# Day 6: 2 medium, 1 hard
			rules.append(medium[0])
			rules.append(medium[1])
			rules.append(hard[0])
		7:
			# Day 7: 1 medium, 2 hard
			rules.append(medium[0])
			rules.append(hard[0])
			rules.append(hard[1])
		_:
			# Day 8+: 3 hard rules (escalating difficulty)
			var num_rules = mini(day - 5, 4)  # 3-4 hard rules
			for i in range(num_rules):
				if i < hard.size():
					rules.append(hard[i])
	
	return rules
