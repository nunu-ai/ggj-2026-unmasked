class_name Introvert
extends Trait

# Gets overwhelmed in larger groups - happiness decreases with group size
# This trait calculates a penalty based on how many people are in the trait set


func name():
	return "Introvert"


func description():
	return "Prefers small groups"


func tags():
	return ["personality"]


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	# Count how many different people are represented (by counting unique age traits as proxy)
	var person_count = trait_set.get_traits_by_tag("age").size()

	if person_count <= 2:
		return 3  # Small group bonus
	elif person_count <= 4:
		return 0  # Neutral
	else:
		return -(person_count - 4) * 3  # Penalty for larger groups
