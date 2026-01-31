class_name Gossip
extends Trait

# Loves drama and gets along with other gossips


func name():
	return "Gossip"


func description():
	return "Loves sharing rumors and drama"


func tags():
	return ["personality", "gossip"]


func calc_score(trait_set: TraitSet):
	var score = 0
	var found_gossip = false
	
	for t in trait_set.get_traits_by_tag("gossip"):
		if t is Gossip and t != self:
			found_gossip = true
			score += 5  # Bonus for each fellow gossip
	
	if not found_gossip:
		score -= 3  # Penalty if no one to gossip with

	return score
