extends Node2D
## res://scripts/enemy_spawner.gd — Spawns enemies on the map based on current era

@export var spawn_radius: float = 300.0
@export var max_enemies: int = 6
@export var spawn_interval: float = 2.0

var _timer: float = 0.0
var _enemy_scene: PackedScene = null
var _spawn_count: int = 0

func _ready() -> void:
	# Load enemy scene
	if ResourceLoader.exists("res://scenes/enemy.tscn"):
		_enemy_scene = load("res://scenes/enemy.tscn")
		print("[Spawner] Enemy scene loaded OK")
	else:
		push_error("[Spawner] enemy.tscn not found!")

	# Spawn a few enemies immediately
	call_deferred("_initial_spawn")

func _initial_spawn() -> void:
	for i in range(4):
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

	# Count current enemies
	var current_count: int = get_tree().get_nodes_in_group("enemies").size()
	if current_count >= max_enemies:
		return

	var era_enemies: Array = CreatureDB.get_era_enemies(GameManager.current_era)
	if era_enemies.is_empty():
		return

	# Filter out enemies too weak
	var player_gen: int = EvoSystem.get_generation()
	var valid_enemies: Array = []
	for eid in era_enemies:
		var edata: Dictionary = CreatureDB.get_enemy(eid)
		var egen: int = edata.get("generation", 1)
		if player_gen - egen < 3:
			valid_enemies.append(eid)

	if valid_enemies.is_empty():
		return

	var chosen_id: String = valid_enemies[randi_range(0, valid_enemies.size() - 1)]

	# Spawn near player
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if player == null:
		# No player in group — try finding by node name
		player = get_parent().get_node_or_null("Player")
	if player == null:
		return

	var angle: float = randf() * TAU
	var dist: float = randf_range(100.0, spawn_radius)
	var spawn_pos: Vector2 = player.global_position + Vector2(cos(angle), sin(angle)) * dist

	var enemy = _enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	enemy.add_to_group("enemies")
	get_parent().add_child(enemy)
	# Call setup AFTER adding to tree so script is active
	enemy.setup(chosen_id)
	_spawn_count += 1
