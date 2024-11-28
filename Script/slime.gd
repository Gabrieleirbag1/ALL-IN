extends CharacterBody2D

@onready var animation : AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 20

var player_chase = false
var player = null
var health = 50
var health_max = 50
var health_min = 0
var alive : bool = true
var death_animation_played : bool = false
var immortal = true

func _ready():
	$Area2D.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))
	$Area2D.connect("body_exited", Callable(self, "_on_area_2d_body_exited"))

func play_animation(animation_name: String) -> void:
	if not alive:
		return
	animation.play(animation_name)
	
func check_health():
	if immortal:
		return
	if health <= 0 and not death_animation_played:
		alive = false
		play_animation("death")
		death_animation_played = true

func _physics_process(delta: float) -> void:
	if player_chase and player:
		position += (player.position - position).normalized() * speed * delta
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		player_chase = true
		play_animation("walk")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_chase = false
		play_animation("idle")
