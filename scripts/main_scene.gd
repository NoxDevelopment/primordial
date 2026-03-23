extends Node2D
## res://scripts/main_scene.gd — Main scene: camera follow, evolution chart toggle, game over

var _camera: Camera2D = null
var _player: CharacterBody2D = null
var _evo_chart: CanvasLayer = null
var _bgm: AudioStreamPlayer = null

func _ready() -> void:
	_camera = get_node_or_null("Camera2D")
	_player = get_node_or_null("Player")
	_bgm = get_node_or_null("BGM")

	# Loop BGM when it finishes
	if _bgm:
		_bgm.finished.connect(_on_bgm_finished)

	# Create evolution chart UI (not in .tscn — built dynamically)
	var chart_script: GDScript = load("res://scripts/evolution_chart_controller.gd")
	_evo_chart = CanvasLayer.new()
	_evo_chart.set_script(chart_script)
	_evo_chart.name = "EvolutionChart"
	add_child(_evo_chart)

	# Start the game
	GameManager.start_game()

	# Connect signals
	GameManager.game_over.connect(_on_game_over)
	GameManager.creature_evolved.connect(_on_evolved)
	GameManager.combat_finished.connect(_on_combat_finished)

func _process(_delta: float) -> void:
	if _camera and _player:
		_camera.global_position = _player.global_position

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if GameManager.state == GameManager.GameState.OVERWORLD:
			if _evo_chart:
				_evo_chart.open()
			get_viewport().set_input_as_handled()

func _on_game_over(reason: String) -> void:
	# Show game over screen
	var overlay := CanvasLayer.new()
	overlay.layer = 50

	var panel := ColorRect.new()
	panel.color = Color(0, 0, 0, 0.8)
	panel.anchors_preset = Control.PRESET_FULL_RECT
	overlay.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.anchors_preset = Control.PRESET_CENTER
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "EXTINCTION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.modulate = Color(1, 0.3, 0.3)
	vbox.add_child(title)

	var story := RichTextLabel.new()
	story.text = reason
	story.custom_minimum_size = Vector2(600, 200)
	story.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(story)

	var restart_btn := Button.new()
	restart_btn.text = "Try Again"
	restart_btn.custom_minimum_size = Vector2(150, 40)
	restart_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	restart_btn.pressed.connect(func(): get_tree().reload_current_scene())
	vbox.add_child(restart_btn)

	add_child(overlay)

func _on_evolved(old_id: String, new_id: String) -> void:
	var new_creature: Dictionary = CreatureDB.get_creature(new_id)
	var creature_name: String = new_creature.get("name", "Unknown")
	var sci_name: String = new_creature.get("scientific_name", "")

	# Show evolution notification
	var notify := CanvasLayer.new()
	notify.layer = 40

	var panel := PanelContainer.new()
	panel.anchors_preset = Control.PRESET_CENTER
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	notify.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "EVOLUTION!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.modulate = Color(1, 0.9, 0.3)
	vbox.add_child(title)

	var name_label := Label.new()
	name_label.text = "You evolved into %s!" % creature_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_label)

	var sci_label := Label.new()
	sci_label.text = sci_name
	sci_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sci_label.modulate = Color(0.7, 0.7, 0.8)
	vbox.add_child(sci_label)

	var desc := Label.new()
	desc.text = new_creature.get("description", "")
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(500, 0)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc)

	add_child(notify)

	# Auto-dismiss after 4 seconds
	var timer := get_tree().create_timer(4.0)
	timer.timeout.connect(func(): notify.queue_free())

func _on_bgm_finished() -> void:
	if _bgm:
		_bgm.play()

func _on_combat_finished(victory: bool) -> void:
	if victory:
		if _player and _player.has_signal("hp_changed"):
			_player.hp_changed.emit(GameManager.player_hp, GameManager.player_max_hp)
