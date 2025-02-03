extends Control

func _ready() -> void:
	get_tree().paused = false
	$AnimationPlayer.stop()  
	self.visible = false

func pause():
	if !get_tree().paused:
		get_tree().paused = true
		self.visible = true 
		$AnimationPlayer.play("blur")

func resume():
	if get_tree().paused:
		get_tree().paused = false
		$AnimationPlayer.play_backwards("blur")
		await $AnimationPlayer.animation_finished  
		self.visible = false  

func Esc():
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause()

func _process(delta: float) -> void:
	Esc()

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_options_pressed() -> void:
	pass

func _on_exit_pressed() -> void:
	get_tree().paused = false
	Loader.change_level("res://Scene/Menu/Main_menu.tscn")
