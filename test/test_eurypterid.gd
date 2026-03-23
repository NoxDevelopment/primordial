extends SceneTree

var _frame: int = 0

func _initialize() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	root.add_child(scene.instantiate())

func _process(delta: float) -> bool:
	_frame += 1
	if _frame == 8:
		for child in root.get_children():
			if child.name == "CreatureDB":
				var enemy: Dictionary = child.get_enemy("eurypterid")
				for c2 in root.get_children():
					if c2.name == "GameManager":
						c2.start_combat(enemy)
				break
	if _frame >= 35:
		quit(0)
	return false
