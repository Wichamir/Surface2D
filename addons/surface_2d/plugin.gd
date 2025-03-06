@tool
extends EditorPlugin


enum DebuggerMenuItem {
	VISIBLE_BOUNDING_RECTS,
	VISIBLE_POLYGON_SHAPES,
}


@warning_ignore("shadowed_variable_base_class")
static func init_setting(name: String, default: Variant, type: int, hint: int = PROPERTY_HINT_NONE, requires_restart: bool = false) -> void:
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, default)
	ProjectSettings.set_initial_value(name, default)
	ProjectSettings.add_property_info({
		name = name,
		type = type,
		hint = hint
	})
	ProjectSettings.set_restart_if_changed(name, requires_restart)


func _enter_tree() -> void:
	init_setting("addons/surface_2d/defaults/cull_mask",           0,                      TYPE_INT,   PROPERTY_HINT_LAYERS_2D_RENDER, true)
	init_setting("addons/surface_2d/defaults/editor_color",        Color(Color.WHITE, .2), TYPE_COLOR, PROPERTY_HINT_NONE,             true)
	init_setting("addons/surface_2d/defaults/debug_rect_color",    Color(Color.WHITE, .2), TYPE_COLOR, PROPERTY_HINT_NONE,             true)
	init_setting("addons/surface_2d/defaults/debug_polygon_color", Color(Color.WHITE, .2), TYPE_COLOR, PROPERTY_HINT_NONE,             true)
	
	add_tool_submenu_item("Surface2D Debugger...", create_tool_menu())

	add_custom_type(
		"Surface2D", "Polygon2D",
		preload("res://addons/surface_2d/surface_2d.gd"),
		preload("res://addons/surface_2d/icon.svg")
	)


func _exit_tree() -> void:
	remove_custom_type("Surface2D")

	remove_tool_menu_item("Surface2D Debugger...")

	ProjectSettings.set_setting("addons/surface_2d/defaults/cull_mask", null)
	ProjectSettings.set_setting("addons/surface_2d/defaults/editor_color", null)
	ProjectSettings.set_setting("addons/surface_2d/defaults/debug_rect_color", null)
	ProjectSettings.set_setting("addons/surface_2d/defaults/debug_polygon_color", null)


func create_tool_menu() -> PopupMenu:
	var menu := PopupMenu.new()
	var _editor_settings: EditorSettings = EditorInterface.get_editor_settings()

	menu.add_check_item("Visible bounding rects", DebuggerMenuItem.VISIBLE_BOUNDING_RECTS)
	menu.add_check_item("Visible polygon shapes", DebuggerMenuItem.VISIBLE_POLYGON_SHAPES)

	menu.set_item_checked(
		DebuggerMenuItem.VISIBLE_BOUNDING_RECTS,
		_editor_settings.get_project_metadata("Surface2D", "visible_bounding_rects", false)
	)
	
	menu.set_item_checked(
		DebuggerMenuItem.VISIBLE_POLYGON_SHAPES,
		_editor_settings.get_project_metadata("Surface2D", "visible_polygon_shapes", false)
	)

	menu.id_pressed.connect(
		func(index: int) -> void:
			menu.toggle_item_checked(index)
			match index:
				DebuggerMenuItem.VISIBLE_BOUNDING_RECTS:
					_editor_settings.set_project_metadata("Surface2D", "visible_bounding_rects", menu.is_item_checked(index))
				DebuggerMenuItem.VISIBLE_POLYGON_SHAPES:
					_editor_settings.set_project_metadata("Surface2D", "visible_polygon_shapes", menu.is_item_checked(index))
	)

	return menu
