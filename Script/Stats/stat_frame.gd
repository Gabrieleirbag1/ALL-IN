extends Node2D

@onready var texture_rect: TextureRect = $StatBackground
@onready var stat_icon: TextureRect = $StatBackground/StatIcon
@onready var stat_value: CenteredRichTextLabel= $StatBackground/StatValue

var is_mouse_inside = false
var shader = false

func _ready() -> void:
	set_shader()
	set_click_event()

func _process(delta: float) -> void:
	handle_click_action()

func handle_click_action():
	var stats: Dictionary = {
		"damage": 0, 
		"attack_speed": 0, 
		"life_steal": 0, 
		"critical": 0, 
		"health": 0, 
		"speed": 0, 
		"luck": 0
	}
	if Input.is_action_just_pressed("click"):
		if is_mouse_inside:
			get_tree().paused = false
			var icon_name = stat_icon.texture.get_path().get_file().get_basename()
			stats[icon_name] = get_all_int_values(stat_value.text)[0]
			GameController.stats_progress(stats)

func get_all_int_values(text: String) -> Array[int]:
	var regex = RegEx.new()
	regex.compile(r"[-+]?\d+")
	var results: Array[int] = []
	var search_result = regex.search_all(text)
	for result in search_result:
		var value = result.get_string()
		results.append(int(value))
	return results

func set_click_event():
	if not InputMap.has_action("click"):
		InputMap.add_action("click")
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("click", mouse_button_event)
		
func set_shader():
	shader = Shader.new()
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
	texture_rect.material.set_shader_parameter("brightness", 8)

func _on_area_2d_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	is_mouse_inside = true
	texture_rect.material.set_shader_parameter("brightness", 15)

func _on_area_2d_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	is_mouse_inside = false
	texture_rect.material.set_shader_parameter("brightness", 8)
