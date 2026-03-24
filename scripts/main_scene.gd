extends Node2D
## res://scripts/main_scene.gd — Main scene: camera, water overlay, intro tutorial, game flow

var _camera: Camera2D = null
var _player: CharacterBody2D = null
var _evo_chart: CanvasLayer = null
var _bgm: AudioStreamPlayer = null
var _dialogue: Node = null
var _water_overlay: Node = null
var _intro_done: bool = false
var _cam_time: float = 0.0

func _ready() -> void:
	_camera = get_node_or_null("Camera2D")
	_player = get_node_or_null("Player")
	_bgm = get_node_or_null("BGM")

	# Loop BGM
	if _bgm:
		_bgm.finished.connect(_on_bgm_finished)

	# Create water overlay
	var water_script: GDScript = load("res://scripts/water_overlay.gd")
	_water_overlay = CanvasLayer.new()
	_water_overlay.set_script(water_script)
	_water_overlay.name = "WaterOverlay"
	add_child(_water_overlay)

	# Create evolution chart UI
	var chart_script: GDScript = load("res://scripts/evolution_chart_controller.gd")
	_evo_chart = CanvasLayer.new()
	_evo_chart.set_script(chart_script)
	_evo_chart.name = "EvolutionChart"
	add_child(_evo_chart)

	# Create dialogue system
	var dialogue_script: GDScript = load("res://scripts/dialogue_system.gd")
	_dialogue = CanvasLayer.new()
	_dialogue.set_script(dialogue_script)
	_dialogue.name = "DialogueSystem"
	add_child(_dialogue)

	# Start game
	GameManager.start_game()

	# Wire story system to dialogue
	Story.set_dialogue_node(_dialogue)

	# Connect signals
	GameManager.game_over.connect(_on_game_over)
	GameManager.creature_evolved.connect(_on_evolved)
	GameManager.combat_finished.connect(_on_combat_finished)
	GameManager.era_changed.connect(_on_era_changed)

	# Show intro tutorial
	call_deferred("_show_intro")

func _show_intro() -> void:
	var lines: Array[Dictionary] = [
		{
			"speaker": "Professor Helix",
			"text": "Ah, splendid! A new life form! I am Professor Helix — I've been observing evolution on this planet for 500 million years from inside my fossilized shell.",
			"portrait": "res://assets/img/professor_helix.png",
		},
		{
			"speaker": "Professor Helix",
			"text": "You are a Pikaia — one of Earth's very first chordates. Quite humble, yes, but that notochord running down your back? That's the precursor to every spine on Earth. Including, eventually, yours.",
			"portrait": "res://assets/img/professor_helix.png",
		},
		{
			"speaker": "Professor Helix",
			"text": "Here's how evolution works: defeat other creatures to earn EVO Genes. Then press ESC to open your Evolution Chart and spend those genes on four stats:",
			"portrait": "res://assets/img/professor_helix.png",
		},
		{
			"speaker": "Professor Helix",
			"text": "ATTACK — raw combat power. WISDOM — special abilities and escape chance. VITALITY — maximum health. ENDURANCE — defense and terrain resistance.",
			"portrait": "res://assets/img/professor_helix.png",
		},
		{
			"speaker": "Professor Helix",
			"text": "When any stat reaches its maximum, you'll EVOLVE into a new creature! The stat you max determines WHICH creature. The highest-cap stat leads to the main evolutionary line — other stats branch into alternate forms.",
			"portrait": "res://assets/img/professor_helix.png",
		},
		{
			"speaker": "Professor Helix",
			"text": "But beware — some branches are dead ends. Not every path leads forward. That's natural selection for you! Now swim out there and start evolving. The Cambrian seas await!",
			"portrait": "res://assets/img/professor_helix.png",
		},
	]
	if _dialogue and _dialogue.has_method("show_dialogue"):
		_dialogue.show_dialogue(lines)
		_dialogue.dialogue_finished.connect(_on_intro_done, CONNECT_ONE_SHOT)

func _on_intro_done() -> void:
	_intro_done = true

