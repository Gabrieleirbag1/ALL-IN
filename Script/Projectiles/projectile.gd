class_name Projectile extends Area2D

@onready var animation: AnimatedSprite2D = $ProjectileSprite
@onready var animation_name: String = "run"
var projectile_sound_scene
var sound_instance: AudioStreamPlayer

@export var projectile_range: float = 300
@export var damage: int = 100
@export var piercing: bool = false

var direction: Vector2

func _ready():
	animation.play(animation_name)
	if projectile_sound_scene:
		sound_instance = projectile_sound_scene.instantiate()
		add_child(sound_instance)

func _physics_process(delta):
	global_position += direction * projectile_range * delta

func _on_body_entered(body):
	if body is Enemy:
		body.take_damage(damage)
		fade_out_sound()
		if not piercing:
			queue_free()

	if body.get_class() == "TileMapLayer":
		queue_free()
		fade_out_sound()

func fade_out_sound(duration: float = 1.0):
	if sound_instance and is_instance_valid(sound_instance):
		var tween = create_tween()
		tween.tween_property(sound_instance, "volume_db", -80, duration)
		tween.tween_callback(Callable(sound_instance, "stop"))
