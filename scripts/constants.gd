class_name Constants
extends RefCounted

# =============================================================================
# MASK CONSTANTS - All possible values for masks
# =============================================================================

# Mask colors determine money value (see Mask.get_money_value())
const MASK_COLORS = ["gold", "silver", "blue", "grey", "red", "green"]

# Mask decorations (visual only)
const MASK_DECORATIONS = ["none", "deco1"]

# =============================================================================
# NAME POOLS - For person generation
# =============================================================================

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
# GAME CONSTANTS
# =============================================================================

# Cost to reroll and get a new person in the queue
const REROLL_COST = 20
