class_name ItemEffect extends Node

var item_wait_time: float = 1.0
@onready var cooldown_timer: Timer = $"../Cooldown"
@onready var item_signals: Node = $"../ItemSignals"

func _ready() -> void:
	item_signals.connect("item_equipped", _on_item_equipped)
	EventController.connect("attack_speed_update", _on_attack_speed_update)

func set_item_wait_time(new_item_wait_time):
	print(new_item_wait_time)
	cooldown_timer.wait_time = new_item_wait_time
	
func _on_item_equipped(is_equipped: bool):
	if is_equipped:
		run()
	else:
		stop()

func _on_attack_speed_update(new_attack_speed: float):
	print("new_as", new_attack_speed)
	var new_item_wait_time: float = item_wait_time / new_attack_speed
	set_item_wait_time(new_item_wait_time)

func run():
	# This method is overwritten
	pass
	
func stop():
	cooldown_timer.stop()
