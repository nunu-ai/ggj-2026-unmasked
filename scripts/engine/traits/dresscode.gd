class_name DressCode
extends Trait

var theme: String


func _init(_theme: String):
	self.theme = _theme


func name():
	return "Dress Code"


func description():
	return "Wearing %s" % self.theme


func tags():
	return ["dresscode"]


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	var score = 0
	for t in trait_set.get_traits_by_tag("dresscode"):
		if t is DressCode and t != self:
			if t.theme == self.theme:
				score += 1
			else:
				score -= 10

	return score


func explain_score(trait_set: TraitSet, all_people: Array[Person]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for t in trait_set.get_traits_by_tag("dresscode"):
		if t is DressCode and t != self:
			var owner = _find_trait_owner(t, all_people)
			if t.theme == self.theme:
				result.append({
					"reason": "Matching %s attire" % self.theme,
					"score": 1,
					"triggered_by": owner
				})
			else:
				result.append({
					"reason": "Clashing dress code (%s vs %s)" % [self.theme, t.theme],
					"score": -10,
					"triggered_by": owner
				})
	
	return result
