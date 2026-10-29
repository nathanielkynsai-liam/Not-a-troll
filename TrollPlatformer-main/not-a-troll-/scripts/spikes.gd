extends Area2D
class_name Spikes

## Hazards: Floor Spikes, Ceiling Spikes, Spike Row
enum Direction { UP, DOWN, LEFT, RIGHT }

@export var direction: Direction = Direction.UP
@export var is_instant_death: bool = true

@onready var visual: Node2D = get_node_or_null("Visual")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_direction()


func _apply_direction() -> void:
	match direction:
		Direction.UP:
			rotation_degrees = 0.0
		Direction.DOWN:
			rotation_degrees = 180.0
		Direction.LEFT:
			rotation_degrees = -90.0
		Direction.RIGHT:
			rotation_degrees = 90.0


func _on_body_entered(body: Node2D) -> void:
	if not body.has_method("die"):
		return

	if is_instant_death:
		body.die("Impaled by spikes!")

