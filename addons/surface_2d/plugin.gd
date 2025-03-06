@tool
extends EditorPlugin


func _enter_tree() -> void:
	Surface2D._Settings.create_project_settings()
	
	const DebuggerMenu: GDScript = preload("res://addons/surface_2d/debugger_menu.gd")
	add_tool_submenu_item("Surface2D Debugger...", DebuggerMenu.new())

	add_custom_type(
		"Surface2D", "Polygon2D",
		preload("res://addons/surface_2d/surface_2d.gd"),
		preload("res://addons/surface_2d/icon.svg")
	)


func _exit_tree() -> void:
	remove_custom_type("Surface2D")

	remove_tool_menu_item("Surface2D Debugger...")

	Surface2D._Settings.destroy_project_settings()

