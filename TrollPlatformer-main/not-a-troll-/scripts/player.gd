extends CharacterBody2D
class_name Player

## Signals
signal died(reason: String)
signal level_completed
signal state_changed(old_state: State, new_state: State)
signal key_collected

## State Machine
enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	HURT,
	DEFEATED,
	VICTORY
}

var current_state: State = State.IDLE

## Movement Parameters
@export_group("Movement")
@export var speed: float = 260.0
@export var acceleration: float = 1400.0
@export var friction: float = 1200.0

@export_group("Jumping")
@export var jump_velocity: float = -420.0
@export var variable_jump_multiplier: float = 0.5  # Cutting jump early
@export var coyote_time_duration: float = 0.12     # Forgiving jump off ledge
@export var jump_buffer_duration: float = 0.15     # Queue jump before landing

@export_group("Troll Settings")
@export var controls_inverted: bool = false
@export var input_locked: bool = false

## Inventory / State
var has_key: bool = false
var is_dead: bool = false
var has_won: bool = false

## Timers & Internal State
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var gravity: float = 980.0

# Visual node references (handles AnimatedSprite2D, Sprite2D, or Polygon2D)
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var polygon: Polygon2D = get_node_or_null("Polygon2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")


func _ready() -> void:
	add_to_group("player")
	var default_grav = ProjectSettings.get_setting("physics/2d/default_gravity")
	if default_grav != null:
		gravity = float(default_grav)


func _physics_process(delta: float) -> void:
	# Ignore standard input processing if defeated or in victory sequence
	if current_state == State.DEFEATED or current_state == State.VICTORY or is_dead or has_won:
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return

	_handle_timers(delta)
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement(delta)
	move_and_slide()
	_update_state()
	_update_visuals()


func _handle_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time_duration
	else:
		coyote_timer = max(0.0, coyote_timer - delta)

	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func _handle_jump() -> void:
	if input_locked:
		return

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_duration

	# Execute jump if buffered and on floor/coyote
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		_change_state(State.JUMP)

	# Variable jump height: release jump button early to cut ascent
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= variable_jump_multiplier


func _handle_movement(delta: float) -> void:
	if input_locked:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		return

	var direction := Input.get_axis("move_left", "move_right")
	if controls_inverted:
		direction = -direction

	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		# Face direction
		_flip_sprite(direction < 0.0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)


func _update_state() -> void:
	if current_state == State.HURT or current_state == State.DEFEATED or current_state == State.VICTORY:
		return

	if not is_on_floor():
		if velocity.y < 0:
			_change_state(State.JUMP)
		else:
			_change_state(State.FALL)
	else:
		if abs(velocity.x) > 10.0:
			_change_state(State.RUN)
		else:
			_change_state(State.IDLE)


func _change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	var old_state = current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)


func _update_visuals() -> void:
	var anim_name := _get_state_anim_name(current_state)

	if animated_sprite and animated_sprite.sprite_frames:
		if animated_sprite.sprite_frames.has_animation(anim_name):
			if animated_sprite.animation != anim_name:
				animated_sprite.play(anim_name)
	elif sprite:
		# If using a single texture or shader
		pass


func _get_state_anim_name(state: State) -> String:
	match state:
		State.IDLE: return "idle"
		State.RUN: return "run"
		State.JUMP: return "jump"
		State.FALL: return "fall"
		State.HURT: return "hurt"
		State.DEFEATED: return "defeated"
		State.VICTORY: return "victory"
		_: return "idle"


func _flip_sprite(facing_left: bool) -> void:
	if animated_sprite:
		animated_sprite.flip_h = facing_left
	elif sprite:
		sprite.flip_h = facing_left
	elif polygon:
		polygon.scale.x = -abs(polygon.scale.x) if facing_left else abs(polygon.scale.x)


## External Troll Interaction: Spring Launch
func bounce(force: float = 650.0) -> void:
	velocity.y = -abs(force)
	_change_state(State.JUMP)


func launch(launch_vec: Vector2) -> void:
	velocity = launch_vec
	if launch_vec.y < 0:
		_change_state(State.JUMP)


## External Interaction: Key Collection
func collect_key() -> void:
	has_key = true
	key_collected.emit()
	print("Player collected key!")


## Hurt logic
func take_hit(knockback: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
	_change_state(State.HURT)
	_update_visuals()
	if knockback != Vector2.ZERO:
		velocity = knockback


## Death logic (Instant Troll Death)
func die(reason: String = "") -> void:
	if is_dead:
		return

	is_dead = true
	input_locked = true
	velocity = Vector2.ZERO
	_change_state(State.DEFEATED)
	_update_visuals()
	died.emit(reason)

	# Death flop / defeated rotation if no AnimatedSprite
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("defeated"):
		animated_sprite.play("defeated")
	else:
		rotation_degrees = 90.0 # Lie flat on ground

	await get_tree().create_timer(0.6).timeout

	# Pass the current level path so GameOver knows which scene to retry
	var game_over_script = load("res://scripts/game_over.gd")
	if game_over_script and get_tree().current_scene:
		game_over_script.last_level_path = get_tree().current_scene.scene_file_path

	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")


## Victory logic (Reaching True Goal)
func win_level() -> void:
	if is_dead or has_won:
		return

	has_won = true
	input_locked = true
	velocity = Vector2.ZERO
	_change_state(State.VICTORY)
	_update_visuals()
	level_completed.emit()

	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("victory"):
		animated_sprite.play("victory")

	print("LEVEL WON! Victory dance!")
