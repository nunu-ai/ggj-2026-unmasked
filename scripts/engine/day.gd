class_name Day

var queue: Array[Person] = []
var in_club: Array[Person] = []

func get_score():
  var trait_list: Array[Trait] = []

  for person in in_club:
    trait_list.append_array(person.traits)

  var trait_set = TraitSet.new(trait_list)

  return trait_set.calc_score()
