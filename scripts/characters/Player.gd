extends CharacterBody2D
class_name Player


# Movement
@export var max_speed: float = 8 * 16
@export var acceleration: float = 30.0
@export var deceleration: float = 30.0

var facing_right: bool = true

# Jump
@export var max_jump_height: float = 6 * 16
@export var min_jump_height: float = 2 * 16
@export var double_jump_height: float = 4 * 16
@export var jump_duration: float = .6
@export var max_jumps: int = 2

var gravity: float
var max_jump_velocity: float
var min_jump_velocity: float
var double_jump_velocity: float
var jump_counter: int = 0
var was_on_floor: bool = true
var is_jumping: bool = false

# Nodes
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var sprite: Sprite2D = $Sprite


func _ready():
	# weird maths, dont touch these, works just fine
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	double_jump_velocity = -sqrt(2 * gravity * double_jump_height)


func _physics_process(delta):
	apply_gravity(delta)
	handle_jump(delta)
	handle_movement()
	handle_animations()
	
	was_on_floor = is_on_floor()
	move_and_slide()
	handle_coyote_time()
	print(jump_counter)


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		
		# If ascending, applies default gravity
		if velocity.y < 0:
			velocity.y += gravity * delta
		
		# If decending, applies stronger gravity
		else:
			velocity.y += gravity * 1.4 * delta


func can_jump() -> bool:
	if max_jumps == 1:
		return jump_counter == 0 and (is_on_floor() or !is_on_floor() and !coyote_timer.is_stopped()) 
	
	return jump_counter < max_jumps


func increase_jump_counter():
	var new_count = 1
	
	if jump_counter == 0 and coyote_timer.is_stopped() and !is_on_floor():
		new_count += 1

	jump_counter += new_count

func handle_jump(delta: float) -> void:
	if is_on_floor():
		landed()
	
	# Start jump
	if Input.is_action_just_pressed("jump") and can_jump():
		increase_jump_counter()
		velocity.y = max_jump_velocity if (jump_counter - 1) == 0 else double_jump_velocity
		is_jumping = true
	
	# Stop jump when release jump action
	if Input.is_action_just_released("jump") and velocity.y < min_jump_velocity:
		velocity.y = min_jump_velocity


func landed() -> void:
	is_jumping = false
	jump_counter = 0
	coyote_timer.stop()


func handle_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x += direction * acceleration
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
	
	if velocity.x > 0:
		facing_right = true
	elif velocity.x < 0:
		facing_right = false


func handle_animations() -> void:
	sprite.flip_h = !facing_right
	
	# placeholder, animations gonna be handled by state machines
	if velocity.x == 0:
		anim_player.play("idle")
	elif velocity.x != 0:
		anim_player.play("walk")


func handle_coyote_time():
	coyote_timer.timeout.connect(func():
		print('timed out!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
	)
	if was_on_floor and !is_on_floor():
		coyote_timer.start()
