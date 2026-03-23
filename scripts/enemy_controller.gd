extends CharacterBody2D
## res://scripts/enemy_controller.gd — Enemy wander AI, despawn logic, combat trigger

var enemy_id: String = ""
var enemy_data: Dictionary = {}
var wander_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0
var wander_speed: float = 40.0

# Sprite region mapping: which part of enemy_creatures.png to show per enemy type
# The sheet is 1024x1024 with ~16 creatures in a 4x4 grid (256x256 each)
var ENEMY_SPRITE_REGIONS: Dictionary = {
	"trilobite": Rect2(0, 256, 256, 256),
	"jellyfish": Rect2(256, 512, 256, 256),
	"eurypterid": Rect2(0, 512, 256, 256),
	"nautiloid": Rect2(256, 0, 256, 256),
	"anomalocaris": Rect2(512, 0, 256, 256),
	"cameroceras": Rect2(768, 0, 256, 256),
}

func _ready() -> void:
	var area: Area2D = get_node_or_null("DetectionArea")
	if area:
		area.body_entered.connect(_on_body_entered)

func setup(id: String) -> void:
	enemy_id = id
	enemy_data = CreatureDB.get_enemy(id)
	var sprite: Sprite2D = get_node_or_null("Sprite2D")
	if sprite:
		# Try to use a specific region from the enemy sprite sheet
		if ENEMY_SPRITE_REGIONS.has(id):
			sprite.region_rect = ENEMY_SPRITE_REGIONS[id]
		else:
			# Random region for unknown enemy types
			var rx: int = randi_range(0, 3) * 256
			var ry: int = randi_range(0, 3) * 256
			sprite.region_rect = Rect2(rx, ry, 256, 256)
		sprite.modulate = Color.WHITE  # Use actual texture colors, not tint

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
		# Remove this enemy after triggering combat
		queue_free()
