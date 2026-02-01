extends Panel

const MASK_DISPLAY_SCENE = preload("res://scenes/mask_display.tscn")
const DECORATIVE_MASK_COUNT = 12
const MASK_SIZE = Vector2(240, 240)
const MASK_SCATTER_SEED = 42069  # Fixed seed for consistent mask placement

@onready var _settings_popup: PopupPanel = $SettingsPopup
@onready var _volume_slider: HSlider = $SettingsPopup/SettingsMargin/SettingsVBox/VolumeHBox/VolumeSlider
@onready var _volume_value_label: Label = $SettingsPopup/SettingsMargin/SettingsVBox/VolumeHBox/VolumeValue
@onready var _mask_decorations: Control = $MaskDecorations


func _ready() -> void:
	# Only show Continue button if there's a save file
	var continue_btn = $VBoxContainer/ContinueButton
	continue_btn.disabled = !SaveState.has_save()
	if continue_btn.disabled:
		continue_btn.modulate = Color(0.4, 0.4, 0.4, 0.5)
	
	# Initialize volume slider from saved settings
	_volume_slider.value = MusicManager.get_volume()
	_update_volume_label(_volume_slider.value)
	
	# Spawn decorative masks around the border
	_spawn_decorative_masks()


func _spawn_decorative_masks() -> void:
	# Use fixed seed for consistent mask placement
	seed(MASK_SCATTER_SEED)
	
	var viewport_size = get_viewport_rect().size
	var margin = 60.0
	var center_exclusion = Rect2(
		viewport_size.x * 0.25,
		viewport_size.y * 0.01,
		viewport_size.x * 0.5,
		viewport_size.y * 0.9
	)
	
	var positions: Array[Vector2] = []
	var attempts = 0
	var max_attempts = 200
	
	while positions.size() < DECORATIVE_MASK_COUNT and attempts < max_attempts:
		attempts += 1
		var pos = _get_border_position(viewport_size, margin)
		
		# Skip if in center exclusion zone (where buttons are)
		if center_exclusion.has_point(pos + MASK_SIZE / 2):
			continue
		
		# Check minimum distance from other masks
		var too_close = false
		for existing_pos in positions:
			if pos.distance_to(existing_pos) < MASK_SIZE.x * 0.8:
				too_close = true
				break
		
		if not too_close:
			positions.append(pos)
	
	# Create mask displays at each position
	for pos in positions:
		var mask_display = MASK_DISPLAY_SCENE.instantiate()
		_mask_decorations.add_child(mask_display)
		
		# Generate a random mask
		var mask = MaskGenerator.generate()
		
		# Position and size the mask
		mask_display.position = pos
		mask_display.size = MASK_SIZE
		mask_display.pivot_offset = MASK_SIZE / 2
		
		# Random rotation for visual interest
		mask_display.rotation = randf_range(-0.4, 0.4)
		
		# Slight random scale variation
		var scale_factor = randf_range(0.8, 1.2)
		mask_display.scale = Vector2(scale_factor, scale_factor)
		
		# Apply mask visuals (without character - just the mask)
		_apply_mask_to_display(mask_display, mask)
		
		# Add slight transparency for decorative effect
		mask_display.modulate.a = randf_range(0.6, 0.9)
	
	# Restore random seed to not affect other game systems
	randomize()


func _get_border_position(viewport_size: Vector2, margin: float) -> Vector2:
	# Randomly pick an edge: 0=top, 1=right, 2=bottom, 3=left
	var edge = randi() % 4
	var pos = Vector2.ZERO
	
	match edge:
		0:  # Top edge
			pos.x = randf_range(margin, viewport_size.x - margin - MASK_SIZE.x)
			pos.y = randf_range(-MASK_SIZE.y * 0.3, margin)
		1:  # Right edge
			pos.x = randf_range(viewport_size.x - margin - MASK_SIZE.x, viewport_size.x - MASK_SIZE.x * 0.5)
			pos.y = randf_range(margin, viewport_size.y - margin - MASK_SIZE.y)
		2:  # Bottom edge
			pos.x = randf_range(margin, viewport_size.x - margin - MASK_SIZE.x)
			pos.y = randf_range(viewport_size.y - margin - MASK_SIZE.y, viewport_size.y - MASK_SIZE.y * 0.5)
		3:  # Left edge
			pos.x = randf_range(-MASK_SIZE.x * 0.3, margin)
			pos.y = randf_range(margin, viewport_size.y - margin - MASK_SIZE.y)
	
	return pos


func _apply_mask_to_display(display: Control, mask: Mask) -> void:
	# Hide character layer (we only want the mask)
	var character_layer = display.get_node_or_null("CharacterLayer")
	if character_layer:
		character_layer.visible = false
	
	# Apply mask base
	var mask_layer = display.get_node_or_null("MaskLayer")
	if mask_layer:
		mask_layer.texture = load(mask.mask_path)
		mask_layer.modulate = mask.color
	
	# Apply mouth
	var mouth_layer = display.get_node_or_null("MouthLayer")
	if mouth_layer:
		if mask.mouth_path != "":
			mouth_layer.texture = load(mask.mouth_path)
			mouth_layer.visible = true
		else:
			mouth_layer.visible = false
	
	# Apply upper deco
	var upper_deco = display.get_node_or_null("UpperDecoLayer")
	if upper_deco:
		if mask.upper_deco_path != "":
			upper_deco.texture = load(mask.upper_deco_path)
			upper_deco.modulate = mask.upper_deco_color
			upper_deco.visible = true
		else:
			upper_deco.visible = false
	
	# Apply lower deco
	var lower_deco = display.get_node_or_null("LowerDecoLayer")
	if lower_deco:
		if mask.lower_deco_path != "":
			lower_deco.texture = load(mask.lower_deco_path)
			lower_deco.modulate = mask.lower_deco_color
			lower_deco.visible = true
		else:
			lower_deco.visible = false


func _on_new_game_button_pressed() -> void:
	MusicManager.play_button_sfx()
	SaveState.new_game()


func _on_continue_button_pressed() -> void:
	MusicManager.play_button_sfx()
	if SaveState.load():
		# Check if player has already lost (money < 0)
		if SaveState.club.money < 0:
			SaveState.delete_save()
			SaveState.switch_to_state(SaveStateClass.State.GameOver)
		else:
			SaveState.switch_to_state(SaveStateClass.State.Manage)


func _on_settings_button_pressed() -> void:
	MusicManager.play_button_sfx()
	_settings_popup.popup_centered()


func _on_settings_close_pressed() -> void:
	MusicManager.play_button_sfx()
	_settings_popup.hide()


func _on_volume_slider_value_changed(value: float) -> void:
	MusicManager.set_volume(value)
	_update_volume_label(value)


func _update_volume_label(volume_db: float) -> void:
	# Convert dB to percentage (0 dB = 100%, -40 dB = 0%)
	var percentage = int(((volume_db + 40.0) / 40.0) * 100.0)
	_volume_value_label.text = "%d%%" % percentage


func _on_exit_button_pressed() -> void:
	MusicManager.play_button_sfx()
	get_tree().quit()
