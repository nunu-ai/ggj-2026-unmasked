class_name Day

var queue: Array[Person] = []
var in_club: Array[Person] = []


func get_score():
	var trait_list: Array[Trait] = []

	for person in in_club:
		trait_list.append_array(person.traits)

	var trait_set = TraitSet.new(trait_list)

	return trait_set.calc_score()


## Creates a queue for the day. Currently placeholder.
func fill_queue():
	self.queue = [
		Person.new("john", [DressCode.new("theme-a")]),
		Person.new("jane", [DressCode.new("theme-b")]),
	]


func current_person():
	if queue.is_empty():
		return null

	return queue[0]


func decide_current_person(accept: bool):
	if accept:
		in_club.append(current_person())
		queue.remove_at(0)
	else:
		queue.remove_at(0)
