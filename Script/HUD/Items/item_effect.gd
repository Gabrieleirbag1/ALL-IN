class_name ItemEffect extends Node

var item_wait_time: float = 1.0
@onready var cooldown_timer: Timer = $"../Cooldown"

func _ready() -> void:
	pass

func set_item_wait_time():
	cooldown_timer.wait_time = item_wait_time

func run():
	cooldown_timer.start()
	#faire un signal qui envoie au node de l'arme
