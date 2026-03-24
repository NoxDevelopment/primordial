extends CharacterBody2D
## res://scripts/enemy_controller.gd — Enemy wander AI, swimming animation, combat trigger

var enemy_id: String = ""
var enemy_data: Dictionary = {}
var wander_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0
var wander_speed: float = 40.0
var _swim_time: float = 0.0
var _sprite: Sprite2D = null

var ENEMY_SPRITES: Dictionary = {
	"trilobite": "res://assets/img/sprite_trilobite.png",
	"jellyfish": "res://assets/img/sprite_jellyfish.png",
	"eurypterid": "res://assets/img/sprite_eurypterid.png",
	"nautiloid": "res://assets/img/sprite_nautiloid.png",
	"anomalocaris": "res://assets/img/sprite_anomalocaris.png",
	"cameroceras": "res://assets/img/sprite_nautiloid.png",
}

func _ready() -> void:
	_sprite = get_node_or_null("Sprite2D")
	# Randomize swim phase so enemies don't bob in sync
	_swim_time = randf() * TAU

	var area: Area2D = get_node_or_null("DetectionArea")
	if area:
		area.body_entered.connect(_on_body_entered)
		area.monitoring = true

func setup(id: String) -> void:
	enemy_id = id
	enemy_data = CreatureDB.get_enemy(id)
	if _sprite == null:
		_sprite = get_node_or_null("Sprite2D")
	if _sprite == null:
		return

	var sprite_path: String = ENEMY_SPRITES.get(id, "")
	if sprite_path != "" and ResourceLoader.exists(sprite_path):
		_sprite.texture = load(sprite_path)
		_sprite.region_enabled = false
		_sprite.modulate = Color.WHITE
		# Size based on enemy generation (bigger = tougher)
		var gen: int = enemy_data.get("generation", 1)
		var s: float = 0.06 + gen * 0.012
		_sprite.scale = Vector2(s, s)
	else:
		_sprite.modulate = enemy_data.get("color", Color.RED)

func _physics_process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.OVERWORLD:
		return

	# Despawn check
	var player_gen: int = EvoSystem.get_generation()
	var enemy_gen: int = enemy_data.get("generation", 1)
	if player_gen - enemy_gen >= 3:
		queue_free()
		return

	# Swimming animation
	_swim_time += delta
	if _sprite:
		_sprite.offset.y = sin(_swim_time * 2.5) * 2.5
		_sprite.rotation = sin(_swim_time * 1.8) * 0.06
		# Face wander direction
		if wander_direction.x != 0.0:
			_sprite.flip_h = wander_direction.x < 0.0

	# Wander AI
	wander_timer -= delta
	if wander_timer <= 0.0:
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		wander_timer = randf_range(1.5, 4.0)
		if randf() < 0.3:
			wander_direction = Vector2.ZERO

	velocity = wander_direction * wander_speed
	move_and_slide()

func get_combat_data() -> Dictionary:
	return enemy_data

func _on_body_entered(body: Node2D) -> void:
	if GameManager.state != GameManager.GameState.OVERWORLD:
		return
	if body.is_in_group("player") and body.has_method("trigger_combat"):
		body.trigger_combat(enemy_data)
		queue_free()
