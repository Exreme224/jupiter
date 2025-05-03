extends StaticBody2D

var player: CharacterBody2D
var player_grounded: bool = false
var platform_manager: Node2D
var used: bool = false  # ✅ Prevent multiple triggers

@export var is_ground: bool = false
@export var words: Array[String] = []
var color: Color

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	label.text = ""
	label.visible = false
	label.modulate.a = 1.0
	
	# Get ref to platform manager
	platform_manager = get_parent()

func _on_area_2d_body_entered(body):
	if used:
		return  # ✅ Already triggered once
	
	if body.is_in_group("player"):
		player = body as CharacterBody2D
		
		# Wait up to 0.2 seconds for a solid grounded state
		var grounded := false
		for i in range(12):  # ~0.2 seconds at 60fps
			await get_tree().physics_frame
			if player.is_on_floor():
				grounded = true
				break
				
		if not grounded:
			return
			
		used = true  # ✅ Mark as used
		
		if !is_ground:
			# Set platform color
			sprite.modulate = color
		
		# Show random word
		if words.size() > 0:
			var index := randi_range(0, words.size() - 1)
			var word := words[index]
			label.text = word
			label.visible = true
			label.modulate.a = 1.0  # Reset alpha
			
			# Position above player
			label.global_position = player.global_position + Vector2(0, -40)
			
			var tween = label.create_tween()
			tween.tween_property(label, "global_position", label.global_position + Vector2(0, -30), 0.3)
			tween.tween_property(label, "modulate:a", 0.0, 0.2)
			
			await tween.finished
			label.visible = false
			
		# Spawn next platform
		platform_manager.spawn_platform_near(self)
