extends Control
@onready var music : Node = $Music
@onready var animation = $Panel/AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music.playing = true
	animation.play("default")
	



func _on_start_pressed() -> void:
	Loader.change_level("res://Scene/map.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
