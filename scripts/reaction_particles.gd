class_name ReactionParticles
extends GPUParticles2D

@export var happy_texture: Texture
@export var neutral_texture: Texture
@export var negative_texture: Texture

var _emission_id: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emitting = false

func _emit_with_texture(selected_texture: Texture) -> void:
	texture = selected_texture
	# Increment emission ID to invalidate any previous timer
	_emission_id += 1
	var current_emission_id = _emission_id

	# Start emitting particles
	emitting = true

	# Wait for 1 second
	await get_tree().create_timer(0.6).timeout

	# Only stop emitting if no new emission was triggered
	if current_emission_id == _emission_id:
		emitting = false


func react_happily() -> void:
	var selected_texture = happy_texture
	_emit_with_texture(selected_texture)


func react_neutrally() -> void:
	var selected_texture = happy_texture
	_emit_with_texture(selected_texture)


func react_negatively() -> void:
	var selected_texture = happy_texture
	_emit_with_texture(selected_texture)
