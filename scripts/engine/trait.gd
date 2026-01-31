class_name Trait

func name():
	return "Base Trait"


## Returns the display value of this trait (e.g., "Male" instead of "Gender")
## Override in subclasses that have specific values
func display_value():
	return description()


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


## Returns detailed breakdown of score with reasons and who triggered it
## Each entry: { "reason": String, "score": int, "triggered_by": Person or null }
func explain_score(_trait_set: TraitSet, _all_people: Array[Person]) -> Array[Dictionary]:
	return []


## Helper to find which person owns a specific trait
func _find_trait_owner(target_trait: Trait, all_people: Array[Person]) -> Person:
	for person in all_people:
		if target_trait in person.traits:
			return person
	return null
