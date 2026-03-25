extends SceneTree
## Scene builder — builds all scenes for Primordial
## Run: timeout 60 godot --headless --script scenes/build_all.gd

func _initialize() -> void:
	print("Building all scenes...")
	_build_enemy()
	_build_player()
	_build_hud()
	_build_combat_ui()
	_build_main()
	print("All scenes built!")
	quit(0)

func _build_player() -> void:
	print("  Building player.tscn...")
	var root := CharacterBody2D.new()
	root.name = "Player"
	root.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	root.add_to_group("player")
	root.collision_layer = 1  # Layer 1: player
	root.collision_mask = 2 | 8  # Detect layer 2 (enemies) + layer 4 (obstacles, bitmask 8)

	# Sprite — load individual creature image, script handles swapping on evolution
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	if ResourceLoader.exists("res://assets/img/sprite_pikaia.png"):
		sprite.texture = load("res://assets/img/sprite_pikaia.png")
		sprite.scale = Vector2(0.05, 0.05)
	else:
		sprite.texture = _make_placeholder_texture(16, 16, Color(0.85, 0.75, 0.65))
	root.add_child(sprite)

	# Collision
	var col := CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape := CircleShape2D.new()
	shape.radius = 10.0
	col.shape = shape
	root.add_child(col)

	# Script
	root.set_script(load("res://scripts/player_controller.gd"))

	_save_scene(root, "res://scenes/player.tscn")

func _build_enemy() -> void:
	print("  Building enemy.tscn...")
	var root := CharacterBody2D.new()
	root.name = "Enemy"
	root.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	root.collision_layer = 2  # Layer 2: enemies
	root.collision_mask = 8   # Enemies collide with obstacles (layer 4, bitmask 8)

	# Sprite — script handles loading correct texture per enemy type in setup()
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	if ResourceLoader.exists("res://assets/img/sprite_trilobite.png"):
		sprite.texture = load("res://assets/img/sprite_trilobite.png")
		sprite.scale = Vector2(0.06, 0.06)
	else:
		sprite.texture = _make_placeholder_texture(16, 16, Color(0.8, 0.3, 0.3))
	root.add_child(sprite)

	var col := CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape := CircleShape2D.new()
	shape.radius = 10.0
	col.shape = shape
	root.add_child(col)

	# Detection area for combat trigger — must detect player (layer 1)
	var area := Area2D.new()
	area.name = "DetectionArea"
	area.collision_layer = 4     # Put area on layer 3 (bitmask 4) — distinct from bodies
	area.collision_mask = 1      # Detects layer 1 (player bodies)
	area.monitoring = true
	area.monitorable = false

	var area_col := CollisionShape2D.new()
	area_col.name = "AreaShape"
	var area_shape := CircleShape2D.new()
	area_shape.radius = 20.0    # Bigger detection radius so it's easier to trigger
	area_col.shape = area_shape
	area.add_child(area_col)
	root.add_child(area)

	root.set_script(load("res://scripts/enemy_controller.gd"))

	_save_scene(root, "res://scenes/enemy.tscn")

