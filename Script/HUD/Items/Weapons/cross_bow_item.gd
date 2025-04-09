extends Item

func _init() -> void:
	Global.load_cfg_file(item_config, Global.config_dir_path + "weapons")
	item_name = item_config.get_value("CrossBow", "name", "Weapon")
	item_desc = item_config.get_value("CrossBow", "desc", "I love this item!")
