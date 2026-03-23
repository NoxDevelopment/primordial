extends CanvasLayer
## res://scripts/water_overlay.gd — Underwater visual effect: blue tint, caustics, particles

var _time: float = 0.0
var _overlay: ColorRect = null
var _bubbles: Array = []

func _ready() -> void:
	layer = 5  # Above world, below HUD

	# Blue water tint overlay
	_overlay = ColorRect.new()
	_overlay.name = "WaterTint"
	_overlay.color = Color(0.05, 0.15, 0.35, 0.18)
	_overlay.anchor_left = 0.0
	_overlay.anchor_top = 0.0
	_overlay.anchor_right = 1.0
	_overlay.anchor_bottom = 1.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)

	# Light rays overlay (subtle)
	var rays := ColorRect.new()
	rays.name = "LightRays"
	rays.color = Color(0.3, 0.5, 0.7, 0.06)
	rays.anchor_left = 0.0
	rays.anchor_top = 0.0
	rays.anchor_right = 1.0
	rays.anchor_bottom = 0.3
	rays.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rays)

func _process(delta: float) -> void:
	_time += delta
	# Gentle pulsing of water tint
	if _overlay:
		var pulse: float = 0.16 + sin(_time * 0.8) * 0.03
		_overlay.color.a = pulse
