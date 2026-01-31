class_name Snob
extends Trait

# Snobs dislike people from lower social classes


func name():
	return "Snob"


func description():
	return "Looks down on lower social classes"


func tags():
	return ["personality"]


func calc_score(trait_set: TraitSet):
	var score = 0
	for t in trait_set.get_traits_by_tag("social_class"):
		if t is SocialClass:
			if t.tier == "lower":
				score -= 15
			elif t.tier == "middle":
				score -= 5

	return score
