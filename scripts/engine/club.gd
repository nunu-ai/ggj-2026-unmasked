class_name Club

var day: int = 0
var money: int
var capacity: int
var reroll_discount: int = 0  # Reduces reroll cost by this amount
var tier_luck_bonus: int = 0  # Increases chance of higher tier masks (each point shifts weight toward better tiers)

func _init(_capacity: int, _money: int):
	self.capacity = _capacity
	self.money = _money


func rent() -> int:
	return int(1000 * (1.5 ** day))


static func load(data: Dictionary):
	var me = Club.new(data["capacity"], data["money"])
	me.day = data.get("day", 1)  # Default to day 1 for older saves
	me.reroll_discount = data.get("reroll_discount", 0)
	me.tier_luck_bonus = data.get("tier_luck_bonus", 0)

	return me


func save():
	var data = Dictionary()
	data["capacity"] = self.capacity
	data["money"] = self.money
	data["day"] = self.day
	data["reroll_discount"] = self.reroll_discount
	data["tier_luck_bonus"] = self.tier_luck_bonus

	return data
