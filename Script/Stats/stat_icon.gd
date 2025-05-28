extends TextureRect

@export_dir var stats_icon_dir_path: String = "res://Assets/Stats/icons/png180x/"

func set_stat_icon(stat: String):
	self.texture = load(stats_icon_dir_path + stat + ".png")
