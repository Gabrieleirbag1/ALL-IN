class_name Item extends Node2D

var draggable: bool = false
var is_click_event_active: bool = false
var is_inside_dropable: bool = false
var body_ref: BasicFrame
var initialPos: Vector2
var offset: Vector2
var hovered_dropables: Array[BasicFrame] = []
var item_frames: Array = []
var has_player_entered: bool
var is_inside_weapon_frame: bool = false

@onready var item_frames_inside: Dictionary[BasicFrame, Node2D] = Global.item_frames_inside
@onready var dragged_item: Node2D = Global.dragged_item

@export var item_layer_scene: PackedScene

func place_in_itemlayer():
	if item_layer_scene:
		var item_layer_instance = item_layer_scene.instantiate()
		get_tree().get_current_scene().add_child(item_layer_instance)
		self.get_parent().remove_child(self)
		item_layer_instance.add_child(self)
		global_position = self.global_position

func handle_item_layer(layer: int, viewport: bool):
	var canvas_layer: CanvasLayer = self.get_parent()
	if canvas_layer is CanvasLayer:
		canvas_layer.layer = layer
		canvas_layer.follow_viewport_enabled = viewport
	
func get_empty_item_frame() -> int:
	for i in range(item_frames.size()):
		var item_frame: BasicFrame = item_frames[i]
		if not item_frame.is_in_group("weapons"):
			if not item_frames_inside[item_frame]:
				var index_empty_frame: int = i
				return index_empty_frame
	return -1

func is_addable_to_item_frame() -> bool:
	if not is_inside_dropable:
		return false
	if item_frames_inside[body_ref]:
		return false
	if is_inside_weapon_frame:
		return false
	return true

func add_to_item_frame():
	for item in item_frames:
		if item_frames_inside[item] == self:
			item_frames_inside[item] = null
			break
	item_frames_inside[body_ref] = self
	if body_ref.is_in_group("weapons"):
		is_inside_weapon_frame = true
	
func add_input_click_action():
	is_click_event_active = true
	if not InputMap.has_action("click"):
		InputMap.add_action("click")
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("click", mouse_button_event)
	
func scale_item_size():
	self.scale = Vector2(body_ref.item_scaling_x, body_ref.item_scaling_y)

func _on_tween_completed():
	scale_item_size()
	add_input_click_action()
	
func handle_place_in_frame_action():
	if not Global.is_dragging:
		if Input.is_action_just_pressed("place_in_frame") and has_player_entered:
			if item_frames.size() > 0:
				var index_empty_frame: int = get_empty_item_frame()
				if index_empty_frame != -1:
					place_in_itemlayer()
					handle_item_layer(1, false)
					var last_body: BasicFrame = item_frames[index_empty_frame]
					is_inside_dropable = true
					body_ref = last_body
					var tween: Tween = get_tree().create_tween()
					add_to_item_frame()
					tween.tween_property(self, "global_position", last_body.global_position, 0.2).set_ease(Tween.EASE_OUT)
					tween.finished.connect(_on_tween_completed)

func handle_click_action():
	if draggable and is_click_event_active:
		if Input.is_action_just_pressed("click"):
			Global.dragged_item = self
			initialPos = global_position
			offset = get_global_mouse_position() - global_position
			Global.is_dragging = true
		if Input.is_action_pressed("click"):
			Global.dragged_item = self
			global_position = get_global_mouse_position() - offset
			scale_item_size()
		elif Input.is_action_just_released("click"):
			Global.is_dragging = false
			Global.dragged_item = null
			var tween: Tween = get_tree().create_tween()
			if is_addable_to_item_frame():
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
		item_frames_inside[item] = null
		
	if not InputMap.has_action("place_in_frame"):
		InputMap.add_action("place_in_frame")
		var key_event: InputEvent = InputEventKey.new()
		key_event.physical_keycode = KEY_E
		InputMap.action_add_event("place_in_frame", key_event)

func _process(_delta: float) -> void:
	handle_place_in_frame_action()
	handle_click_action()

func _on_area_2d_mouse_entered() -> void:
	if not Global.is_dragging and is_click_event_active:
		draggable = true
		scale = Vector2(body_ref.item_scaling_x + 0.05, body_ref.item_scaling_y + 0.05)
		#handle_item_layer(1, false)

func _on_area_2d_mouse_exited() -> void:
	if not Global.is_dragging and is_click_event_active:
		draggable = false
		scale = Vector2(body_ref.item_scaling_x, body_ref.item_scaling_y)
		#handle_item_layer(0, true)

func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group('dropable'):
		hovered_dropables.append(body)
		body.set("is_item_inside", true)
		for b in hovered_dropables:
			b.get_node("TextureRect").material.set_shader_parameter("brightness", 12)
		var last_body: BasicFrame = hovered_dropables[-1]
		last_body.get_node("TextureRect").material.set_shader_parameter("brightness", 25)
		is_inside_dropable = true
		body_ref = last_body
	if body.name == "Player":
		has_player_entered = true

func _on_area_2d_body_exited(body) -> void:
	if body.is_in_group('dropable'):
		body.set("is_item_inside", false)
		body.get_node("TextureRect").material.set_shader_parameter("brightness", 12)
		if not item_frames_inside[body]:
			hovered_dropables.erase(body)
			if hovered_dropables.size() > 0:
				var last_body: BasicFrame = hovered_dropables[-1]
				last_body.get_node("TextureRect").material.set_shader_parameter("brightness", 25)
				body_ref = last_body
			else:
				is_inside_dropable = false
				body_ref = null
	if body.name == "Player":
		has_player_entered = false
		
