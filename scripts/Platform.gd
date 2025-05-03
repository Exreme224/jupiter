extends StaticBody2D

var player: CharacterBody2D
@export var words: Array[String] = []
@export var color: Color

@onready var label: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	label.text = ""
	label.visible = false
	label.modulate.a = 1.0

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player = body as CharacterBody2D
		
		# Set platform color
		sprite.modulate = color
		
		# Show random word
		if words.size() > 0:
			var index := randi_range(0, words.size() - 1)
			var word := words[index]
			
			label.text = word
			label.visible = true
			label.modulate.a = 1.0  # Reset alpha in case it was faded before
			
			# Position above player
			label.global_position = player.global_position + Vector2(0, -40)
			
			var tween = label.create_tween()
			tween.tween_property(label, "global_position", label.global_position + Vector2(0, -30), 0.3)
			tween.tween_property(label, "modulate:a", 0.0, 0.2)
			
			# After tween, hide the label
			await tween.finished
			label.visible = false
