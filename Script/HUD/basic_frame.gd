class_name BasicFrame extends StaticBody2D

var is_item_inside: bool = false
var item_scaling_x: float = 3.0
var item_scaling_y: float = 3.0

const BRIGHTNESS_NORMAL: float = 1.0
const BRIGHTNESS_HIGHLIGHTED: float = 12.0
const BRIGHTNESS_SELECTED: float = 25.0

func _ready() -> void:
	_setup_shader()

func _process(_delta: float) -> void:
	update_brightness()

func _setup_shader() -> void:
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
	set_brightness(BRIGHTNESS_NORMAL)

# Update the frame's brightness based on its state
func update_brightness() -> void:
	if not Global.item_frames_inside:
		return
		
	if Global.item_frames_inside[self]:
		_handle_occupied_frame()
	else:
		_handle_empty_frame()

# Handle brightness for frames containing items
func _handle_occupied_frame() -> void:
	if self.is_in_group("weapons"):
		return
		
	if Global.item_frames_inside[self] != Global.dragged_item:
		set_brightness(BRIGHTNESS_SELECTED)

# Handle brightness for empty frames
func _handle_empty_frame() -> void:
	if Global.is_dragging:
		_update_brightness_while_dragging()
	else:
		set_brightness(BRIGHTNESS_NORMAL)

# Update brightness during dragging operations
func _update_brightness_while_dragging() -> void:
	if Global.dragged_item.is_inside_weapon_frame:
		set_brightness(BRIGHTNESS_NORMAL)
	elif not is_item_inside:
		set_brightness(BRIGHTNESS_HIGHLIGHTED)
	else:
		set_brightness(BRIGHTNESS_SELECTED)

# Helper method to set brightness parameter
func set_brightness(value: float) -> void:
	if $TextureRect.material:
		$TextureRect.material.set_shader_parameter("brightness", value)
