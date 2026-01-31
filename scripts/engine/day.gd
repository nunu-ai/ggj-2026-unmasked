class_name Day

var day_number: int

var queue: Array[Person] = []
var in_club: Array[Person] = []


func _init(_day_number: int):
	self.day_number = _day_number

	self.fill_queue()


func profit():
	var trait_list: Array[Trait] = []

	for person in in_club:
		trait_list.append_array(person.traits)

	var trait_set = TraitSet.new(trait_list)

	return trait_set.calc_score()


## Creates a queue for the day. Currently placeholder.
func fill_queue():
	if self.day_number == 1:
		self.queue = [
			Person.new("John", [DressCode.new("black")]),
			Person.new("Jane", [DressCode.new("white")]),
		]
	else:
		for i in range(day_number * 10):
			self.queue.append(Person.new("Person " + str(i), [DressCode.new("theme-" + str(i % 3))]))


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
