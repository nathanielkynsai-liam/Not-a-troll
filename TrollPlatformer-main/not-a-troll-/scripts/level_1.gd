extends Node2D

@export var death_boundary_y: float = 520.0
@export var boundary_width: float = 3000.0

@onready var drop_section: Node2D = get_node_or_null("DropSection")
@onready var drop_trigger: Area2D = get_node_or_null("DropTrigger")
@onready var drop_collision: CollisionShape2D = get_node_or_null("DropSection/CollisionShape2D")

var floor_dropped: bool = false


func _ready() -> void:
	create_death_boundary()
	if drop_trigger:
		drop_trigger.body_entered.connect(_on_drop_trigger_entered)


func _on_drop_trigger_entered(body: Node2D) -> void:
	if floor_dropped or not body.is_in_group("player"):
		return

	floor_dropped = true

	# Middle floor drops away!
	if drop_section:
		var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(drop_section, "position:y", drop_section.position.y + 400.0, 0.5)
		await get_tree().create_timer(0.12).timeout
		if drop_collision:
			drop_collision.set_deferred("disabled", true)


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
		body.die("Fell into the pit!")
