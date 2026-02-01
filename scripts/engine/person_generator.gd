class_name PersonGenerator

# =============================================================================
# PERSON GENERATOR
# Generates random people with masks, money, and optional rules
# =============================================================================


## Generate a single random person
static func generate_person(_theme: DailyTheme = null) -> Person:
	var person_name = _generate_name()
	var mask = MaskGenerator.generate()
	var rules = _maybe_generate_rules()

	return Person.new(person_name, [], mask, rules)


## Generate a random name
static func _generate_name() -> String:
	var first_name = _pick_random(Constants.FIRST_NAMES_MALE + Constants.FIRST_NAMES_FEMALE)
	var last_name = _pick_random(Constants.LAST_NAMES)
	return first_name + " " + last_name


## Maybe generate personal rules for this person
## Most people don't have rules - probability handled here
static func _maybe_generate_rules() -> Array[Rule]:
	var rules: Array[Rule] = []

	# Low chance of having personal rules (10%)
	if randf() < 0.1:
		var available = Rule.get_available_rules()
		if available.size() > 0:
			rules.append(_pick_random(available))

	return rules


## Pick a random element from an array
static func _pick_random(arr: Array) -> Variant:
	return arr[randi() % arr.size()]
