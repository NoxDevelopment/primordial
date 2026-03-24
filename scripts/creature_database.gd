extends Node
## res://scripts/creature_database.gd — All creature definitions, evolution trees, and encyclopedia data

# Each creature is a Dictionary with:
#   id: String — unique identifier
#   name: String — display name
#   scientific_name: String — Latin binomial
#   era: int — which era (1-5)
#   generation: int — depth in evolution tree (higher = more evolved)
#   period: String — geological period
#   mya: String — millions of years ago
#   size: String — real-world size
#   diet: String — herbivore/carnivore/omnivore/filter-feeder
#   description: String — encyclopedia text with real science
#   stat_caps: Dictionary — {attack: int, wisdom: int, vitality: int, endurance: int} max allocatable per stat
#   base_hp: int — starting HP for this form
#   base_attack: int — base attack power
#   base_defense: int — base defense
#   abilities: Array[Dictionary] — special abilities [{name, cost_hp, power, description}]
#   color: Color — sprite tint color (until we have real sprites)
#   sprite_size: Vector2 — pixel size for procedural sprite
#   evolves_to: Array[Dictionary] — [{creature_id: String, stat: String}] vertical=highest cap stat, horizontal=others
#   is_air_breather: bool — triggers era 1→2 transition
#   is_land_walker: bool — can traverse land tiles
#   extinction_story: String — shown if this is a dead-end evolution

var creatures: Dictionary = {}
var era_trees: Dictionary = {}  # era_id -> Array of creature_ids in order

const EraData = preload("res://scripts/creature_database_eras.gd")

func _ready() -> void:
	_build_era1_creatures()
	_build_era1_tree()
	# Load additional eras
	EraData.build_era4_creatures(creatures)
	EraData.build_era8_creatures(creatures)
	EraData.build_era10_creatures(creatures)
	# Build era trees
	era_trees[4] = ["ichthyostega", "eryops", "hylonomus", "petrolacosaurus", "dimetrodon"]
	era_trees[8] = ["coelophysis", "allosaurus", "stegosaurus", "tyrannosaurus", "triceratops"]
	era_trees[10] = ["purgatorius", "aegyptopithecus", "australopithecus", "homo_sapiens"]

func get_creature(id: String) -> Dictionary:
	return creatures.get(id, {})

func get_era_creatures(era: int) -> Array:
	return era_trees.get(era, [])

func get_starter_creature(era: int) -> String:
	var tree: Array = era_trees.get(era, [])
	if tree.is_empty():
		return ""
	return tree[0]

func get_evolution_options(creature_id: String) -> Array:
	var c: Dictionary = creatures.get(creature_id, {})
	return c.get("evolves_to", [])

func get_vertical_evolution(creature_id: String) -> String:
	var c: Dictionary = creatures.get(creature_id, {})
	var caps: Dictionary = c.get("stat_caps", {})
	if caps.is_empty():
		return ""
	var max_stat: String = ""
	var max_val: int = 0
	for stat_name in caps:
		var val: int = caps[stat_name]
		if val > max_val:
			max_val = val
			max_stat = stat_name
	for evo in c.get("evolves_to", []):
		if evo.get("stat", "") == max_stat:
			return evo.get("creature_id", "")
	return ""

func get_horizontal_evolution(creature_id: String, filled_stat: String) -> String:
	var c: Dictionary = creatures.get(creature_id, {})
	for evo in c.get("evolves_to", []):
		if evo.get("stat", "") == filled_stat:
			return evo.get("creature_id", "")
	return ""

# ---------------------------------------------------------------------------
# Era 1: The Primordial Seas (540–380 MYA)
# ---------------------------------------------------------------------------

