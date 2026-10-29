extends Area2D
class_name SpringLauncher

## Hazard / Gizmo: Spring / Launcher that propels the player into hazards or traps!
signal launched(body: Node2D)

@export_group("Launch Settings")
@export var launch_force: float = 750.0
@export var launch_direction: Vector2 = Vector2.UP
@export var is_troll_spring: bool = false # Troll option: spring breaks or launches sideways into spikes!
@export var troll_horizontal_multiplier: float = 1.0

var is_animating: bool = false

@onready var visual: Node2D = get_node_or_null("Visual")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if is_animating:
		return

	if not body.is_in_group("player") and not body.has_method("bounce"):
		return

	_launch_body(body)


func _launch_body(body: Node2D) -> void:
	is_animating = true
	launched.emit(body)

	# Calculate launch vector
	var launch_vector = launch_direction.normalized() * launch_force
	if is_troll_spring:
		# Add unexpected sideways momentum
		launch_vector.x += (200.0 * troll_horizontal_multiplier)

	if body.has_method("launch"):
		body.launch(launch_vector)
	elif body.has_method("bounce"):
		body.bounce(launch_force)

	# Visual uncoil & bounce animation
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("launch"):
		animated_sprite.play("launch")
		await animated_sprite.animation_finished
		if animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")
	else:
		# Squash and stretch tween
		var orig_scale = scale
		var tween = create_tween()
		# Compress down
		tween.tween_property(self, "scale", Vector2(orig_scale.x * 1.3, orig_scale.y * 0.5), 0.06)
		# Spring up high
		tween.tween_property(self, "scale", Vector2(orig_scale.x * 0.7, orig_scale.y * 1.4), 0.1)
		# Return to normal
		tween.tween_property(self, "scale", orig_scale, 0.15)
		await tween.finished

	is_animating = false

