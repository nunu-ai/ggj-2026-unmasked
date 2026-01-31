class_name Day

var day_number: int
var queue: Array[Person] = []
var in_club: Array[Person] = []


func _init(_day_number: int):
	self.day_number = _day_number
	self.fill_queue()


## Calculate profit based on the happiness score of people in the club
func profit() -> float:
	var trait_list: Array[Trait] = []

	for person in in_club:
		trait_list.append_array(person.traits)

	var trait_set = TraitSet.new(trait_list)

	# Base profit from number of guests, modified by their happiness
	var base_profit = in_club.size() * 50
	var happiness_bonus = trait_set.calc_score() * 10
	
	return base_profit + happiness_bonus


## Creates a queue for the day using the PersonGenerator
func fill_queue():
	self.queue = PersonGenerator.generate_queue(day_number)


func current_person() -> Person:
	if queue.is_empty():
		return null

	return queue[0]


## Accept or reject the current person in the queue
## Note: Caller should check club capacity via SaveState.club.capacity before accepting
func decide_current_person(accept: bool):
	if accept:
		in_club.append(current_person())
	queue.remove_at(0)


## Check if club is full (convenience method, uses provided capacity)
func is_club_full(capacity: int) -> bool:
	return in_club.size() >= capacity
