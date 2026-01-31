class_name Trait

func name():
	return "Base Trait"


func tags():
	return []


func description():
	return "Base trait"


func hidden():
	return false


## Returns true if this trait can affect happiness (has scoring effects)
func can_affect_happiness() -> bool:
	return false


func calc_score(_trait_set: TraitSet) -> float:
	return 0.0
