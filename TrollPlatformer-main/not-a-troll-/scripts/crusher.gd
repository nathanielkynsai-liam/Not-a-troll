extends Node2D
class_name Crusher

## Hazard: Spiked ceiling crusher that slams down when player walks underneath
signal slammed
signal retracted

enum State { IDLE, SLAMMING, RESTING, RETRACTING }

@export_group("Crusher Mechanics")
@export var slam_distance: float = 160.0
@export var slam_speed: float = 720.0
@export var retract_speed: float = 120.0
@export var rest_duration: float = 0.5
@export var detection_range: float = 200.0

var current_state: State = State.IDLE
var start_y: float = 0.0
var target_y: float = 0.0

@onready var moving_body: Area2D = get_node_or_null("PistonHead")
@onready var detector: RayCast2D = get_node_or_null("RayCast2D")


func _ready() -> void:
	if moving_body:
		start_y = moving_body.position.y
		target_y = start_y + slam_distance
		moving_body.body_entered.connect(_on_piston_body_entered)

	if not detector:
		detector = RayCast2D.new()
		detector.target_position = Vector2(0, detection_range)
		detector.enabled = true
		detector.collide_with_areas = false
		detector.collide_with_bodies = true
		add_child(detector)


func _physics_process(delta: float) -> void:
	if not moving_body:
		return

	match current_state:
		State.IDLE:
			if detector and detector.is_colliding():
				var col = detector.get_collider()
				if col and (col.is_in_group("player") or col.has_method("die")):
					_start_slam()

		State.SLAMMING:
			moving_body.position.y = move_toward(moving_body.position.y, target_y, slam_speed * delta)
			if abs(moving_body.position.y - target_y) < 1.0:
				_on_slam_impact()

		State.RETRACTING:
			moving_body.position.y = move_toward(moving_body.position.y, start_y, retract_speed * delta)
			if abs(moving_body.position.y - start_y) < 1.0:
				current_state = State.IDLE
				retracted.emit()


func _start_slam() -> void:
	current_state = State.SLAMMING


func _on_slam_impact() -> void:
	current_state = State.RESTING
	slammed.emit()

	# Impact pause
	await get_tree().create_timer(rest_duration).timeout
	current_state = State.RETRACTING


func _on_piston_body_entered(body: Node2D) -> void:
	# Deadly while slamming down
	if current_state == State.SLAMMING:
		if body.has_method("die"):
			body.die("Crushed to a pulp!")

