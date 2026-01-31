class_name Constants
extends RefCounted

# =============================================================================
# DATA POOLS - All possible values for traits
# =============================================================================

const PROFESSIONS = [
	"Doctor", "Lawyer", "Artist", "Chef", "Teacher", "Musician", 
	"Writer", "Banker", "Engineer", "Actor", "Politician", "Merchant"
]

const NATIONALITIES = [
	"French", "German", "Italian", "British", "Spanish", "Swedish",
	"Dutch", "Austrian", "Russian", "American"
]

const HOBBIES = [
	"Golf", "Chess", "Painting", "Dancing", "Reading", "Hunting",
	"Fencing", "Opera", "Wine Tasting", "Gardening", "Card Games"
]

const SOCIAL_CLASSES = ["lower", "middle", "upper"]

const GENDERS = ["Male", "Female"]

const DRESS_THEMES = ["formal", "casual", "extravagant", "modest"]

# First names by gender
const FIRST_NAMES_MALE = [
	"James", "William", "Charles", "Henry", "Edward", "Frederick",
	"Albert", "Arthur", "George", "Louis", "Victor", "Edmund"
]

const FIRST_NAMES_FEMALE = [
	"Elizabeth", "Margaret", "Catherine", "Victoria", "Charlotte", "Eleanor",
	"Beatrice", "Adelaide", "Josephine", "Isabelle", "Florence", "Harriet"
]

const LAST_NAMES = [
	"Ashworth", "Blackwood", "Crawford", "Davenport", "Everett", "Fairfax",
	"Grantham", "Hartwell", "Irving", "Kensington", "Lancaster", "Montgomery",
	"Pemberton", "Ravencroft", "Sterling", "Thornton", "Whitmore", "York"
]

# =============================================================================
# DAY CONFIGURATION - Controls difficulty progression
# Note: Club capacity is handled by SaveState.Club, not here
# =============================================================================

const DAY_CONFIG = {
	1: {
		"queue_size": 10,
		"hobby_chance": 0.3,             # Chance to have a hobby
		"scoring_trait_chance": 0.15,    # Chance for each scoring trait
		"max_scoring_traits": 1,         # Max traits that affect happiness
	},
	2: {
		"queue_size": 12,
		"hobby_chance": 0.4,
		"scoring_trait_chance": 0.25,
		"max_scoring_traits": 2,
	},
	3: {
		"queue_size": 15,
		"hobby_chance": 0.5,
		"scoring_trait_chance": 0.35,
		"max_scoring_traits": 2,
	},
	4: {
		"queue_size": 18,
		"hobby_chance": 0.5,
		"scoring_trait_chance": 0.45,
		"max_scoring_traits": 3,
	},
	5: {
		"queue_size": 20,
		"hobby_chance": 0.6,
		"scoring_trait_chance": 0.55,
		"max_scoring_traits": 3,
	},
}

# Default config for days beyond what's defined
const DEFAULT_DAY_CONFIG = {
	"queue_size": 25,
	"hobby_chance": 0.6,
	"scoring_trait_chance": 0.6,
	"max_scoring_traits": 4,
}


static func get_day_config(day: int) -> Dictionary:
	if DAY_CONFIG.has(day):
		return DAY_CONFIG[day]
	return DEFAULT_DAY_CONFIG
