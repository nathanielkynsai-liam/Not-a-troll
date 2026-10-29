extends Node2D

@export var death_boundary_y: float = 520.0
@export var boundary_width: float = 3000.0


func _ready() -> void:
	create_death_boundary()


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
		body.die("Fell into the spike pit!")

