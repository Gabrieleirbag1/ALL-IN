class_name BasicFrame extends StaticBody2D

var is_item_inside: bool = false
var item_scaling_x: int = 3
var item_scaling_y: int = 3

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

func _process(_delta: float) -> void:
	if Global.item_frames_inside:
		if Global.item_frames_inside[self]:
			if self.is_in_group("weapons"):
				return
			elif not Global.item_frames_inside[self] == Global.dragged_item:
				$TextureRect.material.set_shader_parameter("brightness", 25)
		else:
			if Global.is_dragging:
				if Global.dragged_item.is_inside_weapon_frame:
					$TextureRect.material.set_shader_parameter("brightness", 1.0)
				elif not is_item_inside:
					$TextureRect.material.set_shader_parameter("brightness", 12)
				elif is_item_inside:
					$TextureRect.material.set_shader_parameter("brightness", 25)
			elif not Global.is_dragging:
				$TextureRect.material.set_shader_parameter("brightness", 1.0)
