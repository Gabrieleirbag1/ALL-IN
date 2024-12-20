extends Node2D

@export_enum("small", "medium", "large") var xp_type: String = "small"
@export var xp_value: Dictionary = {"small": 100, "medium": 200, "large": 500}
@onready var animation : AnimatedSprite2D = $AnimatedSprite2D

func get_xp(xp: int) -> String:
	for key in xp_value.keys():
		if xp_value[key] == xp:
			print(key)
			return key
	return "small"

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		GameController.xp_collected(xp_value[xp_type])
		self.queue_free()

func _ready() -> void:
	animation.play("idle_" + xp_type)
