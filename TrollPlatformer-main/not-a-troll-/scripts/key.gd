extends Area2D
class_name CollectibleKey

## Key item needed to unlock doors
signal collected

@export_group("Troll Behaviors")
@export var is_troll_key: bool = false
@export var flee_distance: float = 70.0
@export var flee_speed: float = 240.0

var is_collected: bool = false
var original_y: float = 0.0

@onready var visual: Node2D = get_node_or_null("Visual")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	original_y = position.y
	_start_bob_animation()


func _start_bob_animation() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", original_y - 4.0, 0.7).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", original_y + 4.0, 0.7).set_trans(Tween.TRANS_SINE)


func _physics_process(delta: float) -> void:
	# Troll Key: If player gets close, flee away!
	if is_troll_key and not is_collected:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var player = players[0]
			var dist = global_position.distance_to(player.global_position)
			if dist < flee_distance:
				var away_dir = (global_position - player.global_position).normalized()
				# Move away horizontally
				global_position.x += away_dir.x * flee_speed * delta


func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return

	if body.is_in_group("player") or body.has_method("collect_key"):
		is_collected = true
		collected.emit()
		if body.has_method("collect_key"):
			body.collect_key()

		# Pickup sparkle/pop effect
		var tween = create_tween().set_parallel(true)
		tween.tween_property(self, "scale", scale * 1.5, 0.15)
		tween.tween_property(self, "modulate:a", 0.0, 0.15)
		await tween.finished
		queue_free()