func _build_hud() -> void:
	print("  Building hud.tscn...")
	var root := CanvasLayer.new()
	root.name = "HUD"
	root.layer = 10

	var panel := PanelContainer.new()
	panel.name = "HUDPanel"
	panel.anchors_preset = Control.PRESET_TOP_WIDE
	panel.custom_minimum_size = Vector2(0, 60)
	root.add_child(panel)

	var hbox := HBoxContainer.new()
	hbox.name = "HBox"
	panel.add_child(hbox)

	var creature_label := Label.new()
	creature_label.name = "CreatureLabel"
	creature_label.text = "Pikaia"
	creature_label.custom_minimum_size = Vector2(150, 0)
	hbox.add_child(creature_label)

	var hp_bar := ProgressBar.new()
	hp_bar.name = "HPBar"
	hp_bar.custom_minimum_size = Vector2(200, 20)
	hp_bar.max_value = 30
	hp_bar.value = 30
	hp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(hp_bar)

	var hp_label := Label.new()
	hp_label.name = "HPLabel"
	hp_label.text = "HP: 30/30"
	hp_label.custom_minimum_size = Vector2(100, 0)
	hbox.add_child(hp_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	var genes_label := Label.new()
	genes_label.name = "GenesLabel"
	genes_label.text = "EVO Genes: 0"
	genes_label.custom_minimum_size = Vector2(140, 0)
	hbox.add_child(genes_label)

	var era_label := Label.new()
	era_label.name = "EraLabel"
	era_label.text = "Era 1: Primordial Seas"
	hbox.add_child(era_label)

	root.set_script(load("res://scripts/hud_controller.gd"))

	_save_scene(root, "res://scenes/hud.tscn")

func _build_combat_ui() -> void:
	print("  Building combat_screen.tscn...")
	var root := CanvasLayer.new()
	root.name = "CombatScreen"
	root.layer = 20

	# Dark background overlay
	var bg := ColorRect.new()
	bg.name = "CombatBG"
	bg.color = Color(0.02, 0.05, 0.12, 0.95)
	bg.anchor_left = 0.0
	bg.anchor_top = 0.0
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.visible = false
	root.add_child(bg)

	var panel := PanelContainer.new()
	panel.name = "CombatPanel"
	panel.anchor_left = 0.05
	panel.anchor_top = 0.02
	panel.anchor_right = 0.95
	panel.anchor_bottom = 0.98
	panel.visible = false
	root.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.name = "MainLayout"
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	# Enemy section (top half)
	var enemy_section := VBoxContainer.new()
	enemy_section.name = "EnemySection"
	enemy_section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(enemy_section)

	var enemy_name := Label.new()
	enemy_name.name = "EnemyName"
	enemy_name.text = "Enemy"
	enemy_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_name.add_theme_font_size_override("font_size", 22)
	enemy_section.add_child(enemy_name)

	# Enemy portrait — TextureRect for real images
	var portrait_tex := TextureRect.new()
	portrait_tex.name = "EnemyPortraitTex"
	portrait_tex.custom_minimum_size = Vector2(256, 256)
	portrait_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_tex.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	portrait_tex.visible = false
	enemy_section.add_child(portrait_tex)

	# Fallback colored rect if no portrait
	var portrait := ColorRect.new()
	portrait.name = "EnemyPortrait"
	portrait.color = Color(0.8, 0.3, 0.3)
	portrait.custom_minimum_size = Vector2(128, 128)
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	enemy_section.add_child(portrait)

	var enemy_hp := ProgressBar.new()
	enemy_hp.name = "EnemyHPBar"
	enemy_hp.custom_minimum_size = Vector2(300, 20)
	enemy_hp.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	enemy_section.add_child(enemy_hp)

	# Combat log (middle)
	var log_label := RichTextLabel.new()
	log_label.name = "CombatLog"
	log_label.custom_minimum_size = Vector2(0, 120)
	log_label.bbcode_enabled = true
	log_label.scroll_following = true
	vbox.add_child(log_label)

	# Player HP (bottom)
	var player_hp := ProgressBar.new()
	player_hp.name = "PlayerHPBar"
	player_hp.custom_minimum_size = Vector2(400, 25)
	player_hp.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(player_hp)

	# Action buttons
	var actions := HBoxContainer.new()
	actions.name = "Actions"
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 15)
	vbox.add_child(actions)

	var fight_btn := Button.new()
	fight_btn.name = "FightBtn"
	fight_btn.text = "Fight"
	fight_btn.custom_minimum_size = Vector2(100, 40)
	actions.add_child(fight_btn)

	var abilities := VBoxContainer.new()
	abilities.name = "Abilities"
	actions.add_child(abilities)

	var escape_btn := Button.new()
	escape_btn.name = "EscapeBtn"
	escape_btn.text = "Escape"
	escape_btn.custom_minimum_size = Vector2(100, 40)
	actions.add_child(escape_btn)

	root.set_script(load("res://scripts/combat_ui_controller.gd"))

	_save_scene(root, "res://scenes/combat_screen.tscn")

