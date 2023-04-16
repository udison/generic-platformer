extends CharacterBody2D
class_name Player


# Movement
@export var max_speed: float = 8 * 16
@export var acceleration: float = 30.0
@export var deceleration: float = 30.0

# Jump
@export var max_jump_height: float = 6 * 16
@export var min_jump_height: float = 2 * 16
@export var double_jump_height: float = 4 * 16
@export var jump_duration: float = .6
@export var max_jumps: int = 2

# Private properties
var gravity: float
var max_jump_velocity: float
var min_jump_velocity: float
var double_jump_velocity: float
var is_jumping: bool = false
var jump_counter: int = 0
var can_jump: bool = false

# Nodes
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer


func _ready():
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	double_jump_velocity = -sqrt(2 * gravity * double_jump_height)


func _physics_process(delta):
	apply_gravity(delta)
	handle_jump(delta)
	handle_movement()
	move_and_slide()
	print(jump_counter)


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		
		# If ascending, applies default gravity
		if velocity.y < 0:
			velocity.y += gravity * delta
		
		# If decending, applies stronger gravity
		else:
			velocity.y += gravity * 1.4 * delta


func handle_jump(delta: float) -> void:
	#can_jump = (jump_counter < max_jumps)
	
	if is_on_floor():
		landed()
	
	# Start jump
	if Input.is_action_just_pressed("jump") and jump_counter < max_jumps:
		velocity.y = max_jump_velocity if jump_counter == 0 else double_jump_velocity
		jump_counter += 2 if jump_counter == 0 and !is_on_floor() else 1
		is_jumping = true
	
	# Stop jump when release jump action
	if Input.is_action_just_released("jump") and velocity.y < min_jump_velocity:
		velocity.y = min_jump_velocity


func landed():
	is_jumping = false
	can_jump = true
	jump_counter = 0


func handle_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x += direction * acceleration
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
