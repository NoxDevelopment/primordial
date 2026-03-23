extends CharacterBody2D
## res://scripts/player_controller.gd — Player movement, collision, HP regen

signal entered_combat(enemy_data: Dictionary)
signal hp_changed(current: int, max_hp: int)

@export var speed: float = 120.0
@export var heal_rate: float = 1.0

var _idle_time: float = 0.0
var _heal_accumulator: float = 0.0
var _sprite: Sprite2D = null

# Sprite regions from player_creatures.png per creature
# The sheet has ~12 creatures scattered — map them by evolution tree position
var CREATURE_SPRITE_REGIONS: Dictionary = {
	"pikaia": Rect2(768, 512, 256, 256),
	"haikouichthys": Rect2(512, 512, 256, 256),
	"arandaspis": Rect2(256, 512, 256, 256),
	"cephalaspis": Rect2(0, 512, 256, 256),
	"climatius": Rect2(768, 256, 256, 256),
	"cladoselache": Rect2(0, 0, 256, 256),
	"bothriolepis": Rect2(256, 256, 256, 256),
	"dunkleosteus": Rect2(0, 256, 256, 256),
	"eusthenopteron": Rect2(512, 0, 256, 256),
	"tiktaalik": Rect2(256, 0, 256, 256),
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
		# Flip sprite to face movement direction
		if _sprite and input_dir.x != 0.0:
			_sprite.flip_h = input_dir.x < 0.0

	move_and_slide()

func _on_evolved(_old: Dictionary, new_data: Dictionary) -> void:
	_update_appearance()
	hp_changed.emit(GameManager.player_hp, GameManager.player_max_hp)

func _update_appearance() -> void:
	if _sprite == null:
		return
	var creature: Dictionary = EvoSystem.get_current_creature()
	var creature_id: String = creature.get("id", "")

	# Use creature-specific sprite region
	if CREATURE_SPRITE_REGIONS.has(creature_id):
		_sprite.region_rect = CREATURE_SPRITE_REGIONS[creature_id]
		_sprite.modulate = Color.WHITE

	# Scale based on creature size progression
	var gen: int = creature.get("generation", 1)
	var base_scale: float = 0.08 + gen * 0.02
	_sprite.scale = Vector2(base_scale, base_scale)

func trigger_combat(enemy_data: Dictionary) -> void:
	entered_combat.emit(enemy_data)
	GameManager.start_combat(enemy_data)
