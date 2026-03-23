extends CanvasLayer
## res://scripts/evolution_chart_controller.gd — Evolution chart screen: stat allocation, tree view, encyclopedia

signal chart_closed()

var _panel: PanelContainer = null
var _creature_name: Label = null
var _scientific_name: Label = null
var _description: RichTextLabel = null
var _period_label: Label = null
var _size_label: Label = null
var _genes_label: Label = null

# Stat bars and buttons
var _stat_bars: Dictionary = {}  # stat_name -> ProgressBar
var _stat_labels: Dictionary = {}  # stat_name -> Label
var _stat_buttons: Dictionary = {}  # stat_name -> Button

var _close_btn: Button = null
var _is_open: bool = false

func _ready() -> void:
	layer = 30
	_build_ui()
	visible = false

	EvoSystem.stats_changed.connect(_on_stats_changed)
	EvoSystem.evo_genes_changed.connect(_on_genes_changed)
	EvoSystem.evolved.connect(_on_evolved)

func open() -> void:
	_is_open = true
	visible = true
	_refresh_all()
	GameManager.open_evolution_chart()

func close() -> void:
	_is_open = false
	visible = false
	GameManager.close_evolution_chart()
	chart_closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return
	if event.is_action_pressed("cancel") or event.is_action_pressed("menu"):
		close()
		get_viewport().set_input_as_handled()

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.name = "ChartPanel"
	_panel.anchors_preset = Control.PRESET_FULL_RECT
	_panel.anchor_left = 0.05
	_panel.anchor_top = 0.05
	_panel.anchor_right = 0.95
	_panel.anchor_bottom = 0.95
	add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	_panel.add_child(margin)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 10)
	margin.add_child(main_vbox)

	# Title
	var title := Label.new()
	title.text = "EVOLUTION CHART"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	main_vbox.add_child(title)

	# Top section: creature info
	var info_hbox := HBoxContainer.new()
	info_hbox.add_theme_constant_override("separation", 20)
	main_vbox.add_child(info_hbox)

	# Left: names + period
	var info_left := VBoxContainer.new()
	info_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_hbox.add_child(info_left)

	_creature_name = Label.new()
	_creature_name.text = "Pikaia"
	_creature_name.add_theme_font_size_override("font_size", 20)
	info_left.add_child(_creature_name)

	_scientific_name = Label.new()
	_scientific_name.text = "Pikaia gracilens"
	_scientific_name.add_theme_font_size_override("font_size", 14)
	_scientific_name.modulate = Color(0.7, 0.7, 0.8)
	info_left.add_child(_scientific_name)

	_period_label = Label.new()
	_period_label.text = "Middle Cambrian — 508 MYA"
	info_left.add_child(_period_label)

	_size_label = Label.new()
	_size_label.text = "Size: 3.8 cm"
	info_left.add_child(_size_label)

	# Right: genes count
	_genes_label = Label.new()
	_genes_label.text = "EVO Genes: 0"
	_genes_label.add_theme_font_size_override("font_size", 18)
	_genes_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	info_hbox.add_child(_genes_label)

	# Stat bars section
	var stats_label := Label.new()
	stats_label.text = "Distribute EVO Genes:"
	stats_label.add_theme_font_size_override("font_size", 16)
	main_vbox.add_child(stats_label)

	var stat_colors: Dictionary = {
		"attack": Color(0.9, 0.3, 0.2),
		"wisdom": Color(0.3, 0.5, 0.9),
		"vitality": Color(0.2, 0.8, 0.3),
		"endurance": Color(0.8, 0.7, 0.2),
	}

	var stat_descriptions: Dictionary = {
		"attack": "Fight damage",
		"wisdom": "Special abilities & Escape",
		"vitality": "Max HP",
		"endurance": "Defense & terrain",
	}

	for stat_name in ["attack", "wisdom", "vitality", "endurance"]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		main_vbox.add_child(row)

		var name_label := Label.new()
		name_label.text = "%s:" % stat_name.capitalize()
		name_label.custom_minimum_size = Vector2(100, 0)
		row.add_child(name_label)

		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(300, 25)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.max_value = 100
		bar.value = 0
		# Color the bar
		var style := StyleBoxFlat.new()
		style.bg_color = stat_colors.get(stat_name, Color.WHITE)
		bar.add_theme_stylebox_override("fill", style)
		row.add_child(bar)
		_stat_bars[stat_name] = bar

		var val_label := Label.new()
		val_label.text = "0/20"
		val_label.custom_minimum_size = Vector2(60, 0)
		row.add_child(val_label)
		_stat_labels[stat_name] = val_label

		var desc := Label.new()
		desc.text = stat_descriptions.get(stat_name, "")
		desc.modulate = Color(0.6, 0.6, 0.7)
		desc.custom_minimum_size = Vector2(180, 0)
		row.add_child(desc)

		var btn := Button.new()
		btn.text = "+1"
		btn.custom_minimum_size = Vector2(50, 30)
		btn.pressed.connect(_on_allocate.bind(stat_name))
		row.add_child(btn)
		_stat_buttons[stat_name] = btn

		var btn5 := Button.new()
		btn5.text = "+5"
		btn5.custom_minimum_size = Vector2(50, 30)
		btn5.pressed.connect(_on_allocate_bulk.bind(stat_name, 5))
		row.add_child(btn5)

	# Description / encyclopedia
	var desc_label := Label.new()
	desc_label.text = "Encyclopedia:"
	desc_label.add_theme_font_size_override("font_size", 16)
	main_vbox.add_child(desc_label)

	_description = RichTextLabel.new()
	_description.bbcode_enabled = false
	_description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_description.custom_minimum_size = Vector2(0, 100)
	main_vbox.add_child(_description)

	# Close button
	_close_btn = Button.new()
	_close_btn.text = "Close [ESC]"
	_close_btn.custom_minimum_size = Vector2(120, 35)
	_close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_close_btn.pressed.connect(close)
	main_vbox.add_child(_close_btn)

