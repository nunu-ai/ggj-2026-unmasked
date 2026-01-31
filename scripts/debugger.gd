@tool
extends EditorScript

## Helper to calculate raw trait score (without profit formula)
func calc_raw_score(people: Array[Person]) -> float:
	var trait_list: Array[Trait] = []
	for person in people:
		trait_list.append_array(person.traits)
	var trait_set = TraitSet.new(trait_list)
	return trait_set.calc_score()


## Helper to create a test day without auto-generating queue
func create_test_day() -> Day:
	var day = Day.new(1)
	day.queue.clear()  # Clear auto-generated queue
	day.in_club.clear()
	return day


func _run() -> void:
	print("=== TEST 1: Lawyer hatred ===")
	var day1 = create_test_day()
	day1.in_club.append(Person.new("Jane", [
		Age.new(35),
		Profession.new("Lawyer")
	]))
	day1.in_club.append(Person.new("John", [
		Age.new(40),
		DislikeProfession.new("Lawyer")
	]))
	print("Jane (lawyer) + John (dislikes lawyers)")
	print("Expected raw score: -10 (John dislikes Jane's profession)")
	print("Raw score: ", calc_raw_score(day1.in_club))
	print("Profit: ", day1.profit(), " (2 guests × 50 + score × 10)")
	
	print("\n=== TEST 2: Snob meets lower class ===")
	var day2 = create_test_day()
	day2.in_club.append(Person.new("Rich Richard", [
		Age.new(55),
		SocialClass.new("upper"),
		Snob.new()
	]))
	day2.in_club.append(Person.new("Poor Pete", [
		Age.new(30),
		SocialClass.new("lower")
	]))
	print("Rich Richard (upper class snob) + Poor Pete (lower class)")
	print("Expected raw score: -15 (Snob penalty for lower class)")
	print("Raw score: ", calc_raw_score(day2.in_club))
	print("Profit: ", day2.profit())
	
	print("\n=== TEST 3: Gossips together ===")
	var day3 = create_test_day()
	day3.in_club.append(Person.new("Gabby", [
		Age.new(28),
		Gossip.new()
	]))
	day3.in_club.append(Person.new("Gloria", [
		Age.new(32),
		Gossip.new()
	]))
	print("Gabby (gossip) + Gloria (gossip)")
	print("Expected raw score: +10 (each gossip gets +5 from the other)")
	print("Raw score: ", calc_raw_score(day3.in_club))
	print("Profit: ", day3.profit())
	
	print("\n=== TEST 4: Introvert in growing crowd ===")
	var day4 = create_test_day()
	day4.in_club.append(Person.new("Ian", [
		Age.new(25),
		Introvert.new()
	]))
	day4.in_club.append(Person.new("Person2", [Age.new(30)]))
	print("Ian (introvert) + 1 other person (2 total)")
	print("Expected raw score: +3 (small group bonus)")
	print("Raw score: ", calc_raw_score(day4.in_club))
	print("Profit: ", day4.profit())
	
	day4.in_club.append(Person.new("Person3", [Age.new(35)]))
	day4.in_club.append(Person.new("Person4", [Age.new(40)]))
	day4.in_club.append(Person.new("Person5", [Age.new(45)]))
	day4.in_club.append(Person.new("Person6", [Age.new(50)]))
	print("\nIan (introvert) + 5 others (6 total)")
	print("Expected raw score: -6 (penalty for large group: -(6-4)*3)")
	print("Raw score: ", calc_raw_score(day4.in_club))
	print("Profit: ", day4.profit())
	
	print("\n=== TEST 5: Complex scenario ===")
	var day5 = create_test_day()
	day5.in_club.append(Person.new("Alice", [
		Age.new(25),
		Profession.new("Doctor"),
		SocialClass.new("upper"),
		Nationality.new("French"),
		LikeHobby.new("Gaming")
	]))
	day5.in_club.append(Person.new("Bob", [
		Age.new(60),
		Profession.new("Lawyer"),
		SocialClass.new("middle"),
		Nationality.new("German"),
		Hobby.new("Gaming"),
		PrefersYoung.new(),
		Xenophobe.new("German")
	]))
	day5.in_club.append(Person.new("Carol", [
		Age.new(22),
		Profession.new("Artist"),
		SocialClass.new("lower"),
		Nationality.new("French"),
		DislikeProfession.new("Lawyer"),
		Snob.new()  # Ironic: lower class snob
	]))
	print("Alice (25, doctor, upper, French, likes gaming)")
	print("Bob (60, lawyer, middle, German, gamer, prefers young, xenophobe)")
	print("Carol (22, artist, lower, French, dislikes lawyers, snob)")
	print("Expected contributions:")
	print("  Alice: +5 (likes Bob's gaming hobby)")
	print("  Bob: +5 (prefers young - Carol is 22) + (-10 xenophobe sees Alice from France)")
	print("  Carol: -10 (dislikes Bob the lawyer) + (-15 snob sees self as lower) + (-5 snob sees Bob as middle)")
	print("Raw score: ", calc_raw_score(day5.in_club))
	print("Profit: ", day5.profit())
	
	print("\n=== TEST 6: PersonGenerator ===")
	print("Generating 5 random people for day 1...")
	var generated = PersonGenerator.generate_queue(1)
	for i in range(min(5, generated.size())):
		var p = generated[i]
		print("  ", p.name, ": ", p.traits.size(), " traits")
		for t in p.traits:
			print("    - ", t.name(), ": ", _get_trait_value(t))


## Helper to get displayable value from a trait
func _get_trait_value(t: Trait) -> String:
	if t is Profession:
		return t.kind
	elif t is Nationality:
		return t.country
	elif t is Hobby:
		return t.kind
	elif t is SocialClass:
		return t.tier
	elif t is Age:
		return str(t.age)
	elif t is Gender:
		return t.identity
	elif t is DressCode:
		return t.theme
	elif t is LikeHobby:
		return t.like_hobby
	elif t is DislikeHobby:
		return t.dislike_hobby
	elif t is LikeProfession:
		return t.like_profession
	elif t is DislikeProfession:
		return t.dislike_profession
	elif t is Xenophobe:
		return "own: " + t.own_nationality
	elif t is ClassConscious:
		return "own: " + t.own_class
	elif t is Rival:
		return "hates: " + t.rival_profession
	else:
		return "(no value)"
