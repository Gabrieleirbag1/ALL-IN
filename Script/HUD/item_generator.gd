extends Node

var weapons_files: Array[String] = []
var spawn_position: Vector2 = Vector2.ZERO

func set_spawn_position(position: Vector2) -> void:
	spawn_position = position

func _ready() -> void:
	set_weapons_files()
	EventController.connect("lucky_event", on_lucky_event)

func set_weapons_files() -> Array[String]:
	var dir = DirAccess.open(Global.weapon_items_dir_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				continue
			else:
				weapons_files.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	
	return weapons_files

func generate_random_weapon():
	var weapon_file: String = weapons_files[randi() % weapons_files.size()]
	var weapon_scene: PackedScene = load(Global.weapon_items_dir_path + weapon_file)
	
	if not weapon_scene:
		push_error("Failed to load weapon scene: %s" % weapon_file)
		return
	
	var weapon_instance: Node = weapon_scene.instantiate()
	get_parent().add_child(weapon_instance)
	
	if weapon_instance is Node2D:
		weapon_instance.global_position = spawn_position
		
	if not weapon_instance:
		push_error("Failed to instantiate weapon from scene: %s" % weapon_file)
		return
	queue_free()

func on_lucky_event(lucky_event_category: String, _lucky_block_position: Vector2) -> void:
	if not lucky_event_category == "item":
		return
	generate_random_weapon()
