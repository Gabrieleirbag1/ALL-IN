extends TileMapLayer

@onready var decor_1: TileMapLayer = $"../Forest/Decor1"
var custom_offset: Vector2i = Vector2i(0, 2)

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	for cell in decor_1.get_used_cells_by_id(0):
		if coords == cell + custom_offset:
			return true
	return false
	
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	for cell in decor_1.get_used_cells_by_id(0):
		if coords == cell + custom_offset:
			tile_data.set_navigation_polygon(0, null)
