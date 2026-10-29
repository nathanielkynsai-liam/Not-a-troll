extends Node2D

@export var death_boundary_y: float = 520.0
@export var boundary_width: float = 3000.0

@onready var exit_door: Node2D = get_node_or_null("ExitDoor")
@onready var door_trigger: Area2D = get_node_or_null("DoorTrigger")
@onready var pit_section: Node2D = get_node_or_null("PitFloor")
@onready var pit_collision: CollisionShape2D = get_node_or_null("PitFloor/CollisionShape2D")

var door_trolled: bool = false


func _ready() -> void:
	create_death_boundary()
	if door_trigger:
		door_trigger.body_entered.connect(_on_door_trigger_entered)


func _on_door_trigger_entered(body: Node2D) -> void:
	if door_trolled or not body.is_in_group("player"):
		return

	door_trolled = true

	# Troll: Exit door slides away and the floor under its original spot falls into a pit!
	if exit_door:
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(exit_door, "position:x", exit_door.position.x + 100.0, 0.3)

	if pit_section:
		var drop_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		drop_tween.tween_property(pit_section, "position:y", pit_section.position.y + 400.0, 0.4)
		await get_tree().create_timer(0.1).timeout
		if pit_collision:
			pit_collision.set_deferred("disabled", true)


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

