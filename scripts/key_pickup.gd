extends RigidBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape

@onready var game_manager: Node = %GameManager

var grab_spot: Node2D = null;

func _physics_process(_delta: float) -> void:
	if grab_spot:
		global_position = grab_spot.global_position

func _on_grabbable_item_grab_request(spot: Node2D) -> void:
	collision_shape.set_deferred("disabled", true)
	set_freeze_enabled(true)
	grab_spot = spot

func _on_grabbable_item_release_request() -> void:
	collision_shape.set_deferred("disabled", false)
	set_freeze_enabled(false)
	grab_spot = null
