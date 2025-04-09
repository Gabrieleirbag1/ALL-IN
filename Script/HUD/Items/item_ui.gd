class_name Item extends CharacterBody2D

# Item state variables
var draggable: bool = false
var is_click_event_active: bool = false
var is_inside_dropable: bool = false
var is_inside_weapon_frame: bool = false
var is_disposable: bool = false
var is_in_trash_area: bool = false
var has_player_entered: bool = false
var item_level: int = 1
var is_mergeable: bool = false

# Item merge variables
var item_body_to_merge: Item

# Item position tracking
var body_ref: ItemFrame
var initialPos: Vector2
var offset: Vector2

# Item frame references
var item_frames: Array = []
var hovered_dropables: Array[ItemFrame] = []
var current_hovered_body: ItemFrame
var last_hovered_body: ItemFrame

# Item property
var item_config: ConfigFile = ConfigFile.new()
var item_name: String = "Item"
var item_desc: String = "I love this item!"

# Tooltip
@onready var tooltip_control: Control = $TooltipControl

# Global references
@onready var item_frames_inside: Dictionary = Global.item_frames_inside
@onready var dragged_item: Item = Global.dragged_item

# Nodes references
@onready var item_level_rich_text_label: RichTextLabel = $ItemLevelRichTextLabel
@onready var item_effect: ItemEffect = $ItemEffect
@onready var item_signals: Node = $ItemSignals

@export var item_layer_scene: PackedScene

#region Lifecycle Methods
func _ready() -> void:
	initialize_item_frames()
	setup_input_actions()
	set_tooltip_text()

func _process(_delta: float) -> void:
	handle_place_in_frame_action()
	handle_click_action()
#endregion

#region Item Frame Management
func initialize_item_frames() -> void:
	item_frames = get_tree().get_nodes_in_group("dropable")
	for item in item_frames:
		item_frames_inside[item] = null

func get_empty_item_frame() -> int:
	for i in range(item_frames.size()):
		var item_frame: ItemFrame = item_frames[i]
		var item: Item =  item_frames_inside[item_frame]
		if not item_frame.is_in_group("equipable") and not item:
			return i
	for i in range(item_frames.size()):
		var item_frame: ItemFrame = item_frames[i]
		var item: Item =  item_frames_inside[item_frame]
		if item.item_name == self.item_name:
			manage_merge(item, true)
			merge_items()
			return -1
	return -1
	
func weapon_is_equipped():
	for item in item_frames_inside:
		var item_body = item_frames_inside[item]
		if item_body and is_instance_valid(item_body):
			if item_body.item_name == self.item_name:
				if item.is_in_group("equipable"):
					return true
	return false

func is_addable_to_item_frame() -> bool:
	if not is_inside_dropable:
		return false
	if item_frames_inside[body_ref]:
		return false
	if is_inside_weapon_frame:
		return false
	if weapon_is_equipped():
		return false
	return true

func add_to_item_frame():
	# Remove from previous frame
	for item in item_frames:
		if item_frames_inside[item] == self:
			item_frames_inside[item] = null
			break
	
	# Add to new frame
	item_frames_inside[body_ref] = self
	if body_ref.is_in_group("equipable"):
		is_inside_weapon_frame = true
		item_signals.emit_signal("item_equipped", true)
#endregion

#region Item Layer Management
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
#endregion

#region Input Handling
func setup_input_actions():
	if not InputMap.has_action("place_in_frame"):
		InputMap.add_action("place_in_frame")
		var key_event: InputEvent = InputEventKey.new()
		key_event.physical_keycode = KEY_E
		InputMap.action_add_event("place_in_frame", key_event)

func add_input_click_action():
	is_click_event_active = true
	if not InputMap.has_action("click"):
		InputMap.add_action("click")
		var mouse_button_event = InputEventMouseButton.new()
		mouse_button_event.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("click", mouse_button_event)

func handle_place_in_frame_action():
	if not Global.is_dragging:
		if Input.is_action_just_pressed("place_in_frame") and has_player_entered:
			if item_frames.size() > 0:
				var index_empty_frame: int = get_empty_item_frame()
				if index_empty_frame != -1:
					auto_place_in_frame(index_empty_frame)

func auto_place_in_frame(frame_index: int):
	place_in_itemlayer()
	handle_item_layer(1, false)
	var last_body: ItemFrame = item_frames[frame_index]
	is_inside_dropable = true
	body_ref = last_body
	var tween: Tween = get_tree().create_tween()
	add_to_item_frame()
	tween.tween_property(self, "global_position", last_body.global_position, 0.2).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_tween_completed)

func handle_click_action():
	if draggable and is_click_event_active:
		if Input.is_action_just_pressed("click"):
			start_drag()
		if Input.is_action_pressed("click"):
			continue_drag()
		elif Input.is_action_just_released("click"):
			end_drag()

