extends Node

var loading_screen = load("res://Scene/Menu/Loading.tscn")
var scene_path: String

func change_level(path):
	scene_path = path
	print("🔄 Changement de niveau demandé vers :", scene_path)

	var success = get_tree().change_scene_to_packed(loading_screen)

	if success == OK:
		print("✅ Écran de chargement affiché avec succès")
	else:
		print("❌ Erreur lors du changement vers l'écran de chargement")
