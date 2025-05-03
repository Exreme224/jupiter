extends CharacterBody2D

@export var move_speed := 200.0
@export var jump_force := 400.0
@export var gravity := 1300.0
@export var acceleration := 10.0
@export var friction := 5.0

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_jump()
	_apply_gravity(delta)
	move_and_slide()

func _handle_movement(delta: float) -> void:
	var input_dir := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	if input_dir != 0:
		self.velocity.x = lerp(self.velocity.x, input_dir * move_speed, acceleration * delta)
	else:
		self.velocity.x = lerp(self.velocity.x, 0.0, friction * delta)

func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		self.velocity.y = -jump_force

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		self.velocity.y += gravity * delta
