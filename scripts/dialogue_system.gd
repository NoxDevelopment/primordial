extends CanvasLayer
## res://scripts/dialogue_system.gd — Professor Helix dialogue boxes

signal dialogue_finished()

var _panel: PanelContainer = null
var _portrait: TextureRect = null
var _name_label: Label = null
var _text_label: RichTextLabel = null
var _continue_label: Label = null
var _queue: Array[Dictionary] = []  # [{speaker, text, portrait_path}]
var _is_showing: bool = false
var _char_index: int = 0
var _full_text: String = ""
var _char_timer: float = 0.0
var _chars_per_sec: float = 40.0

func _ready() -> void:
	layer = 35
	_build_ui()
	visible = false

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.name = "DialoguePanel"
	_panel.anchor_left = 0.05
	_panel.anchor_top = 0.65
	_panel.anchor_right = 0.95
	_panel.anchor_bottom = 0.95
	add_child(_panel)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	_panel.add_child(hbox)

	# Portrait
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(100, 100)
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hbox.add_child(_portrait)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	_name_label = Label.new()
	_name_label.text = "Professor Helix"
	_name_label.add_theme_font_size_override("font_size", 18)
	_name_label.modulate = Color(1.0, 0.9, 0.5)
	vbox.add_child(_name_label)

	_text_label = RichTextLabel.new()
	_text_label.bbcode_enabled = false
	_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text_label.fit_content = true
	vbox.add_child(_text_label)

	_continue_label = Label.new()
	_continue_label.text = "[SPACE to continue]"
	_continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_continue_label.modulate = Color(0.6, 0.6, 0.7)
	_continue_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(_continue_label)

func show_dialogue(lines: Array[Dictionary]) -> void:
	_queue = lines
	_show_next()

func _show_next() -> void:
	if _queue.is_empty():
		visible = false
		_is_showing = false
		GameManager.state = GameManager.GameState.OVERWORLD
		dialogue_finished.emit()
		return

	var line: Dictionary = _queue.pop_front()
	_full_text = line.get("text", "")
	_char_index = 0
	_text_label.text = ""

	if _name_label:
		_name_label.text = line.get("speaker", "Professor Helix")

	var portrait_path: String = line.get("portrait", "res://assets/img/professor_helix.png")
	if _portrait and ResourceLoader.exists(portrait_path):
		_portrait.texture = load(portrait_path)

	visible = true
	_is_showing = true
	_continue_label.visible = false
	GameManager.state = GameManager.GameState.CUTSCENE

func _process(delta: float) -> void:
	if not _is_showing:
		return

	# Typewriter effect
	if _char_index < _full_text.length():
		_char_timer += delta
		while _char_timer >= 1.0 / _chars_per_sec and _char_index < _full_text.length():
			_char_timer -= 1.0 / _chars_per_sec
			_char_index += 1
			_text_label.text = _full_text.substr(0, _char_index)
	else:
		_continue_label.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if not _is_showing:
		return
	if event.is_action_pressed("confirm") or event.is_action_pressed("interact"):
		if _char_index < _full_text.length():
			# Skip typewriter, show full text
			_char_index = _full_text.length()
			_text_label.text = _full_text
			_continue_label.visible = true
		else:
			_show_next()
		get_viewport().set_input_as_handled()
