class_name LikeHobby
extends Trait

var like_hobby: String


func _init(_like_hobby: String):
	self.like_hobby = _like_hobby


func name():
	return "Like Hobby"


func display_value():
	return "Likes %s enthusiasts" % self.like_hobby


func description():
	return "Enjoys meeting people with a certain hobby"


func tags():
	return []


func calc_score(trait_set: TraitSet):
	for t in trait_set.get_traits_by_tag("hobby"):
		if t is Hobby:
			if self.like_hobby == t.kind:
				return 5

	return 0
