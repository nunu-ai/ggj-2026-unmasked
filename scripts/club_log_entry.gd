extends PanelContainer

## A single row in the club log showing a person's mask portrait, name, and info.

@onready var _portrait: Control = $HBoxContainer/Portrait
@onready var _name_label: Label = $HBoxContainer/InfoContainer/MarginContainer/VBoxContainer/NameLabel
@onready var _info_label: Label = $HBoxContainer/InfoContainer/MarginContainer/VBoxContainer/InfoLabel


## Populate this entry with a Person's data
func setup(person: Person) -> void:
	_name_label.text = person.name

	# Build info line from mask
	var parts: Array[String] = []
	if person.mask != null:
		parts.append("%s Mask" % person.mask.tier_name())
		parts.append(person.mask.mood_name())
		if person.mask.star_count > 0:
			parts.append("%d Star%s" % [person.mask.star_count, "s" if person.mask.star_count > 1 else ""])
		parts.append("$%d" % person.mask.money())
	_info_label.text = " | ".join(parts)

	# Apply mask visuals to the portrait
	if person.mask != null:
		_apply_mask_to_portrait(person.mask)


func _apply_mask_to_portrait(mask: Mask) -> void:
	var mask_layer: TextureRect = _portrait.get_node("MaskLayer")
	var mouth_layer: TextureRect = _portrait.get_node("MouthLayer")
	var upper_deco_layer: TextureRect = _portrait.get_node("UpperDecoLayer")
	var lower_deco_layer: TextureRect = _portrait.get_node("LowerDecoLayer")

	mask_layer.texture = load(mask.mask_path)
	mask_layer.modulate = mask.color

	mouth_layer.texture = load(mask.mouth_path)

	if mask.upper_deco_path != "":
		upper_deco_layer.texture = load(mask.upper_deco_path)
		upper_deco_layer.modulate = mask.upper_deco_color
	else:
		upper_deco_layer.texture = null

	if mask.lower_deco_path != "":
		lower_deco_layer.texture = load(mask.lower_deco_path)
		lower_deco_layer.modulate = mask.lower_deco_color
	else:
		lower_deco_layer.texture = null
