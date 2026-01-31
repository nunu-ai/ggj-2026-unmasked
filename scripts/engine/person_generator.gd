class_name PersonGenerator

# =============================================================================
# PERSON GENERATOR
# Generates random people with traits based on day configuration
# =============================================================================


## Generate a queue of people for a specific day
static func generate_queue(day: int) -> Array[Person]:
	var config = Constants.get_day_config(day)
	var queue: Array[Person] = []
	
	for i in range(config["queue_size"]):
		queue.append(generate_person(config))
	
	return queue


## Generate a single random person based on config
static func generate_person(config: Dictionary) -> Person:
	var traits: Array[Trait] = []
	
	# Always assign base traits
	var gender = _pick_random(Constants.GENDERS)
	var nationality = _pick_random(Constants.NATIONALITIES)
	var profession = _pick_random(Constants.PROFESSIONS)
	var social_class = _pick_random(Constants.SOCIAL_CLASSES)
	var age = _generate_age()
	var dress_theme = _pick_random(Constants.DRESS_THEMES)
	
	traits.append(Gender.new(gender))
	traits.append(Nationality.new(nationality))
	traits.append(Profession.new(profession))
	traits.append(SocialClass.new(social_class))
	traits.append(Age.new(age))
	traits.append(DressCode.new(dress_theme))
	
	# Maybe add a hobby
	if randf() < config["hobby_chance"]:
		var hobby = _pick_random(Constants.HOBBIES)
		traits.append(Hobby.new(hobby))
	
	# Maybe add personality traits (these create interactions)
	var personality_count = 0
	var max_personalities = config["max_personalities"]
	var personality_chance = config["personality_chance"]
	
	# Try to add personality traits based on chance
	var possible_personalities = _get_possible_personalities(nationality, profession, social_class, age)
	possible_personalities.shuffle()
	
	for personality_data in possible_personalities:
		if personality_count >= max_personalities:
			break
		if randf() < personality_chance:
			traits.append(personality_data)
			personality_count += 1
	
	# Generate name based on gender
	var person_name = _generate_name(gender)
	
	return Person.new(person_name, traits)


## Get list of possible personality traits for this person
static func _get_possible_personalities(nationality: String, profession: String, social_class: String, age: int) -> Array[Trait]:
	var personalities: Array[Trait] = []
	
	# Xenophobe - dislikes people from other nationalities
	personalities.append(Xenophobe.new(nationality))
	
	# Class Conscious - cares about social class
	personalities.append(ClassConscious.new(social_class))
	
	# Snob - only likes upper class
	if social_class == "upper":
		personalities.append(Snob.new())
	
	# Introvert / Extrovert
	if randf() > 0.5:
		personalities.append(Introvert.new())
	else:
		personalities.append(Extrovert.new())
	
	# Age preferences
	if age >= 60:
		personalities.append(PrefersElderly.new())
	elif age <= 30:
		personalities.append(PrefersYoung.new())
	
	# Gossip
	personalities.append(Gossip.new())
	
	# Like/Dislike hobbies - pick random hobbies to like/dislike
	var random_hobby = _pick_random(Constants.HOBBIES)
	personalities.append(LikeHobby.new(random_hobby))
	
	var disliked_hobby = _pick_random(Constants.HOBBIES)
	if disliked_hobby != random_hobby:
		personalities.append(DislikeHobby.new(disliked_hobby))
	
	# Like/Dislike professions
	var liked_profession = _pick_random(Constants.PROFESSIONS)
	personalities.append(LikeProfession.new(liked_profession))
	
	var disliked_profession = _pick_random(Constants.PROFESSIONS)
	if disliked_profession != liked_profession:
		personalities.append(DislikeProfession.new(disliked_profession))
	
	# Rival - has a rival profession (someone they personally hate)
	var rival_profession = _pick_random(Constants.PROFESSIONS)
	if rival_profession != profession:
		personalities.append(Rival.new(rival_profession))
	
	return personalities


## Generate a random age (weighted towards middle ages)
static func _generate_age() -> int:
	# Use weighted distribution: more adults, fewer young/elderly
	var roll = randf()
	if roll < 0.2:
		return randi_range(18, 30)   # Young
	elif roll < 0.8:
		return randi_range(31, 55)   # Adult  
	else:
		return randi_range(56, 80)   # Elderly


## Generate a name based on gender
static func _generate_name(gender: String) -> String:
	var first_name: String
	if gender == "Female":
		first_name = _pick_random(Constants.FIRST_NAMES_FEMALE)
	else:
		first_name = _pick_random(Constants.FIRST_NAMES_MALE)
	
	var last_name = _pick_random(Constants.LAST_NAMES)
	return first_name + " " + last_name


## Pick a random element from an array
static func _pick_random(arr: Array) -> Variant:
	return arr[randi() % arr.size()]
