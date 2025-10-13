extends CanvasLayer

@onready var fading_player = $FadingAnimPlayer;
@onready var dialog_player = $DialogAnimPlayer;

@onready var msg_box_label = %msg_box_label;

@onready var mosaic = $mosaic;
@onready var iris = $iris;
@onready var fade = $fade;

@export var MOSAIC_TIME = 1.0;
@export var IRIS_TIME = 0.0;
@export var FADE_TIME = 1.0;

var last_faded_in = false;

var valid_lang_codes: Dictionary = { "en": 0, "es": 0, "hy": 0 };
var dialog_lang_code = "es";
var dialog_data;

signal fading_finished(was_faded_in: bool, fading_name: String);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Select any valid language
	if valid_lang_codes.has(OS.get_locale_language()):
		dialog_lang_code = OS.get_locale_language();
	# Load the dialog data
	dialog_data = JSON.parse_string( FileAccess.get_file_as_string("res://dialogues.json"))
	# Open the theater curtain
	fading_player.animation_finished.connect(_on_fading_finished);
	HudManager.fade_out(true);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	mosaic.material.set_shader_parameter("time", MOSAIC_TIME);
	iris.material.set_shader_parameter("time", IRIS_TIME);
	fade.material.set_shader_parameter("time", FADE_TIME);

func _on_fading_finished(anim_name: String):
	fading_finished.emit(last_faded_in, anim_name);

func fade_in(use_iris = false):
	if fading_player.is_playing():
		return;
	last_faded_in = true;
	if use_iris:
		IRIS_TIME = 0.0;
		MOSAIC_TIME = 0.0;
		FADE_TIME = 0.0;
		fading_player.play("iris_close");
	else:
		MOSAIC_TIME = 0.0;
		FADE_TIME = 0.0;
		IRIS_TIME = 0.0;
		fading_player.play("fade_dark");

func fade_out(use_iris = false):
	if fading_player.is_playing():
		return;
	last_faded_in = false;
	if use_iris:
		IRIS_TIME = 1.0;
		MOSAIC_TIME = 0.0;
		FADE_TIME = 0.0;
		fading_player.play_backwards("iris_close");
	else:
		MOSAIC_TIME = 1.0;
		FADE_TIME = 1.0;
		IRIS_TIME = 0.0;
		fading_player.play_backwards("fade_dark");

func show_dialog(dialog_name: String):
	# Check for dialog data
	if not dialog_data:
		printerr("Don't be a mf and load the dialog data correctly")
		return;
	var dialog : Dictionary;
	# Check for the requested dialog
	if not dialog_data.has(dialog_name):
		dialog = dialog_data["!what"];
		printerr("Trying to access dialog named: ", dialog_name)
	else:
		dialog = dialog_data[dialog_name]
	# Select the correct translated sequence
	if dialog.has("text") and dialog["text"].has(dialog_lang_code):
		msg_box_label.text = dialog["text"][dialog_lang_code];
	else:
		msg_box_label.text = "[Err] No translation for this: " + dialog_name
	# Open the dialog
	dialog_player.play("open_box")
