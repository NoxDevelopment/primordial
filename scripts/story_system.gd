extends Node
## res://scripts/story_system.gd — Story events, extinction sequences, Professor Helix narrative

signal story_event_triggered(event_id: String)
signal extinction_started(era: int)
signal extinction_survived(era: int)
signal era_transition_complete(new_era: int)

# Track which story events have fired
var triggered_events: Dictionary = {}
var _dialogue_node: Node = null

func _ready() -> void:
	EvoSystem.evolved.connect(_on_evolved)
	GameManager.era_changed.connect(_on_era_changed)

func set_dialogue_node(node: Node) -> void:
	_dialogue_node = node

func _say(lines: Array[Dictionary]) -> void:
	if _dialogue_node and _dialogue_node.has_method("show_dialogue"):
		_dialogue_node.show_dialogue(lines)

func _prof(text: String) -> Dictionary:
	return {
		"speaker": "Professor Helix",
		"text": text,
		"portrait": "res://assets/img/professor_helix.png",
	}

# ---------------------------------------------------------------------------
# Evolution milestone triggers
# ---------------------------------------------------------------------------

func _on_evolved(old_data: Dictionary, new_data: Dictionary) -> void:
	var new_id: String = new_data.get("id", "")
	var era: int = new_data.get("era", 1)
	var gen: int = new_data.get("generation", 1)

	# Professor comments on notable evolutions
	match new_id:
		"haikouichthys":
			_trigger_event("first_fish", [
				_prof("Extraordinary! You've become Haikouichthys — one of the first TRUE fish! That skull, those gills, that dorsal fin — you just invented the vertebrate body plan. Every fish, frog, lizard, bird, and mammal that will ever live descends from creatures like you."),
			])
		"climatius":
			_trigger_event("first_jaws", [
				_prof("JAWS! You've evolved jaws! This is one of the most revolutionary innovations in the history of life. Your gill arches have been repurposed into biting tools. Before this moment, no creature on Earth could bite. You just changed the rules of the ocean forever."),
			])
		"cladoselache":
			_trigger_event("first_shark", [
				_prof("A shark! You've become one of the first sharks. Magnificent predators from their very first appearance. But I must warn you — this is a powerful form, but it's a BRANCH, not the main line. Sharks never leave the water. To reach land, you'd need to go back and try a different path..."),
			])
		"dunkleosteus":
			_trigger_event("apex_predator", [
				_prof("Dunkleosteus! The apex predator of the Devonian seas! Six meters long, a one-tonne armored juggernaut with self-sharpening bone blades that bite with 6,000 Newtons of force. Nothing in the ocean can challenge you."),
				_prof("But... this is a dead end. The placoderms — ALL of them — will go extinct when the Devonian ends. Every single one. Your armor, your power, your size — none of it matters against what's coming. If you want to survive, you need LUNGS, not jaws."),
			])
		"eusthenopteron":
			_trigger_event("lobe_fins", [
				_prof("Eusthenopteron! Look at those lobe-fins! Inside them are bones homologous to your future humerus, radius, and ulna. You can prop yourself up, breathe at the surface. You're not just a fish anymore — you're the prototype for every land animal that will ever exist."),
			])
		"tiktaalik":
			_trigger_event("fishapod", [
				_prof("TIKTAALIK! The fishapod! Half fish, half tetrapod. You have a flexible neck — no fish before you could turn its head. You have proto-wrists that let you do push-ups. You have LUNGS. You are the bridge between ocean and land."),
				_prof("The Devonian seas are dying. Oxygen levels are crashing, shallow waters are choking with algae. But YOU can breathe air. You can crawl to fresh water. You can SURVIVE what's coming."),
				_prof("The Late Devonian Extinction is beginning. 75% of all species will perish. But creatures like you — the ones who dared to leave the water — will inherit an empty world. Are you ready?"),
			])

	# Check for era transition triggers
	if new_data.get("is_air_breather", false) and era == 1:
		_trigger_event("era1_transition", [
			_prof("The seas are turning toxic. Volcanic eruptions in what will become Siberia are poisoning the water. Coral reefs collapse. The great armored fish vanish."),
			_prof("But life doesn't end — it TRANSFORMS. You crawl onto the muddy shore, gasping the thick Devonian air. Behind you, the ocean you were born in is dying. Ahead of you... an entire empty continent awaits."),
			_prof("Welcome to the CONQUEST OF LAND."),
		])
		# Delay era transition until dialogue finishes
		if _dialogue_node:
			_dialogue_node.dialogue_finished.connect(
				func(): GameManager._transition_era(2),
				CONNECT_ONE_SHOT
			)

# ---------------------------------------------------------------------------
# Era-specific story introductions
# ---------------------------------------------------------------------------

