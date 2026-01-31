class_name LikeProfession
extends Trait

var like_profession: String


func _init(_like_profession: String):
	self.like_profession = _like_profession


func name():
	return "Like Profession"


func description():
	return "Likes %ss" % self.like_profession


func tags():
	return []


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	for t in trait_set.get_traits_by_tag("profession"):
		if t is Profession:
			if self.like_profession == t.kind:
				return 5

	return 0


func explain_score(trait_set: TraitSet, all_people: Array[Person]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for t in trait_set.get_traits_by_tag("profession"):
		if t is Profession and self.like_profession == t.kind:
			var owner = _find_trait_owner(t, all_people)
			result.append({
				"reason": "Happy to meet a %s" % self.like_profession,
				"score": 5,
				"triggered_by": owner
			})
			break  # Only one match counts
	
	return result
