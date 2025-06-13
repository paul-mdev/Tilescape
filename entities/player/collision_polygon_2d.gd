extends CollisionPolygon2D

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var bounding_box : Rect2 = get_collision_polygon_rect()
	var local_rect : Rect2 = Rect2(to_local(bounding_box.position), bounding_box.size)
	draw_rect(local_rect, Color(1, 0, 0), true)
	
func get_collision_polygon_rect() -> Rect2:
	var global_points: Array = []
	for local_point : Vector2 in polygon:
		var global_point : Vector2 = to_global(local_point)
		global_points.append(global_point)

	var min_x : float = global_points[0].x
	var max_x : float = global_points[0].x
	var min_y : float = global_points[0].y
	var max_y : float = global_points[0].y

	for point : Vector2 in global_points:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)

	var size : Vector2 = Vector2(max_x - min_x, max_y - min_y)
	return Rect2(Vector2(min_x, min_y), size)
