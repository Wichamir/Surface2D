@tool
@icon("res://addons/surface_2d/icon.svg")
## Surface for drawing decals in 2D.
class_name Surface2D extends Polygon2D


const DEFAULT_CULL_MASK := 1 << 1
const DEFAULT_COLOR := Color.WHITE
const EDITOR_COLOR := Color(Color.WHITE, .2)


## Defines if the surface gets updated.
@export var enabled: bool = true:
	set = _set_enabled

## Defines what canvas items should be drawn on the surface based on their visibility_layer.
## This mask should not overlap with visibility_layer of the surface itself.
@export_flags_2d_render var cull_mask: int = DEFAULT_CULL_MASK:
	set = _set_cull_mask

@export_group("Debug")
@export var display_debug_rect: bool = false
@export var debug_rect_color: Color = Color.WHITE
@export var display_debug_polygon: bool = false
@export var debug_polygon_color: Color = Color.WHITE
@export_group("")


## Clears the surface.
func clear() -> void:
	_subviewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE


# inner workings below

var _subviewport: SubViewport
var _camera: Camera2D


func _init() -> void:
	if Engine.is_editor_hint():
		color = EDITOR_COLOR


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	# some safety checks
	if polygon.is_empty():
		push_error("There is no surface to draw on. Add points to create a polygon.")
		enabled = false
		return
	
	if cull_mask == 0 and enabled:
		push_warning("cull_mask of the surface is zero. It will not draw anything.")
	
	if cull_mask & visibility_layer != 0 and enabled:
		push_error("cull_mask and visibility_layer of the surface overlap. Surface will try to draw itself.")
		enabled = false
		return
	
	set_notify_transform(true)
	
	var subviewport_rect: Rect2 = _find_subviewport_rect()
	
	# create subviewport
	_subviewport = SubViewport.new()
	_subviewport.world_2d = get_viewport().find_world_2d()
	_subviewport.size = subviewport_rect.size
	_subviewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	_subviewport.transparent_bg = true
	_subviewport.disable_3d = true
	_subviewport.canvas_cull_mask = cull_mask
	add_child(_subviewport)
	
	# create camera
	_camera = Camera2D.new()
	_camera.ignore_rotation = false
	_camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	_subviewport.add_child(_camera)
	
	# create texture
	texture_offset = -subviewport_rect.position
	texture = _subviewport.get_texture()
	
	# reset color
	color = DEFAULT_COLOR
	
	# debugging
	if display_debug_rect:
		_spawn_debug_rect(subviewport_rect)
	if display_debug_polygon:
		_spawn_debug_polygon()


func _notification(what: int) -> void:
	if Engine.is_editor_hint():
		return
	
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			_update_camera()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	
	if cull_mask == 0 and enabled:
		warnings.push_back("cull_mask of the surface is zero. It will not draw anything.")
	
	if cull_mask & visibility_layer != 0 and enabled:
		warnings.push_back("cull_mask and visibility_layer of the surface overlap. Surface will try to draw itself.")
	
	return warnings


func _set_enabled(value: bool) -> void:
	enabled = value
	
	update_configuration_warnings()
	
	if Engine.is_editor_hint():
		return
	
	_update_subviewport_update_mode()


func _set_cull_mask(value: int) -> void:
	cull_mask = value
	
	update_configuration_warnings()
	
	if Engine.is_editor_hint():
		return
	
	_update_subviewport_cull_mask()


func _update_camera() -> void:
	if not is_instance_valid(_camera): return
	_camera.global_position = global_position + global_transform.basis_xform(_find_subviewport_rect().position)
	_camera.global_rotation = global_rotation
	_camera.zoom = Vector2.ONE / global_scale


func _update_subviewport_update_mode() -> void:
	var update_mode_updater :=\
		func():
			if not is_instance_valid(_subviewport): return
			_subviewport.render_target_update_mode = [
				SubViewport.UPDATE_DISABLED,
				SubViewport.UPDATE_WHEN_VISIBLE
			][int(enabled)]
	
	if is_node_ready():
		update_mode_updater.call()
	else:
		ready.connect(update_mode_updater)


func _update_subviewport_cull_mask() -> void:
	var cull_mask_updater :=\
		func():
			if not is_instance_valid(_subviewport): return
			_subviewport.canvas_cull_mask = cull_mask
	
	if is_node_ready():
		cull_mask_updater.call()
	else:
		ready.connect(cull_mask_updater)


func _find_subviewport_rect() -> Rect2:
	var points := Array(polygon)
	
	assert(not points.is_empty())
	
	var rect_position := Vector2(
		points.map(func(p): return p.x).min(),
		points.map(func(p): return p.y).min()
	)
	
	var rect_size := Vector2(
		points.map(func(p): return p.x).max() - rect_position.x,
		points.map(func(p): return p.y).max() - rect_position.y
	)
	
	return Rect2(
		rect_position,
		rect_size
	)


func _spawn_debug_rect(base: Rect2) -> void:
	var rect := ReferenceRect.new()
	rect.editor_only = false
	rect.border_color = debug_rect_color
	rect.border_width = 2
	rect.position = base.position
	rect.size = base.size
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)


func _spawn_debug_polygon() -> void:
	var poly := Polygon2D.new()
	poly.polygon = polygon
	poly.color = debug_polygon_color
	poly.show_behind_parent = true
	add_child(poly)
