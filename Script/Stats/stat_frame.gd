extends Node2D

var is_item_inside = false
var shader = false
@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
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
	print_debug(1)
	texture_rect.material.set_shader_parameter("brightness", 25)

func _on_area_2d_mouse_exited() -> void:
	print_debug(2)
	texture_rect.material.set_shader_parameter("brightness", 1.0)
