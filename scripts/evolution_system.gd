extends Node
## res://scripts/evolution_system.gd — Core evolution engine: stats, gene distribution, evolution tree traversal

signal stats_changed(stats: Dictionary)
signal evolved(old_creature: Dictionary, new_creature: Dictionary)
signal dead_end(creature: Dictionary)
signal evo_genes_changed(amount: int)

# Current state
var current_creature_id: String = ""
var current_era: int = 1
var evo_genes: int = 0
var evolution_history: Array[String] = []

# 4 EVO stats — each fills from 0 toward the creature's stat cap
# When one reaches 100% of its cap, evolution triggers
var stats: Dictionary = {
	"attack": 0,
	"wisdom": 0,
	"vitality": 0,
	"endurance": 0,
}

func _ready() -> void:
	pass

func initialize(era: int) -> void:
	current_era = era
	var starter_id: String = CreatureDB.get_starter_creature(era)
	if starter_id.is_empty():
		push_error("No starter creature for era %d" % era)
		return
	_set_creature(starter_id, true)

func _set_creature(creature_id: String, is_first: bool = false) -> void:
	var old_data: Dictionary = CreatureDB.get_creature(current_creature_id) if not is_first else {}
	current_creature_id = creature_id
	stats = {"attack": 0, "wisdom": 0, "vitality": 0, "endurance": 0}
	evo_genes = 0
	if not is_first:
		evolution_history.append(creature_id)
	else:
		evolution_history = [creature_id]
	var new_data: Dictionary = CreatureDB.get_creature(creature_id)
	if not is_first:
		evolved.emit(old_data, new_data)
	stats_changed.emit(stats)
	evo_genes_changed.emit(evo_genes)

func get_current_creature() -> Dictionary:
	return CreatureDB.get_creature(current_creature_id)

func get_current_hp_max() -> int:
	var c: Dictionary = get_current_creature()
	var base: int = c.get("base_hp", 30)
	var vitality_bonus: int = stats.get("vitality", 0) * 2
	return base + vitality_bonus

func get_attack_power() -> int:
	var c: Dictionary = get_current_creature()
	var base: int = c.get("base_attack", 5)
	var attack_bonus: int = stats.get("attack", 0)
	return base + attack_bonus

func get_defense_power() -> int:
	var c: Dictionary = get_current_creature()
	var base: int = c.get("base_defense", 3)
	var endurance_bonus: int = stats.get("endurance", 0)
	return base + endurance_bonus

func get_wisdom_power() -> int:
	return stats.get("wisdom", 0)

func get_stat_caps() -> Dictionary:
	var c: Dictionary = get_current_creature()
	return c.get("stat_caps", {"attack": 20, "wisdom": 20, "vitality": 20, "endurance": 20})

func get_stat_percent(stat_name: String) -> float:
	var caps: Dictionary = get_stat_caps()
	var cap: int = caps.get(stat_name, 1)
	if cap <= 0:
		return 0.0
	var current: int = stats.get(stat_name, 0)
	return clampf(float(current) / float(cap), 0.0, 1.0)

func get_abilities() -> Array:
	var c: Dictionary = get_current_creature()
	return c.get("abilities", [])

func get_generation() -> int:
	var c: Dictionary = get_current_creature()
	return c.get("generation", 1)

# ---------------------------------------------------------------------------
# EVO Gene distribution
# ---------------------------------------------------------------------------

func add_evo_genes(amount: int) -> void:
	evo_genes += amount
	evo_genes_changed.emit(evo_genes)

func can_allocate(stat_name: String) -> bool:
	if evo_genes <= 0:
		return false
	var caps: Dictionary = get_stat_caps()
	var cap: int = caps.get(stat_name, 0)
	return stats.get(stat_name, 0) < cap

func allocate_gene(stat_name: String) -> bool:
	if not can_allocate(stat_name):
		return false
	evo_genes -= 1
	stats[stat_name] += 1
	evo_genes_changed.emit(evo_genes)
	stats_changed.emit(stats)

	# Check if this stat hit its cap → trigger evolution
	var caps: Dictionary = get_stat_caps()
	var cap: int = caps.get(stat_name, 0)
	if stats[stat_name] >= cap:
		_trigger_evolution(stat_name)

	return true

func allocate_genes_bulk(stat_name: String, amount: int) -> int:
	var allocated: int = 0
	for i in range(amount):
		if allocate_gene(stat_name):
			allocated += 1
		else:
			break
	return allocated

# ---------------------------------------------------------------------------
# Evolution logic
# ---------------------------------------------------------------------------

func _trigger_evolution(filled_stat: String) -> void:
	var c: Dictionary = get_current_creature()
	var caps: Dictionary = c.get("stat_caps", {})

	# Determine if this is vertical (highest cap stat) or horizontal evolution
	var max_stat: String = ""
	var max_val: int = 0
	for sname in caps:
		if caps[sname] > max_val:
			max_val = caps[sname]
			max_stat = sname

	var is_vertical: bool = (filled_stat == max_stat)
	var target_id: String = ""

	# Find the evolution target for this stat
	for evo in c.get("evolves_to", []):
		if evo.get("stat", "") == filled_stat:
			target_id = evo.get("creature_id", "")
			break

	if target_id.is_empty():
		# Dead end — this stat has no evolution target
		var story: String = c.get("extinction_story", "")
		if story.is_empty():
			story = "Your evolutionary line has reached a dead end. The path of %s was a branch that led nowhere." % c.get("name", "unknown")
		dead_end.emit(c)
		return

	# Evolve!
	Audio.play_sfx("evolve")
	_set_creature(target_id)

func is_air_breather() -> bool:
	var c: Dictionary = get_current_creature()
	return c.get("is_air_breather", false)

func is_land_walker() -> bool:
	var c: Dictionary = get_current_creature()
	return c.get("is_land_walker", false)