func start_drag():
	Global.dragged_item = self
	initialPos = global_position
	offset = get_global_mouse_position() - global_position
	Global.is_dragging = true

func continue_drag():
	Global.dragged_item = self
	global_position = get_global_mouse_position() - offset

func end_drag():
	scale_item_size()
	if is_disposable:
		queue_free()
	elif is_mergeable:
		merge_items()
	Global.is_dragging = false
	Global.dragged_item = null
	
	if is_addable_to_item_frame():
		var tween: Tween = get_tree().create_tween()
		add_to_item_frame()
		tween.tween_property(self, "global_position", body_ref.global_position, 0.2).set_ease(Tween.EASE_OUT)
	elif initialPos and Tween.EASE_OUT:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
#endregion

#region Visual Effects
func scale_item_size(scaling_offset: float = 0.0):
	if body_ref:
		if not is_inside_weapon_frame:
			self.scale = Vector2(body_ref.item_scaling_x + scaling_offset, body_ref.item_scaling_y + scaling_offset)

func set_is_disposable(disposable_state: bool):
	is_disposable = disposable_state
	GameController.item_trash_display(disposable_state)
#endregion

#region Merge
func manage_merge(body: Item, is_mergeable_value: bool):
	if body.item_level == item_level and body.item_name == item_name:
		item_body_to_merge = body
		is_mergeable = is_mergeable_value

func merge_items():
	if is_mergeable:
		item_body_to_merge.item_level = item_body_to_merge.item_level + 1
		item_body_to_merge.item_level_rich_text_label.set_item_level(item_body_to_merge.item_level)
		queue_free()
#endregion

#region Signal Callbacks
func _on_tween_completed():
	scale_item_size()
	add_input_click_action()
	var collision_object: Area2D = $Area2D 
	if collision_object:
		collision_object.set_collision_mask_value(7, true)

func _on_area_2d_mouse_entered() -> void:
	_draggable_mouse_event(true, 0.1)

func _on_area_2d_mouse_exited() -> void:
	_draggable_mouse_event(false)

func _draggable_mouse_event(draggable_value, scaling_offset: float = 0.0):
	if not Global.is_dragging and is_click_event_active:
		draggable = draggable_value
		scale_item_size(scaling_offset)

func _on_area_2d_body_entered(body) -> void:
	if body.name == "ItemTrash":
		handle_trash_area_entered()
	elif body.name == "Player":
		has_player_entered = true
	elif body.is_in_group('dropable'):
		handle_dropable_entered(body)
	if body.is_in_group('weapons'):
		if Global.dragged_item == self:
			manage_merge(body, true)
	else:
		is_mergeable = false

func _on_area_2d_body_exited(body) -> void:
	if body.name == "ItemTrash":
		handle_trash_area_exited()
	elif body.name == "Player":
		has_player_entered = false
	elif body.is_in_group('dropable'):
		handle_dropable_exited(body)
	elif body.is_in_group('weapons'):
		if Global.dragged_item == self:
			manage_merge(body, false)
#endregion

#region Collision Handling
func handle_trash_area_entered():
	is_in_trash_area = true
	set_is_disposable(true)

func handle_trash_area_exited():
	is_in_trash_area = false
	set_is_disposable(false)

func handle_dropable_entered(body):
	body.set("is_item_inside", true)
	
	# Reset previous hovered body to normal highlight
	if current_hovered_body and current_hovered_body != body:
		current_hovered_body.get_node("TextureRect").material.set_shader_parameter("brightness", 12)
	
	# Set the new hovered body
	current_hovered_body = body
	
	# Set the new body to selected brightness
	body.get_node("TextureRect").material.set_shader_parameter("brightness", 25)
	is_inside_dropable = true
	body_ref = body
	scale_item_size()

func handle_dropable_exited(body):
	body.set("is_item_inside", false)
	
	# Only reset brightness if this is the current hovered body
	if body == current_hovered_body:
		body.get_node("TextureRect").material.set_shader_parameter("brightness", 12)
		current_hovered_body = null
		
		# Find a new current_hovered_body among the still hovered frames
		for frame in item_frames:
			if frame.is_in_group('dropable') and frame.is_item_inside and frame != body:
				current_hovered_body = frame
				frame.get_node("TextureRect").material.set_shader_parameter("brightness", 25)
				is_inside_dropable = true
				body_ref = frame
				break
		
		# If no other frame is hovered, reset states
		if not current_hovered_body:
			is_inside_dropable = false
			body_ref = null
	
	scale_item_size()
	last_hovered_body = body
#endregion

#region Tooltip

func set_tooltip_text():
	var tooltip_text: String = item_name + "\n" + item_desc
	tooltip_control.set_tooltip_text(tooltip_text)
	
