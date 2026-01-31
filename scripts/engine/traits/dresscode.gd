class_name DressCode
extends Trait

var theme: String


func _init(_theme: String):
	self.theme = _theme


func name():
	return "Dress Code"


func display_value():
	return "Wearing %s" % self.theme


func description():
	return "Dress code"


func tags():
	return ["dresscode"]


func calc_score(trait_set: TraitSet):
	var score = 0
	for t in trait_set.get_traits_by_tag("dresscode"):
		if t is DressCode and t != self:
			if t.theme == self.theme:
				score += 1
			else:
				score -= 10

	return score
