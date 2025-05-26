extends Node

var current_wave: int
var moving_to_next_wave: bool

var is_dragging: bool = false
var dragged_item: Item
var player_current_attack : bool
var item_frames_inside: Dictionary[ItemFrame, Item] = {}

var luck: float = 0.0
var player_level: int = 0

const config_dir_path: String = "res://Config/"
const weapon_items_dir_path: String = "res://Scene/HUD/Items/Weapons/"

func load_cfg_file(config: ConfigFile, config_file_path: String) -> void:
	var err: Error = config.load(config_file_path)
	if err != OK:
		push_error("Impossible de charger le fichier de configuration: %s" % config_file_path)
		return
		
func are_in_group(nodes: Dictionary[Variant, String]) -> bool:
	for node in nodes.keys():
		var group = nodes[node]
		if not node.is_in_group(group):
			return false
	return true
