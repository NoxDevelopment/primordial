extends Node2D
## res://scripts/enemy_spawner.gd — Spawns enemies scaled to player's current evolution

@export var spawn_radius: float = 250.0
@export var max_enemies: int = 8
@export var spawn_interval: float = 1.5

var _timer: float = 0.0
var _enemy_scene: PackedScene = null

func _ready() -> void:
	if ResourceLoader.exists("res://scenes/enemy.tscn"):
		_enemy_scene = load("res://scenes/enemy.tscn")
	call_deferred("_initial_spawn")

func _initial_spawn() -> void:
	# Spawn 6 enemies immediately so the map isn't empty
	for i in range(6):
		_try_spawn()

func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.OVERWORLD:
		return
	if _enemy_scene == null:
		return

	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_try_spawn()

func _try_spawn() -> void:
	if _enemy_scene == null:
		return

	var current_count: int = get_tree().get_nodes_in_group("enemies").size()
	if current_count >= max_enemies:
		return

	var era_enemies: Array = CreatureDB.get_era_enemies(GameManager.current_era)
	if era_enemies.is_empty():
		return

	var player_gen: int = EvoSystem.get_generation()

	# Build weighted list — favor enemies near player's level
	# Easy enemies (gen 0): always available but less common as you grow
	# Same-gen enemies: most common
	# Slightly stronger enemies: rare, for challenge
	var weighted: Array = []
	for eid in era_enemies:
		var edata: Dictionary = CreatureDB.get_enemy(eid)
		var egen: int = edata.get("generation", 0)

		# Skip enemies way above player
		if egen > player_gen + 2:
			continue
		# Skip enemies way below (despawn threshold)
		if player_gen - egen >= 4:
			continue

		# Weight: enemies at or below player gen get more weight
		var diff: int = egen - player_gen
		var weight: int = 1
		if diff <= -2:
			weight = 1  # Very weak — rare
		elif diff <= -1:
			weight = 2  # Weaker — some
		elif diff == 0:
			weight = 4  # Same level — common
		elif diff == 1:
			weight = 2  # Slightly harder — some
		elif diff == 2:
			weight = 1  # Challenge — rare

		for w in range(weight):
			weighted.append(eid)

	if weighted.is_empty():
		return

	var chosen_id: String = weighted[randi_range(0, weighted.size() - 1)]

	# Find player position
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if player == null:
		player = get_parent().get_node_or_null("Player")
	if player == null:
		return

	var angle: float = randf() * TAU
	var dist: float = randf_range(80.0, spawn_radius)
	var spawn_pos: Vector2 = player.global_position + Vector2(cos(angle), sin(angle)) * dist

	var enemy = _enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	enemy.add_to_group("enemies")
	get_parent().add_child(enemy)
	enemy.setup(chosen_id)
