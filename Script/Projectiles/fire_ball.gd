extends Area2D

@export var range: float = 300
@export var damage: int = 100
var direction: Vector2
@onready var animation = $fire_ball_sprite
@export var piercing: bool = false
@onready var fireball_sound = get_node("/root/World/Player/Fireball_sound")

func _ready():
	animation.play("fire_ball")

func _physics_process(delta):
	global_position += direction * range * delta

func _on_body_entered(body):
	if body is Enemy:
		body.take_damage(damage)
		fade_out_sound()
		if not piercing:
			queue_free()

	if body.get_class() == "TileMapLayer":
		queue_free() 
		fade_out_sound()

func _on_fire_ball_sprite_animation_finished() -> void:
	queue_free()
	fade_out_sound()

func fade_out_sound(duration: float = 1.0):
	var tween = create_tween()
	tween.tween_property(fireball_sound, "volume_db", -80, duration)
	tween.tween_callback(Callable(fireball_sound, "stop"))
	
