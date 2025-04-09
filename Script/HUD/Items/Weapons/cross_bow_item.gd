extends Item

func _init() -> void:
	Global.load_cfg_file(item_config, Global.config_dir_path + "weapons.cfg")
	item_name = item_config.get_value("Crossbow", "item_name", "Weapon")
	item_desc = item_config.get_value("Crossbow", "item_desc", "I love this item!")
