extends CharacterBody2D

@onready var animation : AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 250

var health = 50
var health_max = 50
var health_min = 0
var alive : bool = true
var death_animation_played : bool = false
var immortal = true

func check_health():
	if immortal:
		return
	if health <= 0 and not death_animation_played:
		alive = false
		animation.play("death")
		death_animation_played = true

func _ready():
	animation.play("idle")
	walking()

func walking():
	if not alive:
		return
	animation.play("walk")
