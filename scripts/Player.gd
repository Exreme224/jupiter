extends CharacterBody2D

@export var move_speed := 200.0
@export var jump_force := 400.0
@export var gravity := 1300.0
@export var acceleration := 10.0
@export var friction := 5.0
@export var number_of_jumps := 2
var original_collision_mask: int
var jumps_left = number_of_jumps
var was_on_floor = false

func _ready() -> void:
	original_collision_mask = collision_mask

func _physics_process(delta: float) -> void:
	
	was_on_floor = is_on_floor()
	_handle_movement(delta)
	_handle_jump()
	_apply_gravity(delta)
	move_and_slide()
	
	# Reset jumps when player lands
	if not was_on_floor and is_on_floor():
		jumps_left = number_of_jumps
		

func _handle_movement(delta: float) -> void:
	var input_dir := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	if input_dir != 0:
		self.velocity.x = lerp(self.velocity.x, input_dir * move_speed, acceleration * delta)
	else:
		self.velocity.x = lerp(self.velocity.x, 0.0, friction * delta)

func _handle_jump() -> void:
	if Input.is_action_pressed("move_down") and Input.is_action_pressed('jump'):
		collision_mask = 0
		jumps_left -= 1
	elif Input.is_action_just_pressed("jump") and jumps_left > 0:
		self.velocity.y = -jump_force
		jumps_left -= 1
	else:
		collision_mask = original_collision_mask

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		self.velocity.y += gravity * delta
