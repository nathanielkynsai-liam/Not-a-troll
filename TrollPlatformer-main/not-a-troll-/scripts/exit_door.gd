extends Area2D
class_name ExitDoor

## Signals
signal opened
signal door_entered

@export_group("Door Settings")
@export var requires_key: bool = false
@export_file("*.tscn") var next_scene_path: String = "res://scenes/Level2.tscn"

enum DoorState { CLOSED, OPENING, OPEN, LOCKED }
var current_state: DoorState = DoorState.CLOSED
var is_transitioning: bool = false

@onready var visual: Node2D = get_node_or_null("Visual")
@onready var inner_arch: Polygon2D = get_node_or_null("Visual/InnerArch")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var lock_indicator: Node2D = get_node_or_null("LockIndicator")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if requires_key:
		current_state = DoorState.LOCKED
		if lock_indicator:
			lock_indicator.visible = true
	else:
		current_state = DoorState.CLOSED
	_update_visuals()


func _on_body_entered(body: Node2D) -> void:
	if is_transitioning:
		return

	if not body.is_in_group("player") and not body.has_method("win_level"):
		return

	var player = body

	# Locked door check
	if current_state == DoorState.LOCKED:
		if "has_key" in player and player.has_key:
			await unlock_door()
		else:
			print("Door is locked! Find the key.")
			_shake_door()
			return

	is_transitioning = true

	# Open the door
	if current_state != DoorState.OPEN:
		await open_door()

	# Victory!
	door_entered.emit()
	if player.has_method("win_level"):
		player.win_level()

	# Transition to next level
	await get_tree().create_timer(0.7).timeout

	if next_scene_path != "" and ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("Next scene does not exist: ", next_scene_path)
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func unlock_door() -> void:
	current_state = DoorState.CLOSED
	if lock_indicator:
		lock_indicator.visible = false
	await open_door()


func open_door() -> void:
	current_state = DoorState.OPENING
	opened.emit()

	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("open"):
		animated_sprite.play("open")
		await animated_sprite.animation_finished
	elif inner_arch:
		# Visual door sliding open
		var tween = create_tween()
		tween.tween_property(inner_arch, "color", Color(0.05, 0.05, 0.05, 1), 0.2)
		await tween.finished
	else:
		await get_tree().create_timer(0.2).timeout

	current_state = DoorState.OPEN
	_update_visuals()


func _shake_door() -> void:
	var original_pos = position
	var tween = create_tween()
	tween.tween_property(self, "position:x", original_pos.x + 4.0, 0.05)
	tween.tween_property(self, "position:x", original_pos.x - 4.0, 0.05)
	tween.tween_property(self, "position:x", original_pos.x, 0.05)


func _update_visuals() -> void:
	if animated_sprite and animated_sprite.sprite_frames:
		match current_state:
			DoorState.LOCKED:
				if animated_sprite.sprite_frames.has_animation("locked"):
					animated_sprite.play("locked")
			DoorState.CLOSED:
				if animated_sprite.sprite_frames.has_animation("closed"):
					animated_sprite.play("closed")
			DoorState.OPEN:
				if animated_sprite.sprite_frames.has_animation("open"):
					animated_sprite.play("open")
