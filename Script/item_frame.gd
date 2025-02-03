extends StaticBody2D

var is_item_inside = false

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
	$TextureRect.material = mat

func _process(delta: float) -> void:
	if not is_item_inside:
		if Global.is_dragging:
			$TextureRect.material.set_shader_parameter("brightness", 12)
		else:
			$TextureRect.material.set_shader_parameter("brightness", 1.0)
	else:
		if Global.item_frames_inside[str(self)]:
			$TextureRect.material.set_shader_parameter("brightness", 25)
