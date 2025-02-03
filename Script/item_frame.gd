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
	if Global.item_frames_inside[str(self)]:
		if not Global.item_frames_inside[str(self)] == Global.dragged_item:
			$TextureRect.material.set_shader_parameter("brightness", 25)
	else:
		if Global.is_dragging:
			print(is_item_inside)
			if not is_item_inside:
				$TextureRect.material.set_shader_parameter("brightness", 12)
			elif is_item_inside:
				$TextureRect.material.set_shader_parameter("brightness", 25)
		elif not Global.is_dragging:
			$TextureRect.material.set_shader_parameter("brightness", 1.0)
