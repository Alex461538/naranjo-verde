extends Node2D

func _remove_all_children():
	var children = get_children()
	for child in children:
		child.queue_free()

func _change_scene(path: String) -> void:
	var scene: Resource = ResourceLoader.load(path)
	_remove_all_children()
	add_child(scene.instantiate())

func queue_scene_change(path: String, use_iris = false) -> void:
	if not ResourceLoader.exists(path):
		printerr("The requested scene path does not exist: ", path)
		# Once any fading has ended
	HudManager.fading_finished.connect(func(was_fading_in: bool, _fading_name: String):
		if not was_fading_in:
			return;
		_change_scene(path)
		HudManager.fade_out(use_iris)
		, CONNECT_ONE_SHOT)
	HudManager.fade_in(use_iris)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
