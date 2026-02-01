class_name Club

var day: int = 0
var money: int
var capacity: int
var reroll_discount: int = 0  # Reduces reroll cost by this amount

func _init(_capacity: int, _money: int):
	self.capacity = _capacity
	self.money = _money


func rent() -> int:
	return int(capacity * 200 * (1.3 ** day))


static func load(data: Dictionary):
	var me = Club.new(data["capacity"], data["money"])
	me.day = data.get("day", 1)  # Default to day 1 for older saves
	me.reroll_discount = data.get("reroll_discount", 0)

	return me


func save():
	var data = Dictionary()
	data["capacity"] = self.capacity
	data["money"] = self.money
	data["day"] = self.day
	data["reroll_discount"] = self.reroll_discount

	return data
