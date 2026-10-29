extends Area2D
class_name FakeDoor

## Troll Trap: Looks like a normal exit door, but opens into a monster that eats you!
signal triggered_trap

@export var eat_delay: float = 0.2
@export var monster_eye_glow: Color = Color.RED

var triggered: bool = false

@onready var visual: Node2D = get_node_or_null("Visual")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return

	if not body.has_method("die"):
		return

	triggered = true
	triggered_trap.emit()

	# Reveal the monster face (red eyes and jagged teeth)
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("monster"):
		animated_sprite.play("monster")
	elif visual:
		visual.modulate = monster_eye_glow

	# Jump scare / sudden slight lunge toward player
	var tween = create_tween()
	var orig_scale = scale
	tween.tween_property(self, "scale", orig_scale * 1.15, 0.08)
	tween.tween_property(self, "scale", orig_scale, 0.08)

	await get_tree().create_timer(eat_delay).timeout

	if is_instance_valid(body) and body.has_method("die"):
		body.die("Devoured by the fake door!")

