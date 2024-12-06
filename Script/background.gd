extends TileMapLayer

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return intersect_point(to_global(map_to_local(coords)))
	
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if intersect_point(to_global(map_to_local(coords))):
		tile_data.set_navigation_polygon(0, null)

func intersect_point(point: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state
	var pointQuery := PhysicsPointQueryParameters2D.new()
	pointQuery.collide_with_areas = false
	pointQuery.collide_with_bodies = true
	pointQuery.collision_mask = 2#<-HERE
	pointQuery.position = point
	var result = space_state.intersect_point(pointQuery, 1)
	return not result.is_empty()

func _ready() -> void:
	await get_tree().process_frame
	notify_runtime_tile_data_update.call_deferred()
