extends Control
@onready var music : Node = $Music
@onready var animation = $Panel/AnimatedSprite2D
@onready var options = $Options_Menu
@onready var menu = $VBoxContainer
@onready var text = $Label


func _ready() -> void:
	music.playing = true
	animation.play("default")
	options.visible = false
	


func _on_play_pressed() -> void:
	Loader.change_level("res://Scene/map.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_option_pressed() -> void:
	options.visible = true
	menu.visible = false
	text.text = "OPTIONS"
