class_name PersonGenerator

# =============================================================================
# PERSON GENERATOR
# Generates random people with masks, money, and optional rules
# 
# TODO: This is a stub - friend will implement the full generator
# =============================================================================


## Generate a single random person
## This is the main function that should be implemented
static func generate_person() -> Person:
	# Stub implementation - generates a basic person
	# Friend will replace this with proper generation logic including:
	# - Random name generation
	# - Mask generation (color determines money)
	# - Optional rules (with probability)
	
	var name = _generate_name()
	var mask = _generate_mask()
	var rules = _maybe_generate_rules()
	
	return Person.new(name, mask, rules)


## Generate a random name
static func _generate_name() -> String:
	var first_name = _pick_random(Constants.FIRST_NAMES_MALE + Constants.FIRST_NAMES_FEMALE)
	var last_name = _pick_random(Constants.LAST_NAMES)
	return first_name + " " + last_name


## Generate a random mask
## Mask color determines the money value
static func _generate_mask() -> Mask:
	var color = _pick_random(Constants.MASK_COLORS)
	var decoration = _pick_random(Constants.MASK_DECORATIONS)
	return Mask.new(color, decoration)


## Maybe generate personal rules for this person
## Most people don't have rules - probability handled here
static func _maybe_generate_rules() -> Array[Rule]:
	var rules: Array[Rule] = []
	
	# Low chance of having personal rules (10%)
	# TODO: Friend can adjust this probability
	if randf() < 0.1:
		var available = Rule.get_available_rules()
		if available.size() > 0:
			rules.append(_pick_random(available))
	
	return rules


## Pick a random element from an array
static func _pick_random(arr: Array) -> Variant:
	return arr[randi() % arr.size()]
