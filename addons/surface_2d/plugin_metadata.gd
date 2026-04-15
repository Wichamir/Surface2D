## Helper static class for managing project metadata for the plugin.
extends RefCounted

const METADATA_FILEPATH: String = "res://.godot/editor/project_metadata.cfg"

static var visible_bounding_rects: bool:
    set(value): set_project_metadata("Surface2D", "visible_bounding_rects", value)
    get: return get_project_metadata("Surface2D", "visible_bounding_rects", false)
static var visible_polygon_shapes: bool:
    set(value): set_project_metadata("Surface2D", "visible_polygon_shapes", value)
    get: return get_project_metadata("Surface2D", "visible_polygon_shapes", false)


static func set_project_metadata(section: String, key: String, value: Variant) -> void:
    if not OS.is_debug_build():
        return # Don't save metadata in debug builds
    
    if not FileAccess.file_exists(METADATA_FILEPATH):
        printerr(
            "[Surface2D] Project metadata file not found: %s."
            % METADATA_FILEPATH)
        return

    #if Engine.is_editor_hint():
        #var editor_settings := EditorInterface.get_editor_settings()
        #editor_settings.set_project_metadata(section, key, value)

    var file: ConfigFile = ConfigFile.new()
    file.load(METADATA_FILEPATH)
    file.set_value(section, key, value)
    file.save(METADATA_FILEPATH)


static func get_project_metadata(section: String, key: String, default: Variant) -> Variant:
    if not OS.is_debug_build():
        return default # Use defaults in debug builds
    
    if not FileAccess.file_exists(METADATA_FILEPATH):
        printerr(
            "[Surface2D] Project metadata file not found: %s"
            % METADATA_FILEPATH)
        return default

    var file: ConfigFile = ConfigFile.new()
    file.load(METADATA_FILEPATH)
    return file.get_value(section, key, default)