func _on_era_changed(era: int) -> void:
	match era:
		2:
			_trigger_event("era2_intro", [
				_prof("Era 2: The Conquest of Land — 380 to 300 million years ago."),
				_prof("The Devonian and Carboniferous periods. Oxygen levels are SOARING — 35%, higher than ever before or since. Insects grow to monstrous sizes. Forests of giant ferns tower 30 meters high. The air is thick and humid."),
				_prof("You're one of the first vertebrates on land. Your competition? Gigantic arthropods — millipedes 2 meters long, dragonflies with 70cm wingspans. But you have something they don't: BONES. An internal skeleton that can support greater size on land."),
				_prof("Evolve wisely. The Carboniferous Rainforest Collapse is coming — and after that, the GREAT DYING. The worst mass extinction in Earth's history. 96% of all species will perish. Only the most adaptable survive."),
			])
		3:
			_trigger_event("era3_intro", [
				_prof("Era 3: The Rise of Reptiles — 300 to 200 million years ago."),
				_prof("The Permian and Triassic. All the continents have merged into one supercontinent: PANGAEA. The interior is vast desert, scorching and dry. Life clings to the coasts."),
				_prof("Two great lineages are competing: the SYNAPSIDS (ancestors of mammals) and the ARCHOSAURS (ancestors of dinosaurs). Which path will you take? The choice determines your entire future."),
				_prof("The End-Triassic Extinction will reset the board once more. The Central Atlantic Magmatic Province — the largest volcanic event in Earth's history — will tear Pangaea apart and poison the atmosphere."),
			])
		4:
			_trigger_event("era4_intro", [
				_prof("Era 4: The Age of Dinosaurs — 200 to 66 million years ago."),
				_prof("The Jurassic and Cretaceous. This is the golden age of reptiles. Dinosaurs rule every ecosystem on land. Pterosaurs own the skies. Marine reptiles dominate the seas. Flowers appear for the first time. Birds evolve from small feathered theropods."),
				_prof("But in the shadows, small furry creatures — mammals — are biding their time. They're tiny, nocturnal, insect-eating. Insignificant... for now."),
				_prof("And 66 million years ago, a 10-kilometer asteroid will strike what is now Mexico's Yucatan Peninsula. The Chicxulub impact. It will end the age of dinosaurs in a single, terrible day."),
			])
		5:
			_trigger_event("era5_intro", [
				_prof("Era 5: The Age of Mammals — 66 to 2 million years ago."),
				_prof("The Paleogene and Neogene. The dinosaurs are gone. The world is empty, and mammals EXPLODE into every available niche. From tiny shrew-like survivors to the largest land animals that ever lived."),
				_prof("Whales return to the sea. Horses shrink and grow across the plains. Cats, dogs, elephants, primates — all the modern animal families appear. Grasslands replace forests. Ice ages come and go."),
				_prof("And in Africa, a certain lineage of primates begins to walk upright, use tools, and ask questions about where they came from. This is the final chapter of YOUR evolutionary story."),
			])

# ---------------------------------------------------------------------------
# Extinction event sequences
# ---------------------------------------------------------------------------

func trigger_extinction(era: int) -> void:
	extinction_started.emit(era)
	match era:
		1:
			_say([
				_prof("THE LATE DEVONIAN EXTINCTION HAS BEGUN."),
				_prof("Volcanic eruptions are releasing massive amounts of carbon dioxide. Ocean oxygen levels are plummeting. 75% of all species will die in the next million years."),
				_prof("The armored fish — the placoderms — are all gone. The trilobites are decimated. The coral reefs have collapsed entirely. Only creatures adapted to shallow, oxygen-poor water will survive."),
			])
		2:
			_say([
				_prof("THE GREAT DYING — THE PERMIAN-TRIASSIC EXTINCTION."),
				_prof("The Siberian Traps are erupting. FOUR MILLION cubic kilometers of lava. The atmosphere fills with carbon dioxide and sulfur. Global temperatures rise 10°C. The oceans acidify and lose oxygen."),
				_prof("96% of all marine species. 70% of all land vertebrates. Gone. This is the closest life on Earth has EVER come to total extinction. The 'Great Dying' earns its name."),
				_prof("Only the small, the burrowing, the adaptable survive. Is that you?"),
			])
		3:
			_say([
				_prof("THE END-TRIASSIC EXTINCTION."),
				_prof("Pangaea is tearing itself apart. The Central Atlantic Magmatic Province erupts — volcanism on a continental scale. CO2 doubles. Temperatures spike. Ocean chemistry collapses."),
				_prof("Half of all species vanish. But this extinction creates OPPORTUNITY. The ecological niches left empty will be filled by... dinosaurs."),
			])
		4:
			_say([
				_prof("THE CHICXULUB IMPACT — K-Pg EXTINCTION."),
				_prof("A 10-kilometer asteroid traveling at 20 kilometers per second strikes the Yucatan Peninsula. The impact releases energy equivalent to 10 BILLION nuclear weapons."),
				_prof("A wall of superheated air incinerates everything within 1,500 kilometers. Tsunamis hundreds of meters high sweep the coasts. The debris cloud blocks sunlight for YEARS. Global temperatures drop 15°C."),
				_prof("Every land animal larger than 25 kilograms dies. The dinosaurs — rulers of the Earth for 165 million years — are gone. All of them. Except the birds."),
				_prof("But in their burrows, hidden from the cold and dark, small mammals survive on seeds and insects. Their time has finally come."),
			])

# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

func _trigger_event(event_id: String, lines: Array[Dictionary]) -> void:
	if triggered_events.has(event_id):
		return
	triggered_events[event_id] = true
	_say(lines)
	story_event_triggered.emit(event_id)

func has_triggered(event_id: String) -> bool:
	return triggered_events.has(event_id)
