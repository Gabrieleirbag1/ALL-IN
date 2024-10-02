extends CharacterBody2D

@onready var animation : AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 300
var health = 50
var health_max = 50
var health_min = 0

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _input(event):
	if Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_S):
		animation.play("walk")
	else:
		animation.play("idle")

func _physics_process(delta):
	get_input()
	move_and_slide()
