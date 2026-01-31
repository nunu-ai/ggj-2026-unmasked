class_name DislikeHobby
extends Trait

var dislike_hobby: String


func _init(_dislike_hobby: String):
	self.dislike_hobby = _dislike_hobby


func name():
	return "Dislike Hobby"


func description():
	return "Dislikes %s" % self.dislike_hobby


func tags():
	return []


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	for t in trait_set.get_traits_by_tag("hobby"):
		if t is Hobby:
			if self.dislike_hobby == t.kind:
				return -10

	return 0


func explain_score(trait_set: TraitSet, all_people: Array[Person]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for t in trait_set.get_traits_by_tag("hobby"):
		if t is Hobby and self.dislike_hobby == t.kind:
			var owner = _find_trait_owner(t, all_people)
			result.append({
				"reason": "Annoyed by %s enthusiast" % self.dislike_hobby,
				"score": -10,
				"triggered_by": owner
			})
			break  # Only one match counts
	
	return result
