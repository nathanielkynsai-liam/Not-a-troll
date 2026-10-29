extends StaticBody2D
class_name CrumbBlock

## Hazard / Platform: Crumb Block that breaks and crumbles under player's weight
signal crumbling
signal crumbled
signal respawned

@export_group("Crumble Parameters")
@export var crumble_delay: float = 0.35
@export var shake_intensity: float = 2.5
@export var respawns: bool = false
@export var respawn_time: float = 3.0

var is_triggered: bool = false

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var trigger_area: Area2D = get_node_or_null("TriggerArea")
@onready var visual: Node2D = get_node_or_null("Visual")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")


func _ready() -> void:
	if trigger_area:
		trigger_area.body_entered.connect(_on_trigger_body_entered)


func _on_trigger_body_entered(body: Node2D) -> void:
	if is_triggered:
		return

	if not body.is_in_group("player") and not body.has_method("die"):
		return

	# Only trigger when player is landing or standing on top
	if "velocity" in body and body.velocity.y < 0:
		return

	is_triggered = true
	_crumble_sequence()


func _crumble_sequence() -> void:
	crumbling.emit()

	# Visual change to cracked block if animated sprite exists
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("cracked"):
		animated_sprite.play("cracked")

	# Shake warning
	var orig_pos = position
	var tween = create_tween()
	var shake_steps = int(crumble_delay / 0.05)
	for i in range(shake_steps):
		var offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-1.0, 1.0))
		tween.tween_property(self, "position", orig_pos + offset, 0.05)
	tween.tween_property(self, "position", orig_pos, 0.02)

	await tween.finished

	# Disable collision and crumble down
	crumbled.emit()
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	var drop_tween = create_tween().set_parallel(true)
	drop_tween.tween_property(self, "position:y", position.y + 20.0, 0.25)
	drop_tween.tween_property(self, "modulate:a", 0.0, 0.25)
	await drop_tween.finished

	hide()

	if respawns:
		await get_tree().create_timer(respawn_time).timeout
		_respawn(orig_pos)


func _respawn(orig_pos: Vector2) -> void:
	position = orig_pos
	modulate.a = 1.0
	show()
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("default"):
		animated_sprite.play("default")
	is_triggered = false
	respawned.emit()

