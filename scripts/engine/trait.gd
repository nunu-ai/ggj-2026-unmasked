class_name Trait

func name():
	return "Base Trait"


## Returns the display value of this trait (e.g., "Male" instead of "Gender")
## Override in subclasses that have specific values
func display_value():
	return name()


func tags():
	return []


func description():
	return "Base trait"


func hidden():
	return false


func calc_score(_trait_set: TraitSet) -> float:
	return 0.0
