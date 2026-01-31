class_name DislikeProfession
extends Trait

var dislike_profession: String


func _init(_dislike_profession: String):
	self.dislike_profession = _dislike_profession


func name():
	return "Dislike Profession"


func display_value():
	return "Dislikes %ss" % self.dislike_profession


func description():
	return "dislike Profession"


func tags():
	return []


func calc_score(trait_set: TraitSet):
	for t in trait_set.get_traits_by_tag("profession"):
		if t is Profession and t != self:
			print("Dislike Profession: ", self.dislike_profession, " == ", t.kind)
			if self.dislike_profession == t.kind:
				return -10

	return 0
