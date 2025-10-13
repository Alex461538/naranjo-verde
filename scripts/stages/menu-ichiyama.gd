extends Node2D

@export_file("*.tscn") var scene_path: String;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_anything_pressed():
		SceneManager.queue_scene_change(scene_path, true)
