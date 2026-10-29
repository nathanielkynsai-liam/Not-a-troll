extends StaticBody2D
class_name TrapDoor

## Troll Trap: A floor hatch that swings open when stepped on, dropping the player!
signal opened
signal reset_closed

@export_group("Trapdoor Timers")
@export var fall_delay: float = 0.15     # Time player stands before hatch opens
@export var reset_delay: float = 2.5     # Resets closed after player falls (optional)
@export var auto_reset: bool = true

var is_open: bool = false

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var visual: Node2D = get_node_or_null("Visual")
@onready var trigger_area: Area2D = get_node_or_null("TriggerArea")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")


func _ready() -> void:
	if trigger_area:
		trigger_area.body_entered.connect(_on_trigger_entered)


func _on_trigger_entered(body: Node2D) -> void:
	if is_open:
		return

	if not body.is_in_group("player") and not body.has_method("die"):
		return

	is_open = true

	# Slight warning shake or click
	var orig_pos = position
	var shake_tween = create_tween()
	shake_tween.tween_property(self, "position:y", orig_pos.y + 2.0, fall_delay * 0.5)
	shake_tween.tween_property(self, "position:y", orig_pos.y, fall_delay * 0.5)

	await shake_tween.finished
	await get_tree().create_timer(fall_delay).timeout

	# Open trap door
	_open_trapdoor()


func _open_trapdoor() -> void:
	opened.emit()

	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("open"):
		animated_sprite.play("open")
	else:
		# Rotate visual hatch downwards 90 degrees
		var tween = create_tween()
		tween.tween_property(self, "rotation_degrees", 85.0, 0.1)

	if auto_reset:
		await get_tree().create_timer(reset_delay).timeout
		_close_trapdoor()


func _close_trapdoor() -> void:
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 0.0, 0.2)
	await tween.finished

	if collision_shape:
		collision_shape.set_deferred("disabled", false)

	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("closed"):
		animated_sprite.play("closed")

	is_open = false
	reset_closed.emit()

