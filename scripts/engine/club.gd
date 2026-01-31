class_name Club

var day: int = 1
var money: int
var capacity: int

func _init(_capacity: int, _money: int):
	self.capacity = _capacity
	self.money = _money


func rent() -> int:
	return int(capacity * 200 * (1.3 ** day))


static func load(data: Dictionary):
	var me = Club.new(data["capacity"], data["money"])

	return me


func save():
	var data = Dictionary()
	data["capacity"] = self.capacity
	data["money"] = self.money

	return data
