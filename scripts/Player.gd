extends CharacterBody2D

@onready var jump_bar = $ProgressBar
@onready var cast_left = $RayCastLeft
@onready var cast_right = $RayCastRight
@export var move_speed := 200.0
@export var jump_force := 400.0
@export var gravity := 1300.0
@export var acceleration := 10.0
@export var friction := 5.0
@export var number_of_jumps := 2
var original_collision_mask: int
var jumps_left = number_of_jumps
var was_on_floor = false
var velocity_locked = false
var is_near_wall = false

func _ready() -> void:
	original_collision_mask = collision_mask
	jump_bar.value = 100 / number_of_jumps

func _physics_process(delta: float) -> void:
	is_near_wall = cast_left.is_colliding() or cast_right.is_colliding()
	was_on_floor = is_on_floor()
	_handle_movement(delta)
	_handle_jump()
	_apply_gravity(delta)
	move_and_slide()
	
	# Reset jumps when player lands
	if not was_on_floor and is_on_floor():
		jumps_left = number_of_jumps
		

func _handle_movement(delta: float) -> void:
	if velocity_locked:
		return
	var input_dir := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if input_dir != 0:
		self.velocity.x = lerp(self.velocity.x, input_dir * move_speed, acceleration * delta)
	else:
		self.velocity.x = lerp(self.velocity.x, 0.0, friction * delta)

func _handle_jump() -> void:
	if Input.is_action_pressed("move_down"):
		collision_mask = 0
		await get_tree().create_timer(0.1).timeout
		collision_mask = original_collision_mask
	elif Input.is_action_just_pressed('jump') and jumps_left > 0 and is_near_wall:
		self.velocity.y = -jump_force
		self.velocity.x = get_wall_normal().x * move_speed * 2
		jumps_left = number_of_jumps - 1
		velocity_locked = true
		await get_tree().create_timer(0.5).timeout
		velocity_locked = false
	elif Input.is_action_just_pressed("jump") and jumps_left > 0:
		self.velocity.y = -jump_force
		jumps_left -= 1
		
	jump_bar.value = jumps_left* 100 / number_of_jumps

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		self.velocity.y += gravity * delta
