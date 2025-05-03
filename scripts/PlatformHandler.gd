extends Node2D

# — scene to spawn —
var platform: PackedScene = preload("res://scenes/platform.tscn")

# — exports —
@export var min_spawn_offset: Vector2       = Vector2(-100, -160)
@export var max_spawn_offset: Vector2       = Vector2( 100, -240)
@export var section_size: int               = 10      # platforms per section before flipping
@export var difficulty_step: float          = 0.1     # gap increase per section
@export var color_scheme_interval: int      = 20      # re-color every N platforms

# size & distance variability
@export var min_platform_scale: float       = 0.5
@export var max_platform_scale: float       = 1.5
@export var min_gap_variation: float        = 0.8
@export var max_gap_variation: float        = 1.2

# “wall” settings (reuses the same prefab scaled tall/narrow)
@export var wall_interval: int              = 15
@export var min_wall_offset: Vector2        = Vector2(-50, -200)
@export var max_wall_offset: Vector2        = Vector2( 50, -100)
@export var wall_min_width_scale: float     = 0.3
@export var wall_max_width_scale: float     = 0.5

# — state —
var last_platform: Node2D   = null
var platform_count: int     = 0
var direction: int          = 1       # 1 = right, -1 = left
var current_color: Color    = Color.WHITE

# — RNG —
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func spawn_platform_near(pltfrm: Node2D) -> void:
	if pltfrm == null:
		return

	# — count & maybe pick a new neon hue —
	platform_count += 1
	if platform_count % color_scheme_interval == 1:
		current_color = Color.from_hsv(rng.randf(), 1.0, 1.0)

	# — flip direction after each section —
	var idx: int = platform_count - 1
	if idx > 0 and idx % section_size == 0:
		direction *= -1

	# — easy→hard: widen gap per section —
	var section_idx: float = float(idx) / float(section_size)
	var gap_min:    float = abs(min_spawn_offset.x) * (1 + section_idx * difficulty_step)
	var gap_max:    float = abs(max_spawn_offset.x) * (1 + section_idx * difficulty_step)

	# — compute random offsets with extra variation —
	var x_mag:    float = rng.randf_range(gap_min, gap_max)
	var gap_var:  float = rng.randf_range(min_gap_variation, max_gap_variation)
	var x_offset: float = x_mag * direction * gap_var
	var y_offset: float = rng.randf_range(max_spawn_offset.y, min_spawn_offset.y) * gap_var

	# — spawn & position platform —
	var new_plat: Node2D = platform.instantiate() as Node2D
	new_plat.global_position = pltfrm.global_position + Vector2(x_offset, y_offset)

	# — randomize width —
	var scale_factor: float = rng.randf_range(min_platform_scale, max_platform_scale)
	new_plat.scale.x = scale_factor
	if new_plat.has_node("CollisionShape2D"):
		var col: CollisionShape2D = new_plat.get_node("CollisionShape2D") as CollisionShape2D
		col.scale.x = scale_factor

	# — your exact color line —
	new_plat.color = current_color

	add_child(new_plat)
	last_platform = new_plat

	# — every wall_interval, spawn a tall-narrow wall platform that reaches the next platform —
	if platform_count % wall_interval == 0:
		var wall_plat: Node2D = platform.instantiate() as Node2D

		# position its base at the old platform’s Y, with random X offset
		var wx: float = pltfrm.global_position.x + rng.randf_range(min_wall_offset.x, max_wall_offset.x)
		var wy: float = pltfrm.global_position.y
		wall_plat.global_position = Vector2(wx, wy)

		# compute vertical distance needed to reach the new platform
		var height_needed: float = abs(new_plat.global_position.y - pltfrm.global_position.y)

		# original sprite height (in pixels)
		var spr: Sprite2D = wall_plat.get_node("Sprite2D") as Sprite2D
		var orig_h: float = spr.texture.get_height() * spr.scale.y

		# determine scales
		var w_scale_y: float = height_needed / orig_h
		var w_scale_x: float = rng.randf_range(wall_min_width_scale, wall_max_width_scale)
		wall_plat.scale = Vector2(w_scale_x, w_scale_y)

		# update the CollisionShape2D’s shape resource so it’s unique to this instance
		var col_shape: CollisionShape2D = wall_plat.get_node("CollisionShape2D") as CollisionShape2D
		var orig_shape = col_shape.shape
		if orig_shape is RectangleShape2D:
			var orig_rect = orig_shape as RectangleShape2D
			var new_rect: RectangleShape2D = orig_rect.duplicate() as RectangleShape2D
			new_rect.extents = orig_rect.extents * Vector2(w_scale_x, w_scale_y)
			col_shape.shape = new_rect
		elif orig_shape is CircleShape2D:
			var orig_circ = orig_shape as CircleShape2D
			var new_circ: CircleShape2D = orig_circ.duplicate() as CircleShape2D
			new_circ.radius = orig_circ.radius * max(w_scale_x, w_scale_y)
			col_shape.shape = new_circ

		# tint to match
		wall_plat.color = current_color
		add_child(wall_plat)
