class_name Day

var day_number: int
var in_club: Array[Person] = []
var global_rules: Array[Rule] = []
var bonus_rules: Array[Rule] = []
var theme: DailyTheme

# Current person in the infinite queue (generated on demand)
var _current_person: Person = null


func _init(_day_number: int, _theme: DailyTheme = null):
	self.day_number = _day_number
	self.global_rules = Rule.get_day_rules(_day_number)
	self.bonus_rules = Rule.get_day_bonus_rules(_day_number)
	self.theme = _theme if _theme != null else DailyTheme.pick_random()
	# Generate first person
	_generate_next_person()


## Calculate profit based on people in club minus rule penalties plus bonuses
func profit(club_capacity: int = 0) -> float:
	# Base profit from money each person brings (based on their mask)
	var base_profit: float = 0.0
	for person in in_club:
		base_profit += person.money

	# Calculate penalties from violated global rules
	var penalties: float = 0.0
	for rule in global_rules:
		if rule.is_violated(in_club):
			penalties += rule.get_penalty()

	# Calculate penalties from violated personal rules
	for person in in_club:
		for rule in person.rules:
			if rule.is_violated(in_club):
				penalties += rule.get_penalty()

	# Calculate bonuses from achieved bonus rules
	var bonuses: float = 0.0
	for rule in bonus_rules:
		bonuses += rule.get_bonus(in_club, club_capacity)

	return base_profit + penalties + bonuses  # penalties are negative, bonuses are positive


## Get the current person (infinite queue - always has someone)
func current_person() -> Person:
	return _current_person


## Accept or reject the current person
## Note: Caller should check club capacity via SaveState.club.capacity before accepting
func decide_current_person(accept: bool):
	if accept:
		in_club.append(_current_person)
	# Generate next person (infinite queue)
	_generate_next_person()


## Reroll to get a new person (costs money, handled by caller)
func reroll():
	_generate_next_person()


## Generate the next person in the queue
func _generate_next_person():
	_current_person = PersonGenerator.generate_person(theme)


## Check if club is full (convenience method, uses provided capacity)
func is_club_full(capacity: int) -> bool:
	return in_club.size() >= capacity
