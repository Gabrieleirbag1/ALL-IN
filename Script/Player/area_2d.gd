extends Area2D

@onready var player_node: Player = get_node("Player")
@onready var label: Label = get_node("Label")


func _ready():
	label.visible = false

func _process(delta):
	var player_health = player_node.stat["health"] 
	if player_health == 0:
		label.visible = true