func _build_era1_creatures() -> void:
	creatures["pikaia"] = {
		"id": "pikaia",
		"name": "Pikaia",
		"scientific_name": "Pikaia gracilens",
		"era": 1, "generation": 1,
		"period": "Middle Cambrian",
		"mya": "508 MYA",
		"size": "3.8 cm long",
		"diet": "Filter-feeder",
		"description": "One of the earliest known chordates — your most ancient ancestor with a notochord. This tiny worm-like creature swam through Cambrian seas by flexing its body side to side. Its notochord, a flexible rod running along its back, would eventually become the vertebral column in all vertebrates including humans.",
		"stat_caps": {"attack": 20, "wisdom": 24, "vitality": 28, "endurance": 32},
		"base_hp": 30, "base_attack": 3, "base_defense": 2,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP based on Wisdom. Available to all creatures."}
		],
		"color": Color(0.85, 0.75, 0.65),
		"sprite_size": Vector2(16, 8),
		"evolves_to": [
			{"creature_id": "haikouichthys", "stat": "endurance"},
			{"creature_id": "anomalocaris_player", "stat": "attack"},
		],
		"is_air_breather": false, "is_land_walker": false,
		"extinction_story": "",
	}

	creatures["haikouichthys"] = {
		"id": "haikouichthys",
		"name": "Haikouichthys",
		"scientific_name": "Haikouichthys ercaicunensis",
		"era": 1, "generation": 2,
		"period": "Early Cambrian",
		"mya": "518 MYA",
		"size": "2.5 cm long",
		"diet": "Filter-feeder",
		"description": "Among the oldest known true fish. This tiny creature from Cambrian China had a defined skull, gills, and a dorsal fin — features that would define all fish to come. It represents the critical leap from invertebrate to vertebrate.",
		"stat_caps": {"attack": 24, "wisdom": 28, "vitality": 32, "endurance": 36},
		"base_hp": 40, "base_attack": 5, "base_defense": 4,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP based on Wisdom."},
			{"name": "Quick Dart", "cost_hp": 3, "power": 8, "description": "A sudden burst of speed to strike. Early fish were fast despite their size."},
		],
		"color": Color(0.7, 0.8, 0.85),
		"sprite_size": Vector2(18, 8),
		"evolves_to": [
			{"creature_id": "arandaspis", "stat": "endurance"},
			{"creature_id": "cephalaspis", "stat": "vitality"},
		],
		"is_air_breather": false, "is_land_walker": false,
		"extinction_story": "",
	}

	creatures["arandaspis"] = {
		"id": "arandaspis",
		"name": "Arandaspis",
		"scientific_name": "Arandaspis prionotolepis",
		"era": 1, "generation": 3,
		"period": "Late Ordovician",
		"mya": "470 MYA",
		"size": "15 cm long",
		"diet": "Detritivore",
		"description": "One of the first armored jawless fish. Its bony head shield provided protection from predators like eurypterids. Arandaspis fed by scooping sediment from the ocean floor, filtering nutrients. It had no jaws — those wouldn't evolve for millions of years.",
		"stat_caps": {"attack": 24, "wisdom": 28, "vitality": 36, "endurance": 40},
		"base_hp": 55, "base_attack": 6, "base_defense": 8,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP based on Wisdom."},
			{"name": "Shell Bash", "cost_hp": 5, "power": 12, "description": "Ram with armored head shield. The first vertebrate body armor."},
		],
		"color": Color(0.6, 0.55, 0.5),
		"sprite_size": Vector2(24, 12),
		"evolves_to": [
			{"creature_id": "cephalaspis", "stat": "endurance"},
			{"creature_id": "climatius", "stat": "attack"},
		],
		"is_air_breather": false, "is_land_walker": false,
		"extinction_story": "The armored jawless fish persisted for millions of years, but without jaws they could never be active predators. When jawed fish evolved, the ostracoderms slowly declined, clinging to the sediment until the very last one vanished.",
	}

	creatures["cephalaspis"] = {
		"id": "cephalaspis",
		"name": "Cephalaspis",
		"scientific_name": "Cephalaspis lyelli",
		"era": 1, "generation": 3,
		"period": "Early Devonian",
		"mya": "415 MYA",
		"size": "22 cm long",
		"diet": "Detritivore",
		"description": "A jawless fish with a distinctive horseshoe-shaped head shield. Cephalaspis had sensory fields on its head that could detect electrical signals from other animals — a precursor to the electroreception found in modern sharks. It lived on the bottom of rivers and shallow seas.",
		"stat_caps": {"attack": 20, "wisdom": 36, "vitality": 32, "endurance": 40},
		"base_hp": 50, "base_attack": 5, "base_defense": 10,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP based on Wisdom."},
			{"name": "Electrosense", "cost_hp": 4, "power": 6, "description": "Detect and disorient enemies using electrical fields. Confuses enemy for 1 turn."},
		],
		"color": Color(0.65, 0.6, 0.55),
		"sprite_size": Vector2(26, 14),
		"evolves_to": [
			{"creature_id": "climatius", "stat": "endurance"},
			{"creature_id": "bothriolepis", "stat": "vitality"},
		],
		"is_air_breather": false, "is_land_walker": false,
		"extinction_story": "",
	}

	creatures["climatius"] = {
		"id": "climatius",
		"name": "Climatius",
		"scientific_name": "Climatius reticulatus",
		"era": 1, "generation": 4,
		"period": "Late Silurian",
		"mya": "425 MYA",
		"size": "8 cm long",
		"diet": "Carnivore",
		"description": "An acanthodian — one of the first jawed fish. The evolution of jaws was revolutionary: repurposed gill arches became biting tools, allowing fish to become active predators for the first time. Climatius bristled with fin spines along its belly, making it hard to swallow.",
		"stat_caps": {"attack": 36, "wisdom": 28, "vitality": 32, "endurance": 36},
		"base_hp": 60, "base_attack": 12, "base_defense": 8,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP based on Wisdom."},
			{"name": "Jaw Snap", "cost_hp": 5, "power": 18, "description": "The first true bite. Jaws evolved from gill arches — a revolution in feeding."},
			{"name": "Spine Guard", "cost_hp": 3, "power": 0, "description": "Raise fin spines to reduce incoming damage by 50% for 1 turn."},
		],
		"color": Color(0.5, 0.6, 0.45),
		"sprite_size": Vector2(20, 10),
		"evolves_to": [
			{"creature_id": "cladoselache", "stat": "attack"},
			{"creature_id": "bothriolepis", "stat": "endurance"},
		],
		"is_air_breather": false, "is_land_walker": false,
		"extinction_story": "",
	}

	creatures["cladoselache"] = {
		"id": "cladoselache",
		"name": "Cladoselache",
		"scientific_name": "Cladoselache fyleri",
		"era": 1, "generation": 5,
		"period": "Late Devonian",
		"mya": "380 MYA",
		"size": "1.2 m long",
		"diet": "Carnivore",
		"description": "One of the earliest sharks. Built for speed with a streamlined body, large forked tail, and powerful jaws. Unlike modern sharks, Cladoselache had smooth skin and no claspers. Its fossils are remarkably well-preserved, some even showing the outlines of muscles and kidneys.",
		"stat_caps": {"attack": 44, "wisdom": 28, "vitality": 36, "endurance": 32},
		"base_hp": 80, "base_attack": 18, "base_defense": 10,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP based on Wisdom."},
			{"name": "Predator Strike", "cost_hp": 8, "power": 28, "description": "A devastating lunge attack. Sharks are apex predators from their very first appearance."},
			{"name": "Speed Burst", "cost_hp": 5, "power": 15, "description": "Streamlined body allows a rapid charge. High chance to act first."},
		],
		"color": Color(0.45, 0.5, 0.55),
		"sprite_size": Vector2(32, 14),
		"evolves_to": [
			{"creature_id": "dunkleosteus", "stat": "attack"},
		],
		"is_air_breather": false, "is_land_walker": false,
		"extinction_story": "The ancient sharks thrived as oceanic predators. Your lineage continued in the deep waters, refining the cartilaginous skeleton over hundreds of millions of years. But you never left the sea. The land remained forever out of reach.",
	}

	creatures["bothriolepis"] = {
		"id": "bothriolepis",
		"name": "Bothriolepis",
		"scientific_name": "Bothriolepis canadensis",
		"era": 1, "generation": 5,
		"period": "Late Devonian",
		"mya": "385 MYA",
		"size": "30 cm long",
		"diet": "Detritivore",
		"description": "The most widespread placoderm ever found — fossils on every continent. Its armored box-like body and jointed arm-fins let it crawl along river bottoms. Remarkably, Bothriolepis may have had primitive lungs alongside gills, hinting at the transition to land breathing.",
		"stat_caps": {"attack": 28, "wisdom": 32, "vitality": 40, "endurance": 44},
		"base_hp": 75, "base_attack": 10, "base_defense": 15,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP based on Wisdom."},
			{"name": "Arm Sweep", "cost_hp": 5, "power": 14, "description": "Swing jointed pectoral fins. These armored appendages foreshadow limbs."},
			{"name": "Burrow", "cost_hp": 4, "power": 0, "description": "Dig into sediment to avoid damage for 1 turn."},
		],
		"color": Color(0.55, 0.45, 0.35),
		"sprite_size": Vector2(28, 16),
		"evolves_to": [
			{"creature_id": "eusthenopteron", "stat": "endurance"},
			{"creature_id": "dunkleosteus", "stat": "attack"},
		],
		"is_air_breather": false, "is_land_walker": false,
		"extinction_story": "",
	}

	creatures["dunkleosteus"] = {
		"id": "dunkleosteus",
		"name": "Dunkleosteus",
		"scientific_name": "Dunkleosteus terrelli",
		"era": 1, "generation": 6,
		"period": "Late Devonian",
		"mya": "380 MYA",
		"size": "6 m long, 1 tonne",
		"diet": "Hypercarnivore",
		"description": "The apex predator of the Devonian seas. This massive placoderm had no teeth — instead, its jaw bones formed self-sharpening blades that could bite with a force of 6,000 Newtons, rivaling T. rex. Dunkleosteus could open its mouth in 1/50th of a second, creating suction that pulled prey in.",
		"stat_caps": {"attack": 50, "wisdom": 24, "vitality": 44, "endurance": 36},
		"base_hp": 120, "base_attack": 30, "base_defense": 20,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP based on Wisdom."},
			{"name": "Guillotine Bite", "cost_hp": 12, "power": 45, "description": "Self-sharpening bone blades deliver 6,000 N of force. The deadliest bite of the Devonian."},
			{"name": "Suction Strike", "cost_hp": 8, "power": 25, "description": "Opens jaws in 20 milliseconds, creating a vacuum that pulls prey in. Cannot miss."},
		],
		"color": Color(0.35, 0.35, 0.4),
		"sprite_size": Vector2(40, 20),
		"evolves_to": [],
		"is_air_breather": false, "is_land_walker": false,
		"extinction_story": "The great Dunkleosteus ruled the Devonian seas unchallenged. But evolution had no interest in perfecting a dead end. When the Devonian extinction struck, the placoderms vanished entirely. No armored fish descendants survive today — their entire lineage was erased.",
	}

	creatures["eusthenopteron"] = {
		"id": "eusthenopteron",
		"name": "Eusthenopteron",
		"scientific_name": "Eusthenopteron foordi",
		"era": 1, "generation": 6,
		"period": "Late Devonian",
		"mya": "385 MYA",
		"size": "1.8 m long",
		"diet": "Carnivore",
		"description": "The fish that started walking. Eusthenopteron's lobe-fins contained bones homologous to the humerus, radius, and ulna in your own arm. It could prop itself up on its fins and likely used them to move between pools. Its internal nostrils allowed it to breathe at the water surface.",
		"stat_caps": {"attack": 32, "wisdom": 36, "vitality": 36, "endurance": 44},
		"base_hp": 90, "base_attack": 16, "base_defense": 12,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP based on Wisdom."},
			{"name": "Lobe-Fin Strike", "cost_hp": 6, "power": 20, "description": "Muscular lobe-fins deliver a powerful blow. These fins contain the bones of your future arms."},
			{"name": "Air Gulp", "cost_hp": 5, "power": 0, "description": "Breathe at the surface to recover extra HP. The first step toward air-breathing."},
		],
		"color": Color(0.5, 0.55, 0.4),
		"sprite_size": Vector2(32, 14),
		"evolves_to": [
			{"creature_id": "tiktaalik", "stat": "endurance"},
		],
		"is_air_breather": false, "is_land_walker": false,
		"extinction_story": "",
	}

	creatures["tiktaalik"] = {
		"id": "tiktaalik",
		"name": "Tiktaalik",
		"scientific_name": "Tiktaalik roseae",
		"era": 1, "generation": 7,
		"period": "Late Devonian",
		"mya": "375 MYA",
		"size": "2.7 m long",
		"diet": "Carnivore",
		"description": "The 'fishapod' — half fish, half tetrapod. Discovered in 2004 in Arctic Canada, Tiktaalik had fish scales and fins but also a flexible neck, flat head, and proto-wrists that let it do push-ups. It could breathe air through lungs and likely hunted in shallow streams. This is the creature that bridged ocean and land.",
		"stat_caps": {"attack": 36, "wisdom": 40, "vitality": 40, "endurance": 48},
		"base_hp": 100, "base_attack": 20, "base_defense": 14,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP based on Wisdom."},
			{"name": "Proto-Wrist Slam", "cost_hp": 7, "power": 24, "description": "Strike with primitive wrists. The first creature that could do push-ups."},
			{"name": "Lung Breath", "cost_hp": 0, "power": 0, "description": "True air-breathing. Fully recover HP over 2 turns."},
			{"name": "Ambush", "cost_hp": 8, "power": 30, "description": "Flat head and upward-facing eyes — a shallow-water ambush predator."},
		],
		"color": Color(0.45, 0.5, 0.35),
		"sprite_size": Vector2(36, 16),
		"evolves_to": [],
		"is_air_breather": true, "is_land_walker": false,
		"extinction_story": "",
	}

