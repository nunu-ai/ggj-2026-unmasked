class_name LikeHobby
extends Trait

var like_hobby: String


func _init(_like_hobby: String):
	self.like_hobby = _like_hobby


func name():
	return "Like Hobby"


func description():
	return "Likes %s fans" % self.like_hobby


func tags():
	return []


func can_affect_happiness() -> bool:
	return true


func calc_score(trait_set: TraitSet):
	for t in trait_set.get_traits_by_tag("hobby"):
		if t is Hobby:
			if self.like_hobby == t.kind:
				return 5

	return 0


func explain_score(trait_set: TraitSet, all_people: Array[Person]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for t in trait_set.get_traits_by_tag("hobby"):
		if t is Hobby and self.like_hobby == t.kind:
			var owner = _find_trait_owner(t, all_people)
			result.append({
				"reason": "Found a %s enthusiast" % self.like_hobby,
				"score": 5,
				"triggered_by": owner
			})
			break  # Only one match counts
	
	return result