func _process(delta: float) -> void:
	# Camera follows player with slight underwater sway
	_cam_time += delta
	if _camera and _player:
		var target: Vector2 = _player.global_position
		# Gentle camera sway for underwater feel
		target.x += sin(_cam_time * 0.5) * 1.5
		target.y += cos(_cam_time * 0.7) * 1.0
		_camera.global_position = _camera.global_position.lerp(target, 5.0 * delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if GameManager.state == GameManager.GameState.OVERWORLD:
			if _evo_chart and _evo_chart.has_method("open"):
				_evo_chart.open()
			get_viewport().set_input_as_handled()

func _on_bgm_finished() -> void:
	if _bgm:
		_bgm.play()

func _on_game_over(reason: String) -> void:
	var overlay := CanvasLayer.new()
	overlay.layer = 50
	var panel := ColorRect.new()
	panel.color = Color(0, 0, 0, 0.85)
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
	# Story system handles milestone narration via story_system.gd
	# For non-milestone evolutions, show a brief notification
	if not Story.has_triggered(new_id) and not Story.has_triggered("first_fish") or true:
		var new_creature: Dictionary = CreatureDB.get_creature(new_id)
		if new_creature.is_empty():
			return
		# Only show generic evolution popup if Story didn't already handle it
		# (Story triggers on specific creature IDs, this catches the rest)
		var event_ids: Array = ["haikouichthys", "climatius", "cladoselache", "dunkleosteus", "eusthenopteron", "tiktaalik"]
		if new_id not in event_ids:
			if _dialogue and _dialogue.has_method("show_dialogue"):
				var lines: Array[Dictionary] = [{
					"speaker": "Professor Helix",
					"text": "You've evolved into %s (%s)! %s" % [
						new_creature.get("name", "Unknown"),
						new_creature.get("scientific_name", ""),
						new_creature.get("description", ""),
					],
					"portrait": "res://assets/img/professor_helix.png",
				}]
				_dialogue.show_dialogue(lines)

func _on_era_changed(era: int) -> void:
	# Swap tileset based on era
	var tileset_map: Dictionary = {
		1: "res://assets/img/ocean_tiles.png",
		2: "res://assets/img/ocean_tiles.png",
		3: "res://assets/img/ocean_tiles.png",
		4: "res://assets/img/swamp_tiles.png",
		5: "res://assets/img/desert_tiles.png",
		6: "res://assets/img/desert_tiles.png",
		7: "res://assets/img/forest_tiles.png",
		8: "res://assets/img/forest_tiles.png",
		9: "res://assets/img/forest_tiles.png",
		10: "res://assets/img/iceage_tiles.png",
	}
	var tileset_path: String = tileset_map.get(era, "res://assets/img/ocean_tiles.png")
	if ResourceLoader.exists(tileset_path):
		var new_tex: Texture2D = load(tileset_path)
		# Update all ocean tile sprites
		for child in get_children():
			if child.name.begins_with("OceanTile_") and child is Sprite2D:
				child.texture = new_tex

	# Swap water overlay color based on era
	if _water_overlay and _water_overlay.has_method("_ready"):
		var overlay: ColorRect = _water_overlay.get_node_or_null("WaterTint")
		if overlay:
			match era:
				1, 2, 3: overlay.color = Color(0.05, 0.15, 0.35, 0.18)  # Blue underwater
				4: overlay.color = Color(0.05, 0.15, 0.05, 0.12)  # Green swamp mist
				5, 6: overlay.color = Color(0.15, 0.08, 0.02, 0.10)  # Orange desert haze
				7, 8: overlay.color = Color(0.02, 0.10, 0.02, 0.08)  # Light forest green
				9, 10: overlay.color = Color(0.10, 0.12, 0.18, 0.12)  # Cold blue-grey

func _on_combat_finished(victory: bool) -> void:
	if victory and _player and _player.has_signal("hp_changed"):
		_player.hp_changed.emit(GameManager.player_hp, GameManager.player_max_hp)