func _build_main() -> void:
	print("  Building main.tscn...")
	var root := Node2D.new()
	root.name = "Main"

	# Camera
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.zoom = Vector2(2, 2)
	root.add_child(camera)

	# Ocean floor background — tile the ocean texture across the map
	var ocean_tex: Texture2D = null
	if ResourceLoader.exists("res://assets/img/ocean_tiles.png"):
		ocean_tex = load("res://assets/img/ocean_tiles.png")

	if ocean_tex:
		for tx in range(-2, 3):
			for ty in range(-2, 3):
				var tile := Sprite2D.new()
				tile.name = "OceanTile_%d_%d" % [tx + 2, ty + 2]
				tile.texture = ocean_tex
				tile.position = Vector2(tx * 512, ty * 512)
				tile.scale = Vector2(0.5, 0.5)
				root.add_child(tile)
	else:
		var ground := ColorRect.new()
		ground.name = "OceanFloor"
		ground.color = Color(0.08, 0.15, 0.3)
		ground.position = Vector2(-1000, -1000)
		ground.size = Vector2(2000, 2000)
		root.add_child(ground)

	# --- LEVEL GEOMETRY: rocks, coral, obstacles ---
	# Large rocks (collision obstacles)
	var rock_positions: Array = [
		Vector2(-180, -120), Vector2(200, 80), Vector2(-60, 250),
		Vector2(300, -200), Vector2(-300, 100), Vector2(150, -300),
		Vector2(-250, -280), Vector2(350, 250), Vector2(-400, 300),
		Vector2(100, 400), Vector2(-150, -400), Vector2(400, -100),
	]
	for i in range(rock_positions.size()):
		var rock := StaticBody2D.new()
		rock.name = "Rock_%d" % i
		rock.position = rock_positions[i]
		rock.collision_layer = 8  # Layer 4 (bitmask 8) — obstacles
		rock.collision_mask = 0

		var rock_shape := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = randf_range(12.0, 28.0)
		rock_shape.shape = shape
		rock.add_child(rock_shape)

		# Visual — procedural rock texture
		var rock_sprite := Sprite2D.new()
		var rock_size: int = int(shape.radius * 2.5)
		var rock_img := Image.create(rock_size, rock_size, false, Image.FORMAT_RGBA8)
		# Draw a filled circle for the rock
		var center: float = float(rock_size) / 2.0
		var r_sq: float = center * center * 0.85  # slightly smaller than image
		for px in range(rock_size):
			for py in range(rock_size):
				var dx: float = float(px) - center
				var dy: float = float(py) - center
				if dx * dx + dy * dy < r_sq:
					# Dark rock with slight color variation
					var noise_val: float = sin(float(px) * 0.3) * cos(float(py) * 0.4) * 0.03
					var base_r: float = 0.15 + noise_val + randf_range(-0.02, 0.02)
					var base_g: float = 0.13 + noise_val + randf_range(-0.02, 0.02)
					var base_b: float = 0.18 + noise_val + randf_range(-0.02, 0.02)
					rock_img.set_pixel(px, py, Color(base_r, base_g, base_b, 1.0))
				# else: stays transparent (default)
		rock_sprite.texture = ImageTexture.create_from_image(rock_img)
		rock_sprite.name = "RockSprite"
		rock.add_child(rock_sprite)
		root.add_child(rock)

	# Coral clusters — procedural pixel-art style sprites
	var coral_colors: Array = [
		Color(0.9, 0.3, 0.25),    # Red coral
		Color(1.0, 0.55, 0.15),   # Orange coral
		Color(0.9, 0.45, 0.55),   # Pink coral
		Color(0.3, 0.7, 0.4),     # Green seaweed
		Color(0.25, 0.55, 0.65),  # Blue-green algae
		Color(0.75, 0.7, 0.25),   # Yellow sponge
	]
	for i in range(35):
		var coral_color: Color = coral_colors[i % coral_colors.size()]
		var coral_sprite := Sprite2D.new()
		coral_sprite.name = "Coral_%d" % i

		# Generate a small procedural coral shape
		var cw: int = randi_range(8, 18)
		var ch: int = randi_range(12, 28)
		if randf() > 0.5:
			# Swap for wide flat shape
			var tmp: int = cw
			cw = ch
			ch = tmp
		var coral_img := Image.create(cw, ch, false, Image.FORMAT_RGBA8)
		# Fill with coral color, slight variation per pixel
		for px in range(cw):
			for py in range(ch):
				# Taper toward top for branch-like shape
				var width_at_y: float = float(cw) * (0.5 + 0.5 * float(ch - py) / float(ch))
				var center_x: float = float(cw) / 2.0
				if abs(float(px) - center_x) < width_at_y / 2.0:
					var vary: float = randf_range(-0.06, 0.06)
					coral_img.set_pixel(px, py, Color(
						clampf(coral_color.r + vary, 0.0, 1.0),
						clampf(coral_color.g + vary, 0.0, 1.0),
						clampf(coral_color.b + vary, 0.0, 1.0),
						1.0
					))

		coral_sprite.texture = ImageTexture.create_from_image(coral_img)
		coral_sprite.position = Vector2(randf_range(-500, 500), randf_range(-500, 500))

		# Don't place on rocks
		var too_close: bool = false
		for rp in rock_positions:
			if coral_sprite.position.distance_to(rp) < 40.0:
				too_close = true
				break
		if not too_close:
			root.add_child(coral_sprite)

	# Thermal vents — bright glowing circles
	for i in range(5):
		var vent_sprite := Sprite2D.new()
		vent_sprite.name = "Vent_%d" % i
		var vent_size: int = randi_range(6, 12)
		var vent_img := Image.create(vent_size, vent_size, false, Image.FORMAT_RGBA8)
		var vent_center: float = float(vent_size) / 2.0
		for px in range(vent_size):
			for py in range(vent_size):
				var dist: float = Vector2(float(px), float(py)).distance_to(Vector2(vent_center, vent_center))
				if dist < vent_center:
					var glow: float = 1.0 - dist / vent_center
					vent_img.set_pixel(px, py, Color(1.0, 0.5 * glow + 0.3, 0.1 * glow, glow * 0.9))
		vent_sprite.texture = ImageTexture.create_from_image(vent_img)
		vent_sprite.position = Vector2(randf_range(-400, 400), randf_range(-400, 400))
		root.add_child(vent_sprite)

	# Player instance
	var player_scene: PackedScene = load("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	player.name = "Player"
	player.position = Vector2(0, 0)
	root.add_child(player)

	# Enemy spawner
	var spawner := Node2D.new()
	spawner.name = "EnemySpawner"
	spawner.set_script(load("res://scripts/enemy_spawner.gd"))
	root.add_child(spawner)

	# Audio players — BGM with looping
	var bgm := AudioStreamPlayer.new()
	bgm.name = "BGM"
	bgm.bus = &"Master"
	bgm.volume_db = -10.0
	bgm.autoplay = true
	if ResourceLoader.exists("res://assets/audio/ocean_ambient.wav"):
		bgm.stream = load("res://assets/audio/ocean_ambient.wav")
	root.add_child(bgm)

	# SFX player for one-shot sounds (AudioManager autoload handles this too)
	var sfx := AudioStreamPlayer.new()
	sfx.name = "SFX"
	sfx.bus = &"Master"
	root.add_child(sfx)

	# HUD
	var hud_scene: PackedScene = load("res://scenes/hud.tscn")
	var hud = hud_scene.instantiate()
	hud.name = "HUD"
	root.add_child(hud)

	# Combat screen
	var combat_scene: PackedScene = load("res://scenes/combat_screen.tscn")
	var combat_ui = combat_scene.instantiate()
	combat_ui.name = "CombatScreen"
	root.add_child(combat_ui)

	# Main script that starts the game
	root.set_script(load("res://scripts/main_scene.gd"))

	_save_scene(root, "res://scenes/main.tscn")

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _make_placeholder_texture(w: int, h: int, color: Color) -> ImageTexture:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)

func _save_scene(root: Node, path: String) -> void:
	set_owner_on_new_nodes(root, root)
	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err != OK:
		push_error("Pack failed for %s: %s" % [path, str(err)])
		return
	err = ResourceSaver.save(packed, path)
	if err != OK:
		push_error("Save failed for %s: %s" % [path, str(err)])
		return
	print("    Saved: %s" % path)

func set_owner_on_new_nodes(node: Node, scene_owner: Node) -> void:
	for child in node.get_children():
		child.owner = scene_owner
		if child.scene_file_path.is_empty():
			set_owner_on_new_nodes(child, scene_owner)
