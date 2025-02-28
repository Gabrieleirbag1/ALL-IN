extends TextureButton

var pressed_duration : float = 0.08

func _ready():
	toggle_mode = true
	connect("pressed", Callable(self, "_on_button_pressed"))

func _on_button_pressed():
	var timer = Timer.new()
	timer.wait_time = pressed_duration
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timeout"))
	add_child(timer)
	timer.start()
	Loader.change_level("res://Scene/map.tscn")

func _on_timeout():
	toggle_mode = false
	toggle_mode = true