func _build_era1_tree() -> void:
	era_trees[1] = [
		"pikaia", "haikouichthys", "arandaspis", "cephalaspis",
		"climatius", "cladoselache", "bothriolepis",
		"dunkleosteus", "eusthenopteron", "tiktaalik",
	]

# ---------------------------------------------------------------------------
# Enemy creature definitions (for combat encounters, not player evolutions)
# ---------------------------------------------------------------------------

var enemies: Dictionary = {}

func _init() -> void:
	_build_enemies()

func get_enemy(id: String) -> Dictionary:
	return enemies.get(id, {})

func get_era_enemies(era: int) -> Array:
	var result: Array = []
	for eid in enemies:
		if enemies[eid].get("era", 0) == era:
			result.append(eid)
	return result

func _build_era1_starter_enemies() -> void:
	# VERY EASY prey for Pikaia — generation 0, low stats
	enemies["plankton"] = {
		"id": "plankton", "name": "Plankton Swarm", "era": 1,
		"scientific_name": "Zooplankton",
		"hp": 5, "attack": 1, "defense": 0, "wisdom": 0,
		"evo_genes_reward": 3,
		"description": "A cloud of tiny drifting organisms. The foundation of the ocean food web. Easy prey for even the smallest predator.",
		"abilities": [],
		"color": Color(0.7, 0.8, 0.7),
		"generation": 0,
		"portrait": "res://assets/img/portrait_jellyfish.png",
	}

	enemies["sea_worm"] = {
		"id": "sea_worm", "name": "Priapulid Worm", "era": 1,
		"scientific_name": "Ottoia prolifica",
		"hp": 8, "attack": 2, "defense": 1, "wisdom": 0,
		"evo_genes_reward": 4,
		"description": "A burrowing predatory worm of the Cambrian seabed. Common but not dangerous. Named after the Greek god Priapus due to its... shape.",
		"abilities": [{"name": "Burrow", "cost_hp": 1, "power": 0, "description": "Digs into sediment. Avoids damage for 1 turn."}],
		"color": Color(0.6, 0.5, 0.45),
		"generation": 0,
		"portrait": "res://assets/img/portrait_trilobite.png",
	}

	enemies["small_sponge"] = {
		"id": "small_sponge", "name": "Sea Sponge", "era": 1,
		"scientific_name": "Vauxia gracilenta",
		"hp": 10, "attack": 0, "defense": 3, "wisdom": 0,
		"evo_genes_reward": 3,
		"description": "One of the oldest multicellular animals. Sponges don't move, don't think, and don't fight back. But they're tough — they've survived every mass extinction for 600 million years.",
		"abilities": [],
		"color": Color(0.7, 0.6, 0.5),
		"generation": 0,
		"portrait": "res://assets/img/portrait_trilobite.png",
	}

	enemies["small_trilobite"] = {
		"id": "small_trilobite", "name": "Small Trilobite", "era": 1,
		"scientific_name": "Elrathia kingii",
		"hp": 12, "attack": 3, "defense": 4, "wisdom": 1,
		"evo_genes_reward": 5,
		"description": "A common, palm-sized trilobite. Found in enormous numbers — the 'pigeons of the Cambrian'. Easy prey but they can curl up defensively.",
		"abilities": [{"name": "Curl Up", "cost_hp": 1, "power": 0, "description": "Roll into ball. Defense doubled for 1 turn."}],
		"color": Color(0.55, 0.45, 0.35),
		"generation": 1,
		"portrait": "res://assets/img/portrait_trilobite.png",
	}

