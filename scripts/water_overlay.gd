extends CanvasLayer
## res://scripts/water_overlay.gd — Underwater visual: subtle tint only, no weird light band

var _time: float = 0.0
var _overlay: ColorRect = null

func _ready() -> void:
	layer = 5

	# Very subtle blue water tint — barely there
	_overlay = ColorRect.new()
	_overlay.name = "WaterTint"
	_overlay.color = Color(0.02, 0.08, 0.18, 0.10)
	_overlay.anchor_left = 0.0
	_overlay.anchor_top = 0.0
	_overlay.anchor_right = 1.0
	_overlay.anchor_bottom = 1.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)

func _process(delta: float) -> void:
	_time += delta
	if _overlay:
		# Very gentle pulsing
		var pulse: float = 0.08 + sin(_time * 0.6) * 0.02
		_overlay.color.a = pulse

func set_era_tint(era: int) -> void:
	if _overlay == null:
		return
	match era:
		1, 2, 3: _overlay.color = Color(0.02, 0.08, 0.18, 0.10)  # Blue underwater
		4: _overlay.color = Color(0.03, 0.08, 0.02, 0.08)  # Green swamp mist
		5, 6: _overlay.color = Color(0.10, 0.05, 0.01, 0.06)  # Warm desert haze
		7, 8: _overlay.color = Color(0.01, 0.06, 0.01, 0.05)  # Light forest
		9, 10: _overlay.color = Color(0.06, 0.07, 0.10, 0.08)  # Cold grey
