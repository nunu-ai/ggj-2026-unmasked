## TextureRect that scales to fit parent height, keeps aspect ratio,
## aligns bottom-left, and lets the parent clip the overflow.
@tool
extends TextureRect


func _ready() -> void:
	get_parent().resized.connect(_resize)

 
func _process(_delta: float) -> void:
	_resize()


func _resize() -> void:
	if texture == null:
		return

	var tex_size: Vector2 = texture.get_size()
	if tex_size.y == 0.0 or tex_size.x == 0.0:
		return

	var parent_size: Vector2 = get_parent().size
	if parent_size.y == 0.0:
		return

	var aspect: float = tex_size.x / tex_size.y
	var target_height: float = parent_size.y*1.3
	var target_width: float = target_height * aspect

	# Bottom-left aligned, nudged down slightly
	var y_offset: float = parent_size.y * 0.15
	set_position(Vector2(0.0, parent_size.y - target_height + y_offset))
	set_size(Vector2(target_width, target_height))