func _build_era1_extra_enemies() -> void:
	_build_era1_starter_enemies()
	enemies["hallucigenia"] = {
		"id": "hallucigenia", "name": "Hallucigenia", "era": 1,
		"scientific_name": "Hallucigenia sparsa",
		"hp": 12, "attack": 3, "defense": 8, "wisdom": 1,
		"evo_genes_reward": 5,
		"description": "One of the strangest animals ever found. A Cambrian worm with seven pairs of spines on its back and tentacle-like legs. Scientists originally reconstructed it upside-down.",
		"abilities": [{"name": "Spine Wall", "cost_hp": 2, "power": 0, "description": "Raises spines, doubling defense for 1 turn."}],
		"color": Color(0.5, 0.4, 0.6),
		"generation": 1,
		"portrait": "res://assets/img/portrait_trilobite.png",
	}

	enemies["opabinia"] = {
		"id": "opabinia", "name": "Opabinia", "era": 1,
		"scientific_name": "Opabinia regalis",
		"hp": 25, "attack": 8, "defense": 4, "wisdom": 6,
		"evo_genes_reward": 10,
		"description": "Five eyes and a flexible proboscis ending in a claw. When first presented to scientists in 1972, the audience burst out laughing — they thought it was a joke. It was real.",
		"abilities": [
			{"name": "Proboscis Grab", "cost_hp": 4, "power": 12, "description": "The flexible trunk snatches prey with its claw."},
			{"name": "Five-Eyed Watch", "cost_hp": 2, "power": 0, "description": "Five eyes see everything. Cannot be surprised next turn."},
		],
		"color": Color(0.4, 0.5, 0.3),
		"generation": 2,
		"portrait": "res://assets/img/portrait_trilobite.png",
	}

	enemies["wiwaxia"] = {
		"id": "wiwaxia", "name": "Wiwaxia", "era": 1,
		"scientific_name": "Wiwaxia corrugata",
		"hp": 18, "attack": 2, "defense": 12, "wisdom": 1,
		"evo_genes_reward": 7,
		"description": "An armored Cambrian slug covered in overlapping scales and long defensive spines. A living fortress that grazed on bacterial mats on the seafloor.",
		"abilities": [{"name": "Spine Armor", "cost_hp": 0, "power": 0, "description": "Permanent +4 defense from scales and spines."}],
		"color": Color(0.6, 0.55, 0.4),
		"generation": 1,
		"portrait": "res://assets/img/portrait_trilobite.png",
	}

	enemies["orthoceras"] = {
		"id": "orthoceras", "name": "Orthoceras", "era": 1,
		"scientific_name": "Orthoceras regulare",
		"hp": 40, "attack": 12, "defense": 10, "wisdom": 7,
		"evo_genes_reward": 16,
		"description": "A straight-shelled nautiloid up to half a meter long. Jet-propelled predator of the Ordovician seas. Ancestor of modern squid and octopus.",
		"abilities": [
			{"name": "Tentacle Snare", "cost_hp": 5, "power": 16, "description": "Grasping tentacles hold prey tight."},
			{"name": "Ink Cloud", "cost_hp": 4, "power": 0, "description": "Releases ink cloud. Enemy accuracy halved for 2 turns."},
		],
		"color": Color(0.5, 0.45, 0.5),
		"generation": 3,
		"portrait": "res://assets/img/portrait_cameroceras.png",
	}

