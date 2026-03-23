extends Node
## res://scripts/game_manager.gd — Global game state, era transitions, combat bridge

signal era_changed(era_id: int)
signal creature_evolved(old_id: String, new_id: String)
signal game_over(reason: String)
signal combat_requested(enemy_data: Dictionary)
signal combat_finished(victory: bool)

enum GameState { OVERWORLD, COMBAT, MENU, EVOLUTION_CHART, CUTSCENE }

var state: GameState = GameState.OVERWORLD
var current_era: int = 1
var player_hp: int = 30
var player_max_hp: int = 30

func _ready() -> void:
	EvoSystem.evolved.connect(_on_creature_evolved)
	EvoSystem.dead_end.connect(_on_dead_end)
	EvoSystem.evo_genes_changed.connect(_on_genes_changed)

func start_game() -> void:
	current_era = 1
	EvoSystem.initialize(current_era)
	var creature: Dictionary = EvoSystem.get_current_creature()
	player_max_hp = EvoSystem.get_current_hp_max()
	player_hp = player_max_hp
	state = GameState.OVERWORLD

func _on_creature_evolved(old_data: Dictionary, new_data: Dictionary) -> void:
	var old_id: String = old_data.get("id", "")
	var new_id: String = new_data.get("id", "")
	creature_evolved.emit(old_id, new_id)
	player_max_hp = EvoSystem.get_current_hp_max()
	player_hp = player_max_hp  # Full heal on evolution

	# Check for era transition
	if EvoSystem.is_air_breather() and current_era == 1:
		_transition_era(2)

func _on_dead_end(creature: Dictionary) -> void:
	var story: String = creature.get("extinction_story", "Your lineage ends here.")
	game_over.emit(story)

func _on_genes_changed(_amount: int) -> void:
	pass

func start_combat(enemy_data: Dictionary) -> void:
	if state != GameState.OVERWORLD:
		return
	state = GameState.COMBAT
	combat_requested.emit(enemy_data)

func end_combat(victory: bool, evo_genes: int) -> void:
	state = GameState.OVERWORLD
	if victory:
		EvoSystem.add_evo_genes(evo_genes)
	combat_finished.emit(victory)

func open_evolution_chart() -> void:
	if state == GameState.OVERWORLD:
		state = GameState.EVOLUTION_CHART

func close_evolution_chart() -> void:
	if state == GameState.EVOLUTION_CHART:
		state = GameState.OVERWORLD

func heal_player(amount: int) -> void:
	player_hp = mini(player_hp + amount, player_max_hp)

func damage_player(amount: int) -> void:
	player_hp = maxi(0, player_hp - amount)
	if player_hp <= 0:
		game_over.emit("You have perished. Evolution is unforgiving.")

func _transition_era(new_era: int) -> void:
	current_era = new_era
	era_changed.emit(new_era)
