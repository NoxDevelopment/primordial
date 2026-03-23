extends CharacterBody2D
## res://scripts/player_controller.gd — Player movement, collision, HP regen, terrain damage

signal entered_combat(enemy_data: Dictionary)
signal hp_changed(current: int, max_hp: int)

@export var speed: float = 120.0
@export var heal_rate: float = 1.0  # HP per second when idle
@export var water_damage_rate: float = 3.0  # HP per second on water tiles

var _idle_time: float = 0.0
var _heal_accumulator: float = 0.0
var _sprite: Sprite2D = null

func _ready() -> void:
	_sprite = get_node_or_null("Sprite2D")
	_update_appearance()
	EvoSystem.evolved.connect(_on_evolved)

func _physics_process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.OVERWORLD:
		return

	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed

	if input_dir.length() < 0.1:
		# Idle — regenerate HP
		_idle_time += delta
		_heal_accumulator += heal_rate * delta
		if _heal_accumulator >= 1.0:
			var heal_amount: int = int(_heal_accumulator)
			_heal_accumulator -= float(heal_amount)
			GameManager.heal_player(heal_amount)
			hp_changed.emit(GameManager.player_hp, GameManager.player_max_hp)
	else:
		_idle_time = 0.0
		_heal_accumulator = 0.0

	move_and_slide()

func _on_evolved(_old: Dictionary, _new: Dictionary) -> void:
	_update_appearance()
	hp_changed.emit(GameManager.player_hp, GameManager.player_max_hp)

func _update_appearance() -> void:
	if _sprite == null:
		return
	var creature: Dictionary = EvoSystem.get_current_creature()
	_sprite.modulate = creature.get("color", Color.WHITE)
	var size: Vector2 = creature.get("sprite_size", Vector2(16, 16))
	_sprite.scale = size / 16.0  # Base sprite is 16x16

func trigger_combat(enemy_data: Dictionary) -> void:
	entered_combat.emit(enemy_data)
	GameManager.start_combat(enemy_data)
