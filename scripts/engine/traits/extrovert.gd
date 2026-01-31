class_name Extrovert
extends Trait

# Thrives in larger groups - happiness increases with group size


func name():
	return "Extrovert"


func description():
	return "Loves crowds"


func tags():
	return ["personality"]


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	# Count how many different people are represented (by counting unique age traits as proxy)
	var person_count = trait_set.get_traits_by_tag("age").size()

	if person_count <= 2:
		return -3  # Small group penalty
	elif person_count <= 4:
		return 2  # Medium group bonus
	else:
		return (person_count - 4) * 2 + 2  # Bonus for larger groups
