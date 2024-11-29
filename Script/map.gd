extends Node2D


@onready var SceneTransitionAnimation = $SceneTransitionAnimation/AnimationPlayer
var current_wave : int
@export var skeleton_scene: PackedScene

var starting_nodes: int
var current_nodes: int
var wave_spawn_ended


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneTransitionAnimation.play("between_wave")
	current_wave = 0
	Global.current_wave = current_wave
	starting_nodes = get_child_count()
	current_nodes = get_child_count()
	position_to_next_wave()
	
func position_to_next_wave():
	if current_nodes == starting_nodes:
		if current_wave != 0:
			Global.moving_to_next_wave = true
			
		SceneTransitionAnimation.play("between_wave")
		current_wave +=1
		Global.current_wave = current_wave
		await get_tree().create_timer(0.5).timeout
		prepapre_spawn("skeleton", 4.0, 4.0)
		print(current_wave)


func prepapre_spawn(type, multiplier, mob_spawns):
	var mob_amout = float(current_wave) * multiplier
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
