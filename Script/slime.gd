extends CharacterBody2D

@onready var animation : AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 50
var time = Time.get_time_dict_from_system()

var health = 50
var health_max = 50
var health_min = 0
var alive : bool = true
var death_animation_played : bool = false
var immortal = true

var player_position
var target_position
@onready var player = get_parent().get_node("Player") as CharacterBody2D

func _ready():
	if player == null:
		print("Player node not found")
		return
	animation.play("idle")
	walking()

func check_health():
	if immortal:
		return
	if health <= 0 and not death_animation_played:
		alive = false
		animation.play("death")
		death_animation_played = true

func walking():
	if not alive:
		return
	animation.play("walk")
	
func _physics_process(delta: float) -> void:	
	player_position = player.position
	target_position = (player_position - position).normalized()
	
	if position.distance_to(player_position) > 3:
		position += target_position * speed * delta
		rotation = position.angle_to(player_position)
