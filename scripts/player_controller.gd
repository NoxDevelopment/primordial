extends CharacterBody2D
## res://scripts/player_controller.gd — Player movement, collision, HP regen

signal entered_combat(enemy_data: Dictionary)
signal hp_changed(current: int, max_hp: int)

@export var speed: float = 120.0
@export var heal_rate: float = 1.0

var _idle_time: float = 0.0
var _heal_accumulator: float = 0.0
var _sprite: Sprite2D = null

# Individual sprite paths per creature
var CREATURE_SPRITES: Dictionary = {
	"pikaia": "res://assets/img/sprite_pikaia.png",
	"haikouichthys": "res://assets/img/sprite_pikaia.png",
	"arandaspis": "res://assets/img/sprite_trilobite.png",
	"cephalaspis": "res://assets/img/sprite_trilobite.png",
	"climatius": "res://assets/img/sprite_nautiloid.png",
	"cladoselache": "res://assets/img/sprite_anomalocaris.png",
	"bothriolepis": "res://assets/img/sprite_trilobite.png",
	"dunkleosteus": "res://assets/img/sprite_anomalocaris.png",
	"eusthenopteron": "res://assets/img/sprite_nautiloid.png",
	"tiktaalik": "res://assets/img/sprite_eurypterid.png",
}

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
		if _sprite and input_dir.x != 0.0:
			_sprite.flip_h = input_dir.x < 0.0

	move_and_slide()

func _on_evolved(_old: Dictionary, _new: Dictionary) -> void:
	_update_appearance()
	hp_changed.emit(GameManager.player_hp, GameManager.player_max_hp)

func _update_appearance() -> void:
	if _sprite == null:
		return
	var creature: Dictionary = EvoSystem.get_current_creature()
	var creature_id: String = creature.get("id", "")

	# Load individual sprite
	var sprite_path: String = CREATURE_SPRITES.get(creature_id, "")
	if sprite_path != "" and ResourceLoader.exists(sprite_path):
		_sprite.texture = load(sprite_path)
		_sprite.region_enabled = false
		_sprite.modulate = Color.WHITE
	else:
		_sprite.modulate = creature.get("color", Color.WHITE)

	# Scale based on generation — bigger as you evolve
	var gen: int = creature.get("generation", 1)
	var base_scale: float = 0.04 + gen * 0.01
	_sprite.scale = Vector2(base_scale, base_scale)

func trigger_combat(enemy_data: Dictionary) -> void:
	entered_combat.emit(enemy_data)
	GameManager.start_combat(enemy_data)
