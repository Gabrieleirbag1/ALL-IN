extends TileMapLayer

@onready var decor_1: TileMapLayer = $"../Forest/Decor1"

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	var cell_position = decor_1.map_to_local(coords)
	var space_state = get_world_2d().direct_space_state
	var pointQuery = PhysicsPointQueryParameters2D.new()
	pointQuery.canvas_instance_id = 0
	pointQuery.collide_with_areas = false
	pointQuery.collide_with_bodies = true
	pointQuery.collision_mask = 4294967295
	pointQuery.exclude = []
	pointQuery.position = cell_position
	var result = space_state.intersect_point(pointQuery)
	return result.size() > 0
	
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	var cell_position = decor_1.map_to_local(coords)
	var space_state = get_world_2d().direct_space_state
	var pointQuery = PhysicsPointQueryParameters2D.new()
	pointQuery.canvas_instance_id = 0
	pointQuery.collide_with_areas = false
	pointQuery.collide_with_bodies = true
	pointQuery.collision_mask = 4294967295
	pointQuery.exclude = []
	pointQuery.position = cell_position
	var result = space_state.intersect_point(pointQuery)
	if result.size() > 0:
		tile_data.set_navigation_polygon(0, null)
