extends Control

@export var loading_bar: ProgressBar
@export var percentage_label: Label

var scene_path: String
var progress: Array = [0.0]
var update: float = 0.0

func _ready():
	scene_path = Loader.scene_path
	ResourceLoader.load_threaded_request(scene_path)
	

func _process(delta):
	var status = ResourceLoader.load_threaded_get_status(scene_path, progress)


	if progress.size() > 0 and progress[0] > update:
		update = progress[0]

	if loading_bar.value >= 1.0:
		if update >= 1.0:
			var packed_scene = ResourceLoader.load_threaded_get(scene_path)
			
			if packed_scene:
				get_tree().change_scene_to_packed(packed_scene)
			else:
				print("❌ Erreur : Impossible de charger la scène :", scene_path)

	if loading_bar.value < update:
		loading_bar.value = lerp(loading_bar.value, update, delta)

	loading_bar.value += delta * 0.2 * \
		(0.5 if update >= 1.0 else clamp(0.9 - loading_bar.value, 0.0, 1.0))

	percentage_label.text = str(int(loading_bar.value * 100.0)) + " %"
