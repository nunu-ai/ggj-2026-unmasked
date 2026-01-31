class_name Rule
extends RefCounted

# Rule types enum - add more as game expands
enum RuleType {
	MAX_COLOR_COUNT,  # e.g., "max 3 blue masks"
	MIN_COLOR_COUNT,  # e.g., "at least 2 gold masks"
	# Add more rule types here as the game expands
}

var type: RuleType
var params: Dictionary  # e.g., {"color": "blue", "max": 3}
var penalty: int  # Negative money if violated
var description: String

func _init(_type: RuleType, _params: Dictionary, _penalty: int, _desc: String):
	type = _type
	params = _params
	penalty = _penalty
	description = _desc

# Check if rule is violated based on current club state
func is_violated(club_people: Array) -> bool:
	match type:
		RuleType.MAX_COLOR_COUNT:
			var count = 0
			for person in club_people:
				if person.mask.color == params["color"]:
					count += 1
			return count > params["max"]
		RuleType.MIN_COLOR_COUNT:
			var count = 0
			for person in club_people:
				if person.mask.color == params["color"]:
					count += 1
			return count < params["min"]
	return false

# Get the penalty amount (returns negative number)
func get_penalty() -> int:
	return penalty

# All available rules (add more here for later days)
static func get_available_rules() -> Array[Rule]:
	return [
		Rule.new(
			RuleType.MAX_COLOR_COUNT,
			{"color": "blue", "max": 3},
			-50,
			"Maximum of 3 blue masks allowed"
		),
	]

# Get global rules for a specific day
static func get_day_rules(day: int) -> Array[Rule]:
	var all_rules = get_available_rules()
	match day:
		1: return [all_rules[0]]  # Day 1: just 1 rule
		_: return [all_rules[0]]  # Expand later
