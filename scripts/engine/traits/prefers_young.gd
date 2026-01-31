class_name PrefersYoung
extends Trait

# Prefers younger people, dislikes older people


func name():
	return "Prefers Young"


func description():
	return "Prefers younger company"


func tags():
	return ["personality"]


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	var score = 0
	for t in trait_set.get_traits_by_tag("age"):
		if t is Age:
			if t.age < 30:
				score += 5
			elif t.age > 50:
				score -= 10

	return score
