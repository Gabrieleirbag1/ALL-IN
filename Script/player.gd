extends CharacterBody2D

@onready var animation : AnimatedSprite2D = $AnimatedSprite2D
@onready var invincibility_timer: Timer = $Invincibility
@export var speed = 250
var health = 50
var health_max = 50
var health_min = 0
var alive : bool = true
var death_animation_played : bool = false
var immortal = false

var invincible = false

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

	# Déclenche l'animation d'attaque si la touche est pressée
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		animation.play("attack_1")

func _input(event):
	if alive and not is_attacking:
		if Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_DOWN):
			animation.play("walk_shadow")
		elif Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
			animation.play("walk_shadow")
			animation.scale.x = abs(animation.scale.x)
		elif Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_LEFT):
			animation.play("walk_shadow")
			animation.scale.x = -abs(animation.scale.x)
		else:
			animation.play("idle_shadow")

func check_health():
	if immortal:
		return
	if health <= 0 and not death_animation_played:
		alive = false
		animation.play("death")
		death_animation_played = true
		
func take_damage(enemyVelocity, knockback_force, damage):
	if not invincible:
		health -= damage
		var kb_direction = (enemyVelocity - velocity).normalized() * knockback_force
		velocity = kb_direction
		move_and_slide()

func enemy_attack(velocity, knockback_force, damage):
	if alive and not invincible:
		take_damage(velocity, knockback_force, damage)
		animation.play("hurt")
		check_health()
		invincible = true
		invincibility_timer.start()


func _input(event):
	if alive:
		if Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_RIGHT):
			animation.play("walk_shadow")
		else:
			animation.play("idle_shadow")
			
func _physics_process(delta):
	if alive:
		get_input()
		move_and_slide()

func _on_invincibility_timeout() -> void:
	invincible = false

func _on_animation_finished():
	# Réinitialise l'état après une attaque ou une mort
	if animation.animation == "attack_1":
		is_attacking = false
	elif animation.animation == "death":
		alive = false
