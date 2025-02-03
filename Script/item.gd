class_name Item extends Node2D

var draggable: bool = false
var is_inside_dropable: bool = false
var body_ref
var initialPos
var offset: Vector2
var hovered_dropables = []
var item_frames = []
var player_entered: bool

@onready var item_frames_inside = Global.item_frames_inside
@onready var dragged_item = Global.dragged_item

@export var item_layer_scene: PackedScene

func place_in_itemlayer():
	if item_layer_scene:
		var item_layer_instance = item_layer_scene.instantiate()
		get_tree().get_current_scene().add_child(item_layer_instance)
		self.get_parent().remove_child(self)
		item_layer_instance.add_child(self)
		global_position = self.global_position

func handle_item_layer(layer: int, viewport: bool):
	var canvas_layer = self.get_parent()
	if canvas_layer is CanvasLayer:
		canvas_layer.layer = layer
		canvas_layer.follow_viewport_enabled = viewport

func get_empty_item_frame():
	for i in range(item_frames.size()):
		var item_frame = item_frames[i]
		if not item_frames_inside[str(item_frame)]:
			var index_empty_frame = i
			return index_empty_frame
	return -1

func add_to_item_frame():
	for item in item_frames:
		if item_frames_inside[str(item)] == self:
			item_frames_inside[str(item)] = null
			break
	item_frames_inside[str(body_ref)] = self
	print(item_frames_inside)

func handle_place_in_frame_action():
	if not Global.is_dragging:
		if Input.is_action_just_pressed("place_in_frame") and player_entered:
			if item_frames.size() > 0:
				var index_empty_frame = get_empty_item_frame()
				if index_empty_frame != -1:
					place_in_itemlayer()
					handle_item_layer(1, false)
					var last_body = item_frames[index_empty_frame]
					is_inside_dropable = true
					body_ref = last_body
					var tween = get_tree().create_tween()
					add_to_item_frame()
					tween.tween_property(self, "global_position", last_body.global_position, 0.2).set_ease(Tween.EASE_OUT)

func handle_click_action():
	if draggable:
		if Input.is_action_just_pressed("click"):
			Global.dragged_item = self
			initialPos = global_position
			offset = get_global_mouse_position() - global_position
			Global.is_dragging = true
		if Input.is_action_pressed("click"):
			Global.dragged_item = self
			global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("click"):
			Global.is_dragging = false
			Global.dragged_item = null
			var tween = get_tree().create_tween()
			if is_inside_dropable and not item_frames_inside[str(body_ref)]:
				add_to_item_frame()
				tween.tween_property(self, "global_position", body_ref.global_position, 0.2).set_ease(Tween.EASE_OUT)
			else:
				if initialPos and Tween.EASE_OUT:
					tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
				else:
					return

func _ready() -> void:
	item_frames = get_tree().get_nodes_in_group("dropable")
	for item in item_frames:
		item_frames_inside[str(item)] = null
		
	if not InputMap.has_action("place_in_frame"):
		InputMap.add_action("place_in_frame")
		var key_event = InputEventKey.new()
		key_event.physical_keycode = KEY_E
		InputMap.action_add_event("place_in_frame", key_event)
	if not InputMap.has_action("click"):
		InputMap.add_action("click")
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("click", mouse_button_event)

func _process(delta: float) -> void:
	handle_place_in_frame_action()
	handle_click_action()

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
	if body.name == "Player":
		player_entered = true

func _on_area_2d_body_exited(body) -> void:
	if body.is_in_group('dropable'):
		body.set("is_item_inside", false)
		body.get_node("TextureRect").material.set_shader_parameter("brightness", 12)
		if not item_frames_inside[str(body)]:
			hovered_dropables.erase(body)
			if hovered_dropables.size() > 0:
				var last_body = hovered_dropables[-1]
				last_body.get_node("TextureRect").material.set_shader_parameter("brightness", 25)
				body_ref = last_body
			else:
				is_inside_dropable = false
				body_ref = null
	if body.name == "Player":
		player_entered = false
		
