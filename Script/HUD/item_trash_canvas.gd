extends CanvasLayer

@onready var trash_animated_sprite_2d: AnimatedSprite2D = $TrashAnimatedSprite2D

func _ready() -> void:
	EventController.connect("item_trash_display", on_item_trash_displayed)
	
func on_item_trash_displayed(is_disposable: bool):
	if is_disposable:
		visible = true
		trash_animated_sprite_2d.play("run")
	else:
		visible = false
		trash_animated_sprite_2d.stop()
