class_name DislikeProfession
extends Trait

var dislike_profession: String


func _init(_dislike_profession: String):
	self.dislike_profession = _dislike_profession


func name():
	return "Dislike Profession"


func description():
	return "Dislikes %ss" % self.dislike_profession


func tags():
	return []


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	for t in trait_set.get_traits_by_tag("profession"):
		if t is Profession and t != self:
			if self.dislike_profession == t.kind:
				return -10

	return 0


func explain_score(trait_set: TraitSet, all_people: Array[Person]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for t in trait_set.get_traits_by_tag("profession"):
		if t is Profession and self.dislike_profession == t.kind:
			var owner = _find_trait_owner(t, all_people)
			result.append({
				"reason": "Unhappy to see a %s" % self.dislike_profession,
				"score": -10,
				"triggered_by": owner
			})
			break  # Only one match counts
	
	return result
