extends PopupMenu

enum {
	ITEM_VISIBLE_BOUNDING_RECTS,
	ITEM_VISIBLE_POLYGON_SHAPES,
}


func _init() -> void:
	add_check_item("Visible bounding rects", ITEM_VISIBLE_BOUNDING_RECTS)
	add_check_item("Visible polygon shapes", ITEM_VISIBLE_POLYGON_SHAPES)

	set_item_checked(
		ITEM_VISIBLE_BOUNDING_RECTS,
		Surface2D._PluginMetadata.visible_bounding_rects
	)
	
	set_item_checked(
		ITEM_VISIBLE_POLYGON_SHAPES,
		Surface2D._PluginMetadata.visible_polygon_shapes
	)

	id_pressed.connect(_on_id_pressed)


func _on_id_pressed(index: int) -> void:
	toggle_item_checked(index)
	match index:
		ITEM_VISIBLE_BOUNDING_RECTS:
			Surface2D._PluginMetadata.visible_bounding_rects = \
				is_item_checked(index)
		ITEM_VISIBLE_POLYGON_SHAPES:
			Surface2D._PluginMetadata.visible_polygon_shapes = \
				is_item_checked(index)
