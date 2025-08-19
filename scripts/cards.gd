extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
var target_size: Vector2 = Vector2(100, 150)

func set_card(card: Dictionary) -> void:
	var path := "res://assets/card_%s_%s.png" % [card["rank"], card["suit"]]
	print("Trying path:", path)

	if not FileAccess.file_exists(path):
		print("File does NOT exist at:", path)
		return

	var tex := ResourceLoader.load(path)
	if tex is Texture2D and sprite:
		sprite.texture = tex
		sprite.scale = Vector2(
			target_size.x / tex.get_width(),
			target_size.y / tex.get_height()
		)
		sprite.centered = true
		print("Texture successfully applied.")
	else:
		print("Failed to load texture OR sprite is null for path:", path)
