class_name DislikeHobby
extends Trait

var dislike_hobby: String


func _init(_dislike_hobby: String):
	self.dislike_hobby = _dislike_hobby


func name():
	return "Dislike Hobby"


func display_value():
	return "Dislikes %s enthusiasts" % self.dislike_hobby


func description():
	return "Dislikes people with a certain hobby"


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
