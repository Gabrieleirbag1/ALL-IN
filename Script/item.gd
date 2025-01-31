extends Node2D

var draggable: bool = false
var is_inside_dropable: bool = false
var body_ref
var initialPos
var offset: Vector2
var hovered_dropables = []

func handle_item_layer(layer: int, viewport: bool):
	var canvas_layer = self.get_parent()
	if canvas_layer is CanvasLayer:
		canvas_layer.layer = layer
		canvas_layer.follow_viewport_enabled = viewport

func _ready() -> void:
	if not InputMap.has_action("click"):
		InputMap.add_action("click")
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("click", mouse_button_event)

func _process(delta: float) -> void:
	if draggable:
		if Input.is_action_just_pressed("click"):
			initialPos = global_position
			offset = get_global_mouse_position() - global_position
			Global.is_dragging = true
		if Input.is_action_pressed("click"):
			global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("click"):
			Global.is_dragging = false
			var tween = get_tree().create_tween()
			if is_inside_dropable:
				tween.tween_property(self, "global_position", body_ref.global_position, 0.2).set_ease(Tween.EASE_OUT)
			else:
				if initialPos and Tween.EASE_OUT:
					tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
				else:
					return

func _on_area_2d_mouse_entered() -> void:
	if not Global.is_dragging:
		draggable = true
		scale = Vector2(1.05, 1.05)
		handle_item_layer(1, false)

func _on_area_2d_mouse_exited() -> void:
	if not Global.is_dragging:
		draggable = false
		scale = Vector2(1, 1)
		#handle_item_layer(0, true)

func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group('dropable'):
		hovered_dropables.append(body)
		body.set("is_item_inside", true)
		for b in hovered_dropables:
			b.get_node("TextureRect").material.set_shader_parameter("brightness", 12)
		var last_body = hovered_dropables[-1]
		last_body.get_node("TextureRect").material.set_shader_parameter("brightness", 25)
		is_inside_dropable = true
		body_ref = last_body

func _on_area_2d_body_exited(body) -> void:
	if body.is_in_group('dropable'):
		hovered_dropables.erase(body)
		body.set("is_item_inside", false)
		body.get_node("TextureRect").material.set_shader_parameter("brightness", 12)
		if hovered_dropables.size() > 0:
			var last_body = hovered_dropables[-1]
			last_body.get_node("TextureRect").material.set_shader_parameter("brightness", 25)
			body_ref = last_body
		else:
			is_inside_dropable = false
			body_ref = null
