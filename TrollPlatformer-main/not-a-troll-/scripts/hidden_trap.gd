extends Node2D
class_name HiddenTrap

## Hazard: Hidden Spikes that pop up out of the floor when triggered
signal sprung

@export_group("Trap Configuration")
@export var trigger_delay: float = 0.15      # Brief pause so player feels the surprise
@export var pop_speed: float = 0.08          # Speed spikes thrust up
@export var spikes_height: float = 24.0      # Pixel distance spikes extend
@export var auto_retract: bool = false
@export var retract_delay: float = 2.0

var activated: bool = false
var original_spike_y: float = 0.0

@onready var visual: Node2D = get_node_or_null("Visual")
@onready var hazard_area: Area2D = get_node_or_null("Hazard")
@onready var hazard_shape: CollisionShape2D = get_node_or_null("Hazard/CollisionShape2D")
@onready var trigger_area: Area2D = get_node_or_null("Trigger")


func _ready() -> void:
	if visual:
		original_spike_y = visual.position.y
		visual.position.y += spikes_height
		visual.visible = false

	if hazard_shape:
		hazard_shape.set_deferred("disabled", true)

	if trigger_area:
		trigger_area.body_entered.connect(_on_trigger_entered)

	if hazard_area:
		hazard_area.body_entered.connect(_on_hazard_entered)


func _on_trigger_entered(body: Node2D) -> void:
	if activated:
		return

	if not body.is_in_group("player") and not body.has_method("die"):
		return

	activated = true

	# Wait surprise moment
	await get_tree().create_timer(trigger_delay).timeout
	_spring_trap()


func _spring_trap() -> void:
	sprung.emit()

	if visual:
		visual.visible = true
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(visual, "position:y", original_spike_y, pop_speed)

	if hazard_shape:
		hazard_shape.set_deferred("disabled", false)

	if auto_retract:
		await get_tree().create_timer(retract_delay).timeout
		_retract_trap()


func _retract_trap() -> void:
	if hazard_shape:
		hazard_shape.set_deferred("disabled", true)

	if visual:
		var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tween.tween_property(visual, "position:y", original_spike_y + spikes_height, 0.3)
		await tween.finished
		visual.visible = false

	activated = false


func _on_hazard_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die("Impaled by surprise spikes!")

