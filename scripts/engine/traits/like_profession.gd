class_name LikeProfession
extends Trait

var like_profession: String


func _init(_like_profession: String):
	self.like_profession = _like_profession


func name():
	return "Like Profession"


func display_value():
	return "Likes %ss" % self.like_profession


func description():
	return "Enjoys the company of a certain profession"


func tags():
	return []


func calc_score(trait_set: TraitSet):
	for t in trait_set.get_traits_by_tag("profession"):
		if t is Profession:
			if self.like_profession == t.kind:
				return 5

	return 0
