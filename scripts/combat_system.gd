extends Node
## res://scripts/combat_system.gd — Turn-based combat: Fight/Special/Escape

signal combat_started(enemy_data: Dictionary)
signal combat_ended(victory: bool, evo_genes: int)
signal player_hp_changed(current: int, max_hp: int)
signal enemy_hp_changed(current: int, max_hp: int)
signal combat_log(text: String)
signal turn_ended()
signal awaiting_player_input()

var in_combat: bool = false
var enemy_data: Dictionary = {}
var enemy_hp: int = 0
var enemy_max_hp: int = 0
var player_hp: int = 0
var player_max_hp: int = 0

# Status effects
var player_poisoned_turns: int = 0
var enemy_confused_turns: int = 0
var player_defense_mult: float = 1.0
var enemy_defense_mult: float = 1.0

func start_combat(enemy: Dictionary, current_player_hp: int) -> void:
	enemy_data = enemy
	enemy_hp = enemy.get("hp", 20)
	enemy_max_hp = enemy_hp
	player_max_hp = EvoSystem.get_current_hp_max()
	player_hp = mini(current_player_hp, player_max_hp)
	in_combat = true

	# Reset status
	player_poisoned_turns = 0
	enemy_confused_turns = 0
	player_defense_mult = 1.0
	enemy_defense_mult = 1.0

	combat_started.emit(enemy_data)
	player_hp_changed.emit(player_hp, player_max_hp)
	enemy_hp_changed.emit(enemy_hp, enemy_max_hp)

	combat_log.emit("A wild %s appeared!" % enemy_data.get("name", "creature"))
	awaiting_player_input.emit()

# ---------------------------------------------------------------------------
# Player actions
# ---------------------------------------------------------------------------

func player_fight() -> void:
	if not in_combat:
		return
	var attack: int = EvoSystem.get_attack_power()
	var enemy_def: int = int(float(enemy_data.get("defense", 0)) * enemy_defense_mult)
	var damage: int = maxi(1, attack - enemy_def + randi_range(-2, 2))

	enemy_hp -= damage
	combat_log.emit("You attack for %d damage!" % damage)
	enemy_hp_changed.emit(maxi(0, enemy_hp), enemy_max_hp)

	if enemy_hp <= 0:
		_victory()
		return

	_enemy_turn()

func player_special(ability_index: int) -> void:
	if not in_combat:
		return
	var abilities: Array = EvoSystem.get_abilities()
	if ability_index < 0 or ability_index >= abilities.size():
		combat_log.emit("No such ability!")
		awaiting_player_input.emit()
		return

	var ability: Dictionary = abilities[ability_index]
	var cost: int = ability.get("cost_hp", 0)
	var power: int = ability.get("power", 0)
	var ability_name: String = ability.get("name", "Unknown")

	# Rest is special — heals based on wisdom
	if ability_name == "Rest":
		var heal: int = 5 + EvoSystem.get_wisdom_power()
		player_hp = mini(player_hp + heal, player_max_hp)
		combat_log.emit("You rest and recover %d HP." % heal)
		player_hp_changed.emit(player_hp, player_max_hp)
		_enemy_turn()
		return

	# Lung Breath — big heal over time
	if ability_name == "Lung Breath":
		var heal: int = int(float(player_max_hp) * 0.4)
		player_hp = mini(player_hp + heal, player_max_hp)
		combat_log.emit("You breathe air deeply and recover %d HP!" % heal)
		player_hp_changed.emit(player_hp, player_max_hp)
		_enemy_turn()
		return

	# Electrosense — confuse enemy
	if ability_name == "Electrosense":
		player_hp -= cost
		enemy_confused_turns = 2
		combat_log.emit("Electrical fields disorient the enemy for 2 turns!")
		player_hp_changed.emit(maxi(0, player_hp), player_max_hp)
		if player_hp <= 0:
			_defeat()
			return
		_enemy_turn()
		return

	# Spine Guard / Curl Up — boost defense
	if ability_name == "Spine Guard" or ability_name == "Curl Up":
		player_hp -= cost
		player_defense_mult = 2.0
		combat_log.emit("You raise your defenses!")
		player_hp_changed.emit(maxi(0, player_hp), player_max_hp)
		if player_hp <= 0:
			_defeat()
			return
		_enemy_turn()
		return

	# Burrow — avoid damage
	if ability_name == "Burrow":
		player_hp -= cost
		player_defense_mult = 100.0  # Essentially invincible for 1 turn
		combat_log.emit("You burrow into the sediment!")
		player_hp_changed.emit(maxi(0, player_hp), player_max_hp)
		if player_hp <= 0:
			_defeat()
			return
		_enemy_turn()
		return

	# Standard damage ability
	if cost > 0:
		player_hp -= cost
		player_hp_changed.emit(maxi(0, player_hp), player_max_hp)
		if player_hp <= 0:
			_defeat()
			return

	var wisdom_bonus: int = EvoSystem.get_wisdom_power() / 3
	var enemy_def: int = int(float(enemy_data.get("defense", 0)) * enemy_defense_mult)
	var damage: int = maxi(1, power + wisdom_bonus - enemy_def + randi_range(-2, 3))

	enemy_hp -= damage
	combat_log.emit("%s deals %d damage!" % [ability_name, damage])
	enemy_hp_changed.emit(maxi(0, enemy_hp), enemy_max_hp)

	if enemy_hp <= 0:
		_victory()
		return

	_enemy_turn()