func _build_enemies() -> void:
	_build_era1_extra_enemies()
	EraData.build_era4_enemies(enemies)
	EraData.build_era10_enemies(enemies)
	enemies["trilobite"] = {
		"id": "trilobite", "name": "Trilobite", "era": 1,
		"scientific_name": "Calymene blumenbachii",
		"hp": 20, "attack": 4, "defense": 6, "wisdom": 2,
		"evo_genes_reward": 8,
		"description": "An ancient arthropod that dominated the seas for 300 million years. Over 20,000 species are known.",
		"abilities": [{"name": "Curl Up", "cost_hp": 2, "power": 0, "description": "Roll into a ball, doubling defense for 1 turn."}],
		"color": Color(0.6, 0.5, 0.4),
		"generation": 1,
		"portrait": "res://assets/img/portrait_trilobite.png",
	}

	enemies["jellyfish"] = {
		"id": "jellyfish", "name": "Jellyfish", "era": 1,
		"scientific_name": "Scyphozoa",
		"hp": 15, "attack": 6, "defense": 1, "wisdom": 4,
		"evo_genes_reward": 6,
		"description": "Jellyfish have existed for over 500 million years — older than dinosaurs, older than trees, older than most life on Earth.",
		"abilities": [{"name": "Sting", "cost_hp": 3, "power": 10, "description": "Venomous tentacle sting. Poisons for 2 turns."}],
		"color": Color(0.7, 0.7, 0.9),
		"generation": 1,
		"portrait": "res://assets/img/portrait_jellyfish.png",
	}

	enemies["eurypterid"] = {
		"id": "eurypterid", "name": "Eurypterid", "era": 1,
		"scientific_name": "Eurypterus remipes",
		"hp": 45, "attack": 14, "defense": 10, "wisdom": 5,
		"evo_genes_reward": 18,
		"description": "Sea scorpions — some grew to 2.5 meters, making them the largest arthropods ever. Terrifying predators of the Ordovician and Silurian seas.",
		"abilities": [
			{"name": "Claw Crush", "cost_hp": 5, "power": 20, "description": "Massive pincers deliver crushing force."},
			{"name": "Tail Stab", "cost_hp": 4, "power": 16, "description": "Scorpion-like tail strike."},
		],
		"color": Color(0.4, 0.35, 0.3),
		"generation": 3,
		"portrait": "res://assets/img/portrait_eurypterid.png",
	}

	enemies["nautiloid"] = {
		"id": "nautiloid", "name": "Nautiloid", "era": 1,
		"scientific_name": "Orthoceras regulare",
		"hp": 35, "attack": 10, "defense": 12, "wisdom": 6,
		"evo_genes_reward": 14,
		"description": "Giant straight-shelled cephalopods that ruled Ordovician seas. Some Cameroceras grew to 6 meters — the first large predators on Earth. Ancestors of modern nautilus, squid, and octopus.",
		"abilities": [
			{"name": "Tentacle Grab", "cost_hp": 4, "power": 14, "description": "Grasping tentacles hold prey tight."},
			{"name": "Jet Propulsion", "cost_hp": 6, "power": 18, "description": "Powerful water jet rams into enemy."},
		],
		"color": Color(0.55, 0.45, 0.5),
		"generation": 2,
		"portrait": "res://assets/img/portrait_cameroceras.png",
	}

	enemies["anomalocaris"] = {
		"id": "anomalocaris", "name": "Anomalocaris", "era": 1,
		"scientific_name": "Anomalocaris canadensis",
		"hp": 60, "attack": 20, "defense": 8, "wisdom": 8,
		"evo_genes_reward": 25,
		"description": "The 'abnormal shrimp' was the apex predator of the Cambrian Explosion — up to 1 meter long when most life was centimeters. Its circular mouth could crush trilobite shells. The terror of the ancient seas.",
		"abilities": [
			{"name": "Appendage Crush", "cost_hp": 6, "power": 28, "description": "Grasping appendages seize and crush prey."},
			{"name": "Circular Bite", "cost_hp": 8, "power": 35, "description": "The infamous ring of teeth closes on prey. Devastating."},
		],
		"color": Color(0.65, 0.4, 0.3),
		"generation": 4,
		"portrait": "res://assets/img/portrait_anomalocaris.png",
	}

	enemies["cameroceras"] = {
		"id": "cameroceras", "name": "Cameroceras", "era": 1,
		"scientific_name": "Cameroceras trentonense",
		"hp": 80, "attack": 22, "defense": 15, "wisdom": 10,
		"evo_genes_reward": 30,
		"description": "A 6-meter giant orthocone nautiloid — the largest predator of the Ordovician. Its straight shell was as long as a car. A true sea monster of the ancient world.",
		"abilities": [
			{"name": "Constrict", "cost_hp": 8, "power": 30, "description": "Massive tentacles wrap and squeeze."},
			{"name": "Ram", "cost_hp": 10, "power": 35, "description": "Charge with the enormous shell. Devastating impact."},
		],
		"color": Color(0.5, 0.4, 0.45),
		"generation": 5,
		"portrait": "res://assets/img/portrait_cameroceras.png",
	}
