extends Area2D
class_name CrumblingDoor

## Troll Trap: You reach the exit, but it crumbles into pieces before you can enter!
signal crumbled

@export var trigger_delay: float = 0.25
@export var shake_intensity: float = 4.0
@export var crumble_time: float = 0.4

var has_crumbled: bool = false

@onready var visual: Node2D = get_node_or_null("Visual")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if has_crumbled:
		return

	if not body.is_in_group("player") and not body.has_method("die"):
		return

	has_crumbled = true
	await _start_crumble_sequence()


func _start_crumble_sequence() -> void:
	# 1. Switch to cracked/crumbling visual if animated sprite is set
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("crumbling"):
		animated_sprite.play("crumbling")

	# 2. Violent shaking effect right in front of player
	var orig_pos = position
	var tween = create_tween()
	for i in range(6):
		var offset_x = randf_range(-shake_intensity, shake_intensity)
		var offset_y = randf_range(-shake_intensity * 0.5, shake_intensity * 0.5)
		tween.tween_property(self, "position", orig_pos + Vector2(offset_x, offset_y), 0.04)
	tween.tween_property(self, "position", orig_pos, 0.04)

	await tween.finished
	await get_tree().create_timer(trigger_delay).timeout

	# 3. Collapse & vanish
	crumbled.emit()
	var fade_tween = create_tween().set_parallel(true)
	fade_tween.tween_property(self, "modulate:a", 0.0, crumble_time)
	fade_tween.tween_property(self, "position:y", position.y + 15.0, crumble_time)

	await fade_tween.finished
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	hide()

