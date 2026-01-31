class_name Gossip
extends Trait

# Loves drama and gets along with other gossips


func name():
	return "Gossip"


func description():
	return "Loves drama"


func tags():
	return ["personality", "gossip"]


func can_affect_happiness() -> bool:
	return true


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


func explain_score(trait_set: TraitSet, all_people: Array[Person]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var found_gossip = false
	
	for t in trait_set.get_traits_by_tag("gossip"):
		if t is Gossip and t != self:
			found_gossip = true
			var owner = _find_trait_owner(t, all_people)
			result.append({
				"reason": "Found a fellow gossip!",
				"score": 5,
				"triggered_by": owner
			})
	
	if not found_gossip:
		result.append({
			"reason": "No one to gossip with...",
			"score": -3,
			"triggered_by": null
		})
	
	return result
