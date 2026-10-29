
extends StaticBody2D

var triggered = false


func _ready() -> void:
	$Trigger.body_entered.connect(_on_trigger_body_entered)


func _on_trigger_body_entered(body: Node2D) -> void:
	if triggered:
		return

	if not body is CharacterBody2D:
		return

	# Only activate when the player is falling onto the platform.
	if body.velocity.y <= 0:
		return

	triggered = true

	# Show a red warning before the platform disappears.
	$Visual.modulate = Color.RED

	await get_tree().create_timer(0.35).timeout

	# Disable the platform collision and hide its sprite.
	$CollisionShape2D.set_deferred("disabled", true)
	$Visual.hide()
	$Trigger/CollisionShape2D.set_deferred("disabled", true)
