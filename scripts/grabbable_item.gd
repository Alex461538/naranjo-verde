class_name GrabbableItem
extends Area2D

signal _grab_request(spot: Node2D);
signal _release_request;

@export var robable: bool = false;

var grabbed: bool = false;

func _is_grabbed():
	return grabbed

func _grab(grab_spot: Node2D):
	# Si me lo puedo robar, primero se lo quito al otro
	if grabbed and not robable:
		return
	elif robable:
		emit_signal("_release_request")
	grabbed = true
	emit_signal("_grab_request", grab_spot)

func _release():
	grabbed = false
	emit_signal("_release_request")
