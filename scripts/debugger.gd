@tool
extends EditorScript

func _run() -> void:
	var day = Day.new()
	day.in_club.append(Person.new("john", [DressCode.new("theme-a")]))
	day.in_club.append(Person.new("jane", [DressCode.new("theme-b")]))

	print("Score: ", day.get_score())
