extends Node2D
## res://scripts/enemy_spawner.gd — Spawns enemies on the map based on current era

@export var spawn_radius: float = 400.0
@export var max_enemies: int = 8
@export var spawn_interval: float = 3.0

var _timer: float = 0.0
var _enemy_scene: PackedScene = null

func _ready() -> void:
	_enemy_scene = load("res://scenes/enemy.tscn") if ResourceLoader.exists("res://scenes/enemy.tscn") else null

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
	# Count current enemies
	var current_count: int = get_tree().get_nodes_in_group("enemies").size()
	if current_count >= max_enemies:
		return

	var era_enemies: Array = CreatureDB.get_era_enemies(GameManager.current_era)
	if era_enemies.is_empty():
		return

	# Filter out enemies that are too weak (2+ generations behind)
	var player_gen: int = EvoSystem.get_generation()
	var valid_enemies: Array = []
	for eid in era_enemies:
		var edata: Dictionary = CreatureDB.get_enemy(eid)
		var egen: int = edata.get("generation", 1)
		if player_gen - egen < 3:
			valid_enemies.append(eid)

	if valid_enemies.is_empty():
		return

	# Pick a random enemy weighted toward player's generation
	var chosen_id: String = valid_enemies[randi_range(0, valid_enemies.size() - 1)]

	# Spawn near player but not too close
	var player: Node2D = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var angle: float = randf() * TAU
	var dist: float = randf_range(200.0, spawn_radius)
	var spawn_pos: Vector2 = player.global_position + Vector2(cos(angle), sin(angle)) * dist

	var enemy = _enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	enemy.add_to_group("enemies")
	enemy.setup(chosen_id)
	get_parent().add_child(enemy)
