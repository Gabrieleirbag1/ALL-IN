extends TileMapLayer

@onready var forest: TileMapLayer = $"../Forest"
@onready var decor_1: TileMapLayer = $"../Forest/Decor1"
@onready var decor_2: TileMapLayer = $"../Forest/Decor1/Decor2"
@onready var decor_3: TileMapLayer = $"../Forest/Decor1/Decor2/Decor3"

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	if coords in decor_1.get_used_cells_by_id(0) or coords in decor_2.get_used_cells_by_id(0) or coords in decor_3.get_used_cells_by_id(0) or coords in forest.get_used_cells_by_id(0):
		return true
	return false
	
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if coords in decor_1.get_used_cells_by_id(0) or coords in decor_2.get_used_cells_by_id(0) or coords in decor_3.get_used_cells_by_id(0) or coords in forest.get_used_cells_by_id(0):
		tile_data.set_navigation_polygon(0, null)
