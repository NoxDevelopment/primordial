extends CanvasLayer
## res://scripts/hud_controller.gd — HUD overlay: HP, EVO Genes, creature info, era name

var _hp_bar: ProgressBar = null
var _hp_label: Label = null
var _genes_label: Label = null
var _creature_label: Label = null
var _era_label: Label = null

func _ready() -> void:
	_hp_bar = get_node_or_null("HUDPanel/HPBar")
	_hp_label = get_node_or_null("HUDPanel/HPLabel")
	_genes_label = get_node_or_null("HUDPanel/GenesLabel")
	_creature_label = get_node_or_null("HUDPanel/CreatureLabel")
	_era_label = get_node_or_null("HUDPanel/EraLabel")

	EvoSystem.evolved.connect(_on_evolved)
	EvoSystem.evo_genes_changed.connect(_on_genes_changed)
	GameManager.era_changed.connect(_on_era_changed)

	_update_all()

func _process(_delta: float) -> void:
	_update_hp()

func _update_all() -> void:
	_update_hp()
	_update_genes()
	_update_creature()
	_update_era()

func _update_hp() -> void:
	if _hp_bar:
		_hp_bar.max_value = GameManager.player_max_hp
		_hp_bar.value = GameManager.player_hp
	if _hp_label:
		_hp_label.text = "HP: %d/%d" % [GameManager.player_hp, GameManager.player_max_hp]

func _update_genes() -> void:
	if _genes_label:
		_genes_label.text = "EVO Genes: %d" % EvoSystem.evo_genes

func _update_creature() -> void:
	if _creature_label:
		var c: Dictionary = EvoSystem.get_current_creature()
		_creature_label.text = c.get("name", "Unknown")

func _update_era() -> void:
	if _era_label:
		var era_names: Dictionary = {
			1: "Era 1: Cambrian Seas (540 MYA)",
			2: "Era 2: Ordovician-Silurian (485 MYA)",
			3: "Era 3: Age of Fish (420 MYA)",
			4: "Era 4: Carboniferous (360 MYA)",
			5: "Era 5: Permian (300 MYA)",
			6: "Era 6: Triassic (252 MYA)",
			7: "Era 7: Jurassic (200 MYA)",
			8: "Era 8: Cretaceous (145 MYA)",
			9: "Era 9: Paleogene (66 MYA)",
			10: "Era 10: Neogene (23 MYA)",
		}
		_era_label.text = era_names.get(GameManager.current_era, "Unknown Era")

func _on_evolved(_old: Dictionary, _new: Dictionary) -> void:
	_update_all()

func _on_genes_changed(_amount: int) -> void:
	_update_genes()

func _on_era_changed(_era: int) -> void:
	_update_era()
