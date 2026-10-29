extends Node2D

@export var death_boundary_y: float = 520.0
@export var boundary_width: float = 3000.0

@onready var sliding_spikes: Node2D = get_node_or_null("SlidingSpikes")
@onready var spike_trigger: Area2D = get_node_or_null("SpikeTrigger")
@onready var exit_ledge: Node2D = get_node_or_null("DroppingLedge")
@onready var ledge_trigger: Area2D = get_node_or_null("LedgeTrigger")
@onready var ledge_collision: CollisionShape2D = get_node_or_null("DroppingLedge/CollisionShape2D")

var spikes_slid: bool = false
var ledge_dropped: bool = false


func _ready() -> void:
	create_death_boundary()
	if spike_trigger:
		spike_trigger.body_entered.connect(_on_spike_trigger_entered)
	if ledge_trigger:
		ledge_trigger.body_entered.connect(_on_ledge_trigger_entered)


func _on_spike_trigger_entered(body: Node2D) -> void:
	if spikes_slid or not body.is_in_group("player"):
		return

	spikes_slid = true

	# Spikes slide left toward player!
	if sliding_spikes:
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(sliding_spikes, "position:x", sliding_spikes.position.x - 220.0, 0.8)


func _on_ledge_trigger_entered(body: Node2D) -> void:
	if ledge_dropped or not body.is_in_group("player"):
		return

	ledge_dropped = true

	# Dropping final ledge
	await get_tree().create_timer(0.2).timeout
	if exit_ledge:
		var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(exit_ledge, "position:y", exit_ledge.position.y + 400.0, 0.5)
		await get_tree().create_timer(0.1).timeout
		if ledge_collision:
			ledge_collision.set_deferred("disabled", true)


func create_death_boundary() -> void:
	var boundary = Area2D.new()
	boundary.name = "DeathBoundary"
	boundary.position = Vector2(0, death_boundary_y)
	boundary.collision_layer = 0
	boundary.collision_mask = 1
	boundary.monitoring = true

	var collision = CollisionShape2D.new()
	var rectangle = RectangleShape2D.new()
	rectangle.size = Vector2(boundary_width, 60)
	collision.shape = rectangle
	boundary.add_child(collision)
	add_child(boundary)

	boundary.body_entered.connect(_on_death_boundary_entered)


func _on_death_boundary_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die("Fell into the abyss!")

