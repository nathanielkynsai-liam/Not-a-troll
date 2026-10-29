
extends Node2D

var activated = false


func _ready() -> void:
	# Hide the spikes and disable their damage collision.
	$Visual.hide()
	$Hazard/CollisionShape2D.set_deferred("disabled", true)

	$Trigger.body_entered.connect(_on_trigger_body_entered)
	$Hazard.body_entered.connect(_on_hazard_body_entered)


func _on_trigger_body_entered(body: Node2D) -> void:
	if activated:
		return

	if not body is CharacterBody2D:
		return

	activated = true

	# Give the player a brief chance to react.
	await get_tree().create_timer(0.2).timeout

	if not is_inside_tree():
		return

	# The trap is now visible and dangerous.
	$Visual.show()
	$Hazard/CollisionShape2D.set_deferred("disabled", false)


func _on_hazard_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
