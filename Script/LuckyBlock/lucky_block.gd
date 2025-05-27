extends CharacterBody2D

const ITEM_GENERATOR = preload("res://Scene/HUD/Items/ItemGenerator.tscn")

@onready var lucky_block_animation: AnimatedSprite2D = $LuckyBlockSprite

var has_player_entered = false

func generate_random_event():
	var random_event = randi() % 2
	if random_event == 0:
		generate_stat()
	else:
		generate_stat()

func generate_stat():
	GameController.lucky_event("stat", global_position)
	
func generate_weapon():
	var iteam_generator_instance: Node = ITEM_GENERATOR.instantiate()
	get_parent().add_child(iteam_generator_instance)
	
	var spawn_position = global_position
	
	if iteam_generator_instance.has_method("set_spawn_position"):
		iteam_generator_instance.set_spawn_position(spawn_position)
	elif iteam_generator_instance.get_script() and "spawn_position" in iteam_generator_instance:
		iteam_generator_instance.spawn_position = spawn_position
		
	GameController.lucky_event("item", global_position)

func handle_open_action():
	if Input.is_action_just_pressed("open") and has_player_entered:
		if not lucky_block_animation.animation_finished.is_connected(on_animation_finished):
			lucky_block_animation.animation_finished.connect(on_animation_finished)
		lucky_block_animation.play("explosion")

func on_animation_finished():
	if lucky_block_animation.animation_finished.is_connected(on_animation_finished):
		lucky_block_animation.animation_finished.disconnect(on_animation_finished)
	generate_random_event()	
	queue_free()

func _ready() -> void:
	lucky_block_animation.play("idle")
	if not InputMap.has_action("open"):
		InputMap.add_action("open")
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_E
		InputMap.action_add_event("open", key_event)
		
func _process(_delta: float) -> void:
	handle_open_action()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		has_player_entered = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		has_player_entered = false
