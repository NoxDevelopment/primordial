extends CharacterBody2D
## res://scripts/enemy_controller.gd — Enemy wander AI, despawn logic, combat trigger

var enemy_id: String = ""
var enemy_data: Dictionary = {}
var wander_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0
var wander_speed: float = 40.0

# Individual sprite paths per enemy type
var ENEMY_SPRITES: Dictionary = {
	"trilobite": "res://assets/img/sprite_trilobite.png",
	"jellyfish": "res://assets/img/sprite_jellyfish.png",
	"eurypterid": "res://assets/img/sprite_eurypterid.png",
	"nautiloid": "res://assets/img/sprite_nautiloid.png",
	"anomalocaris": "res://assets/img/sprite_anomalocaris.png",
	"cameroceras": "res://assets/img/sprite_nautiloid.png",
}

func _ready() -> void:
	var area: Area2D = get_node_or_null("DetectionArea")
	if area:
		area.body_entered.connect(_on_body_entered)
		area.monitoring = true

func setup(id: String) -> void:
	enemy_id = id
	enemy_data = CreatureDB.get_enemy(id)
	var sprite: Sprite2D = get_node_or_null("Sprite2D")
	if sprite == null:
		return

	# Load individual sprite texture
	var sprite_path: String = ENEMY_SPRITES.get(id, "")
	if sprite_path != "" and ResourceLoader.exists(sprite_path):
		sprite.texture = load(sprite_path)
		sprite.region_enabled = false
		sprite.scale = Vector2(0.06, 0.06)
		sprite.modulate = Color.WHITE
	else:
		# Fallback: color tint on placeholder
		sprite.modulate = enemy_data.get("color", Color.RED)

func _physics_process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.OVERWORLD:
		return

	# Check if should despawn (2+ generations behind player)
	var player_gen: int = EvoSystem.get_generation()
	var enemy_gen: int = enemy_data.get("generation", 1)
	if player_gen - enemy_gen >= 3:
		queue_free()
		return

	# Simple wander AI
	wander_timer -= delta
	if wander_timer <= 0.0:
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		wander_timer = randf_range(1.5, 4.0)
		if randf() < 0.3:
			wander_direction = Vector2.ZERO

	velocity = wander_direction * wander_speed
	move_and_slide()

func _on_body_entered(body: Node2D) -> void:
	if GameManager.state != GameManager.GameState.OVERWORLD:
		return
	if body.is_in_group("player") and body.has_method("trigger_combat"):
		body.trigger_combat(enemy_data)
		queue_free()
