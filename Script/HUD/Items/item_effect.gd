class_name ItemEffect extends Node

var item_wait_time: float = 1.0
@onready var cooldown_timer: Timer = $"../Cooldown"
@onready var item_signals: Node = $"../ItemSignals"

func _ready() -> void:
	item_signals.connect("item_equipped", _on_item_equipped)

func set_item_wait_time():
	cooldown_timer.wait_time = item_wait_time
	
func _on_item_equipped(is_equipped: bool):
	if is_equipped:
		run()
	else:
		stop()

func run():
	# This method is overwritten
	pass
	
func stop():
	# This method is overwritten
	pass
