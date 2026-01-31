class_name PrefersElderly
extends Trait

# Prefers older, more experienced people


func name():
	return "Prefers Elderly"


func description():
	return "Prefers mature company"


func tags():
	return ["personality"]


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	var score = 0
	for t in trait_set.get_traits_by_tag("age"):
		if t is Age:
			if t.age >= 50:
				score += 5
			elif t.age < 25:
				score -= 8

	return score