func player_escape() -> void:
	if not in_combat:
		return
	var wisdom: int = EvoSystem.get_wisdom_power()
	var enemy_wisdom: int = enemy_data.get("wisdom", 5)
	var escape_chance: float = clampf(0.3 + float(wisdom - enemy_wisdom) * 0.05, 0.1, 0.9)

	if randf() < escape_chance:
		combat_log.emit("You escaped!")
		in_combat = false
		combat_ended.emit(false, 0)
		return

	combat_log.emit("Couldn't escape!")
	_enemy_turn()

# ---------------------------------------------------------------------------
# Enemy turn
# ---------------------------------------------------------------------------

func _enemy_turn() -> void:
	# Reset one-turn buffs
	player_defense_mult = maxf(1.0, player_defense_mult * 0.5)
	enemy_defense_mult = 1.0

	# Poison tick
	if player_poisoned_turns > 0:
		var poison_dmg: int = 3
		player_hp -= poison_dmg
		player_poisoned_turns -= 1
		combat_log.emit("Poison deals %d damage! (%d turns left)" % [poison_dmg, player_poisoned_turns])
		player_hp_changed.emit(maxi(0, player_hp), player_max_hp)
		if player_hp <= 0:
			_defeat()
			return

	# Confused enemies have 50% chance to skip
	if enemy_confused_turns > 0:
		enemy_confused_turns -= 1
		if randf() < 0.5:
			combat_log.emit("The %s is confused and does nothing!" % enemy_data.get("name", "enemy"))
			turn_ended.emit()
			awaiting_player_input.emit()
			return

	# Enemy chooses action
	var abilities: Array = enemy_data.get("abilities", [])
	var use_ability: bool = not abilities.is_empty() and randf() < 0.4

	if use_ability:
		var ability: Dictionary = abilities[randi_range(0, abilities.size() - 1)]
		var ability_name: String = ability.get("name", "Attack")
		var power: int = ability.get("power", 0)

		# Special ability effects
		if ability_name == "Sting":
			player_poisoned_turns = 2
			combat_log.emit("The %s stings you! Poisoned for 2 turns!" % enemy_data.get("name", "enemy"))

		if ability_name == "Curl Up":
			enemy_defense_mult = 2.0
			combat_log.emit("The %s curls into a ball!" % enemy_data.get("name", "enemy"))
			turn_ended.emit()
			awaiting_player_input.emit()
			return

		if power > 0:
			var player_def: int = int(float(EvoSystem.get_defense_power()) * player_defense_mult)
			var damage: int = maxi(1, power - player_def + randi_range(-2, 2))
			player_hp -= damage
			combat_log.emit("The %s uses %s for %d damage!" % [enemy_data.get("name", "enemy"), ability_name, damage])
		else:
			combat_log.emit("The %s uses %s!" % [enemy_data.get("name", "enemy"), ability_name])
	else:
		# Normal attack
		var enemy_attack: int = enemy_data.get("attack", 5)
		var player_def: int = int(float(EvoSystem.get_defense_power()) * player_defense_mult)
		var damage: int = maxi(1, enemy_attack - player_def + randi_range(-2, 2))
		player_hp -= damage
		combat_log.emit("The %s attacks for %d damage!" % [enemy_data.get("name", "enemy"), damage])

	player_hp_changed.emit(maxi(0, player_hp), player_max_hp)

	if player_hp <= 0:
		_defeat()
		return

	turn_ended.emit()
	awaiting_player_input.emit()

# ---------------------------------------------------------------------------
# Combat resolution
# ---------------------------------------------------------------------------

func _victory() -> void:
	var genes: int = enemy_data.get("evo_genes_reward", 5)
	combat_log.emit("Victory! Earned %d EVO Genes." % genes)
	in_combat = false
	combat_ended.emit(true, genes)

func _defeat() -> void:
	combat_log.emit("You have been defeated...")
	in_combat = false
	combat_ended.emit(false, 0)

func get_player_hp() -> int:
	return player_hp
