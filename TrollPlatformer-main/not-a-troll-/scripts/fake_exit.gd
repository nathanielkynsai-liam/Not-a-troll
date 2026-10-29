
extends Area2D

var triggered = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return

	if not body.has_method("die"):
		return

	triggered = true

	# The exit looks suspicious after the player touches it.
	$Visual.color = Color.RED

	# A short pause makes the trap more surprising.
	await get_tree().create_timer(0.6).timeout

	body.die()
