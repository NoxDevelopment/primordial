extends SceneTree
## Test: force a combat encounter to show the combat UI with portrait

var _frame: int = 0
var _combat_triggered: bool = false

func _initialize() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	var instance = scene.instantiate()
	root.add_child(instance)

func _process(delta: float) -> bool:
	_frame += 1

	# Frame 10: Force a combat encounter with a jellyfish
	# Access autoloads via root.get_children() since we're a SceneTree script
	if _frame == 10 and not _combat_triggered:
		var creature_db: Node = null
		var game_mgr: Node = null
		for child in root.get_children():
			if child.name == "CreatureDB":
				creature_db = child
			if child.name == "GameManager":
				game_mgr = child
		if creature_db and game_mgr:
			var enemy: Dictionary = creature_db.get_enemy("jellyfish")
			game_mgr.start_combat(enemy)
			_combat_triggered = true
			print("Combat started with Jellyfish!")

	if _frame >= 40:
		quit(0)

	return false
