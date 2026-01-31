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
