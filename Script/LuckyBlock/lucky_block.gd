extends CharacterBody2D

var has_player_entered = false

func handle_open_action():
	if Input.is_action_just_pressed("open") and has_player_entered:
		self.queue_free()

func _ready() -> void:
	if not InputMap.has_action("open"):
		InputMap.add_action("open")
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_E
		InputMap.action_add_event("open", key_event)
		
func _process(delta: float) -> void:
	handle_open_action()

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body)
	if body is Player:
		print(1)
		has_player_entered = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		print(2)
		has_player_entered = false
