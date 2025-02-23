extends Node2D

@onready var texture_rect: TextureRect = $TextureRect
@onready var item_icon: TextureRect = $TextureRect/ItemIcon

var is_mouse_inside = false
var shader = false

var stats: Dictionary = {
	"damage": 0, 
	"attack_speed": 0, 
	"life_steal": 0, 
	"critical": 0, 
	"health": 0, 
	"speed": 0, 
	"luck": 0
}

func _ready() -> void:
	set_shader()
	set_click_event()

func _process(delta: float) -> void:
	handle_click_action()

func handle_click_action():
	if Input.is_action_just_pressed("click"):
		if is_mouse_inside:
			get_tree().paused = false
			var icon_name = item_icon.texture.get_path().get_file().get_basename()
			stats[icon_name] = 10
			GameController.stats_progress(stats)

func set_click_event():
	if not InputMap.has_action("click"):
		InputMap.add_action("click")
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("click", mouse_button_event)
		
func set_shader():
	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;

	uniform float brightness: hint_range(0.0,2.0) = 1.0;

	void fragment() {
		COLOR = texture(TEXTURE, UV) * vec4(vec3(brightness), 1.0);
	}
	"""
	var mat = ShaderMaterial.new()
	mat.shader = shader
	texture_rect.material = mat

func _on_area_2d_mouse_entered() -> void:
	is_mouse_inside = true
	texture_rect.material.set_shader_parameter("brightness", 25)

func _on_area_2d_mouse_exited() -> void:
	is_mouse_inside = false
	texture_rect.material.set_shader_parameter("brightness", 1.0)
