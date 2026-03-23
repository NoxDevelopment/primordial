extends Node
## res://scripts/audio_manager.gd — Plays SFX and music

var _sfx_player: AudioStreamPlayer = null
var _sfx_cache: Dictionary = {}

# Preload paths
var SFX_PATHS: Dictionary = {
	"hit": "res://assets/audio/hit.wav",
	"evo_gene": "res://assets/audio/evo_gene.wav",
	"evolve": "res://assets/audio/evolve.wav",
	"special": "res://assets/audio/special.wav",
	"defeat": "res://assets/audio/defeat.wav",
}

func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "SFXPlayer"
	_sfx_player.bus = &"Master"
	add_child(_sfx_player)

	# Cache audio streams
	for key in SFX_PATHS:
		var path: String = SFX_PATHS[key]
		if ResourceLoader.exists(path):
			_sfx_cache[key] = load(path)

func play_sfx(sfx_name: String) -> void:
	if _sfx_cache.has(sfx_name):
		_sfx_player.stream = _sfx_cache[sfx_name]
		_sfx_player.play()
