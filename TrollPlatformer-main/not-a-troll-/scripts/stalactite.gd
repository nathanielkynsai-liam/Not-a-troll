extends Area2D
class_name Stalactite

## Hazard: Stalactite / Falling Rock that drops when player walks beneath
signal triggered_fall
signal destroyed

@export_group("Falling Settings")
@export var trigger_distance: float = 280.0
@export var fall_gravity: float = 1200.0
@export var shake_duration: float = 0.2
@export var shake_intensity: float = 3.0

enum State { IDLE, SHAKING, FALLING, SHATTERED }
var current_state: State = State.IDLE
var current_fall_speed: float = 0.0

@onready var visual: Node2D = get_node_or_null("Visual")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var detector: RayCast2D = get_node_or_null("RayCast2D")


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	# Set up default detector raycast if none attached
	if not detector:
		detector = RayCast2D.new()
		detector.target_position = Vector2(0, trigger_distance)
		detector.enabled = true
		detector.collide_with_areas = false
		detector.collide_with_bodies = true
		add_child(detector)


func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			if detector and detector.is_colliding():
				var collider = detector.get_collider()
				if collider and (collider.is_in_group("player") or collider.has_method("die")):
					trigger_drop()

		State.FALLING:
			current_fall_speed += fall_gravity * delta
			position.y += current_fall_speed * delta


func trigger_drop() -> void:
	if current_state != State.IDLE:
		return

	current_state = State.SHAKING
	triggered_fall.emit()

	# Warning vibration
	var orig_x = position.x
	var tween = create_tween()
	for i in range(4):
		var offset = randf_range(-shake_intensity, shake_intensity)
		tween.tween_property(self, "position:x", orig_x + offset, shake_duration / 4.0)
	tween.tween_property(self, "position:x", orig_x, 0.02)

	await tween.finished
	current_state = State.FALLING


func _on_body_entered(body: Node2D) -> void:
	if current_state != State.FALLING:
		return

	if body.has_method("die"):
		body.die("Crushed by a falling stalactite!")
		_shatter()
	elif not body is Area2D:
		# Hit floor or solid obstacle
		_shatter()


func _shatter() -> void:
	current_state = State.SHATTERED
	destroyed.emit()

	# Break / crumble animation
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.2, 0.2), 0.1)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	await tween.finished
	queue_free()

