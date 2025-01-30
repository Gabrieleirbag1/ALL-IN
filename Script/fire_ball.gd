extends Area2D

@export var speed: float = 400
@export var damage: int = 10

var direction: Vector2

@onready var animation = $fire_ball_sprite

func _ready():
	animation.play("fire_ball")


func _physics_process(delta):
	global_position += direction * speed * delta

func _on_area_entered(body):
	if body is Enemy:
		body.take_damage(damage)
		queue_free()


func _on_fire_ball_sprite_animation_finished() -> void:
	queue_free()
