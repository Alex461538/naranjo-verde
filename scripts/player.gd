extends CharacterBody2D;

@export var dust_scene: PackedScene  # drag Dust.tscn here in the editor
@onready var dust_timer: Timer = $DustTimer

const MAX_WALK_SPEED: float = 75;
const MAX_RUN_SPEED: float = 125;
const MAX_P_SPEED: float = 155;
const P_METER_MIN_SPEED: float = 80;

const WALK_ACCEL = 337.5;
const RUN_ACCEL = 337.5;
const STOP_DECEL = 225.0;
const WALK_DECEL = 562.5;
const RUN_DECEL = 562.5;

const JUMP_BASE_SPEED = 248;
const JUMP_SPEED_X_INCR = 9.375;

const P_METER_MAX = 0x70;

var P_METER: float = 0;

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity");

var direction: float = 0;

func _physics_process(delta: float) -> void:
	direction = Input.get_axis("ui_left", "ui_right")
	
	_handle_gravity(delta);
	_handle_jumping(delta);
	_handle_p_meter(delta);
	_handle_walking(delta);

	move_and_slide()

func _handle_gravity(delta: float) -> void:
	var g: float = 0;
	
	if not Input.is_action_pressed("jump"):
		g = 1350
	else:
		g = 675
	
	velocity.y += g * delta;

func _held_run_and_grab() -> bool:
	return Input.is_action_pressed("run_and_grab");

func _holding_forwards_direction() -> bool:
	return (velocity.x == 0 and direction != 0) or sign(direction) == sign(velocity.x);

func _holding_backwards_direction() -> bool:
	return sign(direction) != 0 and sign(direction) != sign(velocity.x);

func _decelerate(amount: float, delta: float) -> void:
	velocity.x = sign(velocity.x) * max(0, abs(velocity.x) - amount * delta );

func _accelerate(amount: float, _max_speed: float, delta: float) -> void:
	if velocity.x == 0:
		velocity.x = sign(direction) * ( abs(velocity.x) + amount * delta );
	else:
		velocity.x = sign(velocity.x) * ( abs(velocity.x) + amount * delta );

func _is_ducking_on_floor():
	return Input.get_axis("ui_down", "ui_up") < 0 and is_on_floor();

func _handle_p_meter(delta: float):
	if abs(velocity.x) >= P_METER_MIN_SPEED:
		if is_on_floor() and _held_run_and_grab():
			P_METER += 120 * delta
		else:
			P_METER -= 60 * delta
	else:
		P_METER -= 60 * delta;
	P_METER = clamp(P_METER, 0, P_METER_MAX)

func _get_max_speed():
	var base_max: float = 0;
	
	if P_METER >= P_METER_MAX:
		base_max = MAX_P_SPEED;
	elif _held_run_and_grab():
		base_max = MAX_RUN_SPEED
	else:
		base_max = MAX_WALK_SPEED
	
	return base_max

func _get_accel():
	var base_acc: float = 0;
	
	if _held_run_and_grab():
		base_acc = RUN_ACCEL
	else:
		base_acc = WALK_ACCEL
	
	return base_acc

func _get_decel():
	var base_acc: float = 0;
	
	if _held_run_and_grab():
		base_acc = RUN_DECEL
	else:
		base_acc = WALK_DECEL
	
	return base_acc

func _handle_jumping(_delta: float):
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = -( JUMP_BASE_SPEED + floor(abs(velocity.x / 30)) * JUMP_SPEED_X_INCR );

func _handle_walking(delta):
	var max_speed: float = _get_max_speed();
	var accel: float = _get_accel();
	var decel: float = _get_decel();
	var force_decel: float = STOP_DECEL;
	
	# Para lanzamientos de tubos, mantiene la velocidad actual
	if direction == 0 and not is_on_floor():
		return;
	
	if _is_ducking_on_floor() or not direction:
		_decelerate(force_decel, delta);
		return
	
	if abs(velocity.x) < abs(max_speed) and _holding_forwards_direction():
		_accelerate(accel, max_speed, delta);
		return
	
	if _holding_backwards_direction():
		_decelerate(decel, delta);
		if is_on_floor():
			_spawn_dust();
		return
	
	if abs(velocity.x) >= abs(max_speed) and (is_on_floor() or _holding_forwards_direction()):
		_decelerate(force_decel, delta);
		return

func _spawn_dust():
	if dust_timer.is_stopped():  # only if timer finished
		var dust = dust_scene.instantiate()
		add_sibling(dust)
		dust.global_position = global_position + Vector2(0, 0)  # offset below feet
		dust_timer.start()
