extends Node2D
var platform = preload("res://scenes/platform.tscn")

@export var min_spawn_offset := Vector2(-100, -160)
@export var max_spawn_offset := Vector2(100, -240)

var last_platform: Node2D = null

func spawn_platform_near(platform: Node2D) -> void:
	if not platform:
		return

	var new_platform = platform.instantiate()
	
	# Generate random offset from current platform position
	var x_offset = randf_range(min_spawn_offset.x, max_spawn_offset.x)
	var y_offset = randf_range(max_spawn_offset.y, min_spawn_offset.y)  # Y is negative (upward)
	
	new_platform.global_position = platform.global_position + Vector2(x_offset, y_offset)
	add_child(new_platform)

	last_platform = new_platform
