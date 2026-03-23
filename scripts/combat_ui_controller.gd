extends CanvasLayer
## res://scripts/combat_ui_controller.gd — Combat screen UI and input handling

var combat: Node = null  # CombatSystem node
var _enemy_portrait: TextureRect = null
var _enemy_portrait_fallback: ColorRect = null
var _enemy_name_label: Label = null
var _enemy_hp_bar: ProgressBar = null
var _player_hp_bar: ProgressBar = null
var _combat_log_label: RichTextLabel = null
var _fight_btn: Button = null
var _special_btn: Button = null
var _escape_btn: Button = null
var _abilities_container: VBoxContainer = null
var _panel: Control = null
var _bg: ColorRect = null

func _ready() -> void:
	_panel = get_node_or_null("CombatPanel")
	_bg = get_node_or_null("CombatBG")

	# Find UI elements recursively since node paths vary depending on containers
	if _panel:
		_enemy_portrait = _find_child_recursive(_panel, "EnemyPortraitTex") as TextureRect
		_enemy_portrait_fallback = _find_child_recursive(_panel, "EnemyPortrait") as ColorRect
		_enemy_name_label = _find_child_recursive(_panel, "EnemyName") as Label
		_enemy_hp_bar = _find_child_recursive(_panel, "EnemyHPBar") as ProgressBar
		_player_hp_bar = _find_child_recursive(_panel, "PlayerHPBar") as ProgressBar
		_combat_log_label = _find_child_recursive(_panel, "CombatLog") as RichTextLabel
		_fight_btn = _find_child_recursive(_panel, "FightBtn") as Button
		_escape_btn = _find_child_recursive(_panel, "EscapeBtn") as Button
		_abilities_container = _find_child_recursive(_panel, "Abilities") as VBoxContainer

	if _fight_btn:
		_fight_btn.pressed.connect(_on_fight)
	if _escape_btn:
		_escape_btn.pressed.connect(_on_escape)

	# Find or create combat system — load script directly since it's not an autoload
	var combat_script: GDScript = load("res://scripts/combat_system.gd")
	combat = Node.new()
	combat.set_script(combat_script)
	combat.name = "CombatSystem"
	add_child(combat)
	combat.combat_started.connect(_on_combat_started)
	combat.combat_ended.connect(_on_combat_ended)
	combat.player_hp_changed.connect(_on_player_hp_changed)
	combat.enemy_hp_changed.connect(_on_enemy_hp_changed)
	combat.combat_log.connect(_on_combat_log)
	combat.awaiting_player_input.connect(_on_awaiting_input)

	GameManager.combat_requested.connect(_on_combat_requested)
	hide_combat()

func hide_combat() -> void:
	if _panel:
		_panel.visible = false
	if _bg:
		_bg.visible = false

func show_combat() -> void:
	if _panel:
		_panel.visible = true
	if _bg:
		_bg.visible = true

func _on_combat_requested(enemy_data: Dictionary) -> void:
	show_combat()
	combat.start_combat(enemy_data, GameManager.player_hp)

func _on_combat_started(enemy_data: Dictionary) -> void:
	if _enemy_name_label:
		_enemy_name_label.text = enemy_data.get("name", "Unknown")

	# Load portrait texture if available
	var portrait_path: String = enemy_data.get("portrait", "")
	if portrait_path != "" and ResourceLoader.exists(portrait_path):
		var tex: Texture2D = load(portrait_path)
		if _enemy_portrait:
			_enemy_portrait.texture = tex
			_enemy_portrait.visible = true
		if _enemy_portrait_fallback:
			_enemy_portrait_fallback.visible = false
	else:
		if _enemy_portrait:
			_enemy_portrait.visible = false
		if _enemy_portrait_fallback:
			_enemy_portrait_fallback.color = enemy_data.get("color", Color.RED)
			_enemy_portrait_fallback.visible = true

	if _combat_log_label:
		_combat_log_label.text = ""
	_build_ability_buttons()
	_set_buttons_enabled(true)

func _on_combat_ended(victory: bool, evo_genes: int) -> void:
	_set_buttons_enabled(false)
	GameManager.player_hp = combat.get_player_hp()
	# Brief delay then close
	await get_tree().create_timer(1.5).timeout
	hide_combat()
	GameManager.end_combat(victory, evo_genes)

func _on_player_hp_changed(current: int, max_hp: int) -> void:
	if _player_hp_bar:
		_player_hp_bar.max_value = max_hp
		_player_hp_bar.value = current

func _on_enemy_hp_changed(current: int, max_hp: int) -> void:
	if _enemy_hp_bar:
		_enemy_hp_bar.max_value = max_hp
		_enemy_hp_bar.value = current

func _on_combat_log(text: String) -> void:
	if _combat_log_label:
		_combat_log_label.text += text + "\n"
		# Auto-scroll to bottom
		_combat_log_label.scroll_to_line(_combat_log_label.get_line_count() - 1)

func _on_awaiting_input() -> void:
	_set_buttons_enabled(true)

func _set_buttons_enabled(enabled: bool) -> void:
	if _fight_btn:
		_fight_btn.disabled = not enabled
	if _escape_btn:
		_escape_btn.disabled = not enabled
	if _abilities_container:
		for child in _abilities_container.get_children():
			if child is Button:
				child.disabled = not enabled

func _build_ability_buttons() -> void:
	if _abilities_container == null:
		return
	# Clear old buttons
	for child in _abilities_container.get_children():
		child.queue_free()
	# Add ability buttons
	var abilities: Array = EvoSystem.get_abilities()
	for i in range(abilities.size()):
		var ability: Dictionary = abilities[i]
		var btn := Button.new()
		var cost_text: String = " (-%d HP)" % ability.get("cost_hp", 0) if ability.get("cost_hp", 0) > 0 else ""
		btn.text = "%s%s" % [ability.get("name", "???"), cost_text]
		btn.pressed.connect(_on_ability_pressed.bind(i))
		_abilities_container.add_child(btn)

func _find_child_recursive(node: Node, child_name: String) -> Node:
	for child in node.get_children():
		if child.name == child_name:
			return child
		var found: Node = _find_child_recursive(child, child_name)
		if found:
			return found
	return null

func _on_fight() -> void:
	_set_buttons_enabled(false)
	combat.player_fight()

func _on_escape() -> void:
	_set_buttons_enabled(false)
	combat.player_escape()

func _on_ability_pressed(index: int) -> void:
	_set_buttons_enabled(false)
	combat.player_special(index)
