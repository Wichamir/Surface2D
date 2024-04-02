extends Node


const PARTICLES_DIR := "res://demo/particles"

@onready var particles_container: Node2D = %ParticlesContainer
@onready var particles_list: ItemList = %ParticlesList


func _ready() -> void:
	for path in DirAccess.get_files_at(PARTICLES_DIR):
		particles_list.add_item(path)
	particles_list.select(0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var path: String = PARTICLES_DIR + '/' + particles_list.get_item_text(particles_list.get_selected_items()[0])
			spawn_particles(path, event.position)
	elif event is InputEventKey:
		if event.keycode == KEY_SPACE:
			get_tree().call_group("surfaces", "clear")


func spawn_particles(path: String, at: Vector2) -> void:
	var instance: GPUParticles2D = load(path).instantiate()
	instance.global_position = at
	instance.restart()
	instance.finished.connect(instance.queue_free)
	particles_container.add_child(instance)