func _refresh_all() -> void:
	var c: Dictionary = EvoSystem.get_current_creature()
	if _creature_name:
		_creature_name.text = c.get("name", "Unknown")
	if _scientific_name:
		_scientific_name.text = c.get("scientific_name", "")
	if _period_label:
		_period_label.text = "%s — %s" % [c.get("period", "?"), c.get("mya", "?")]
	if _size_label:
		_size_label.text = "Size: %s | Diet: %s" % [c.get("size", "?"), c.get("diet", "?")]
	if _description:
		_description.text = c.get("description", "No data available.")
	_update_stats()
	_update_genes()

func _update_stats() -> void:
	var caps: Dictionary = EvoSystem.get_stat_caps()
	for stat_name in ["attack", "wisdom", "vitality", "endurance"]:
		var val: int = EvoSystem.stats.get(stat_name, 0)
		var cap: int = caps.get(stat_name, 1)
		if _stat_bars.has(stat_name):
			_stat_bars[stat_name].max_value = cap
			_stat_bars[stat_name].value = val
		if _stat_labels.has(stat_name):
			_stat_labels[stat_name].text = "%d/%d" % [val, cap]
		if _stat_buttons.has(stat_name):
			_stat_buttons[stat_name].disabled = not EvoSystem.can_allocate(stat_name)

func _update_genes() -> void:
	if _genes_label:
		_genes_label.text = "EVO Genes: %d" % EvoSystem.evo_genes
	# Disable all buttons if no genes
	for stat_name in _stat_buttons:
		_stat_buttons[stat_name].disabled = not EvoSystem.can_allocate(stat_name)

func _on_allocate(stat_name: String) -> void:
	EvoSystem.allocate_gene(stat_name)

func _on_allocate_bulk(stat_name: String, amount: int) -> void:
	EvoSystem.allocate_genes_bulk(stat_name, amount)

func _on_stats_changed(_stats: Dictionary) -> void:
	if _is_open:
		_update_stats()

func _on_genes_changed(_amount: int) -> void:
	if _is_open:
		_update_genes()

func _on_evolved(_old: Dictionary, _new: Dictionary) -> void:
	if _is_open:
		_refresh_all()
