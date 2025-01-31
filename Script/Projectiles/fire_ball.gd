extends Area2D

@export var range: float = 300
@export var damage: int = 100
var direction: Vector2
@onready var animation = $fire_ball_sprite
@export var piercing: bool = false

func _ready():
	animation.play("fire_ball")
	connect("body_entered", _on_body_entered)
	connect("area_entered", _on_area_entered)

func _physics_process(delta):
	global_position += direction * range * delta


func _on_body_entered(body):
	if body is Enemy:
		body.take_damage(damage)
		if not piercing:
			queue_free()

	if body.get_class() == "TileMapLayer":
		queue_free() 

func _on_fire_ball_sprite_animation_finished() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	pass
