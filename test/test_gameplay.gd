extends SceneTree
## Test harness: simulates gameplay — movement, combat encounter, evolution chart

var _frame: int = 0
var _cam: Camera2D = null
var _player: Node2D = null
var _main: Node2D = null
var _init_done: bool = false

func _initialize() -> void:
	# Load main scene
	var scene: PackedScene = load("res://scenes/main.tscn")
	var instance = scene.instantiate()
	root.add_child(instance)
	_main = instance

func _process(delta: float) -> bool:
	_frame += 1

	if _frame == 1:
		_player = root.get_node_or_null("Main/Player")
		_cam = root.get_node_or_null("Main/Camera2D")
		if _cam:
			_cam.current = true
		return false

	# Frames 2-20: Move player around to show the overworld
	if _frame >= 2 and _frame < 20:
		if _player:
			_player.position += Vector2(3, 1)
		return false

	# Frame 20: Give player some EVO genes to show the chart
	if _frame == 20:
		EvoSystem.add_evo_genes(25)
		return false

	# Frame 25: Open evolution chart
	if _frame == 25:
		var chart: Node = root.get_node_or_null("Main/EvolutionChart")
		if chart and chart.has_method("open"):
			chart.open()
		return false

	# Frame 40: Allocate some stats
	if _frame == 40:
		EvoSystem.allocate_genes_bulk("endurance", 10)
		EvoSystem.allocate_genes_bulk("attack", 5)
		EvoSystem.allocate_genes_bulk("vitality", 5)
		EvoSystem.allocate_genes_bulk("wisdom", 5)
		return false

	# Frame 55: Close chart
	if _frame == 55:
		var chart: Node = root.get_node_or_null("Main/EvolutionChart")
		if chart and chart.has_method("close"):
			chart.close()
		return false

	# Frame 60-80: Move more
	if _frame >= 60 and _frame < 80:
		if _player:
			_player.position += Vector2(-2, 2)
		return false

	# Frame 90: Done
	if _frame >= 90:
		return false

	return false
