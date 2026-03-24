extends Node
## res://scripts/creature_database_eras.gd — Creature data for Eras 2-10
## Called by CreatureDB to populate all eras beyond Era 1

# This file is loaded by creature_database.gd to add creatures for all eras.
# Each era has player evolution creatures AND enemy creatures.

static func build_era4_creatures(creatures: Dictionary) -> void:
	# Era 4: Carboniferous (360-300 MYA) — Giant insects, first reptiles, coal forests
	creatures["ichthyostega"] = {
		"id": "ichthyostega", "name": "Ichthyostega", "scientific_name": "Ichthyostega stensioei",
		"era": 4, "generation": 1,
		"period": "Late Devonian / Early Carboniferous", "mya": "365 MYA",
		"size": "1.5 m long", "diet": "Carnivore",
		"description": "One of the first vertebrates to walk on land. Ichthyostega had four sturdy legs but kept a fish-like tail and lateral line system. It probably lived like a crocodile — lurking in shallow water and hauling itself onto muddy banks to ambush prey or escape aquatic predators.",
		"stat_caps": {"attack": 32, "wisdom": 28, "vitality": 36, "endurance": 40},
		"base_hp": 80, "base_attack": 14, "base_defense": 10,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Jaw Clamp", "cost_hp": 5, "power": 18, "description": "Powerful amphibian bite inherited from lobe-finned fish ancestors."},
			{"name": "Land Ambush", "cost_hp": 7, "power": 24, "description": "Lunge from water onto land prey. First land predator attack."},
		],
		"color": Color(0.4, 0.45, 0.3), "sprite_size": Vector2(32, 16),
		"evolves_to": [
			{"creature_id": "eryops", "stat": "attack"},
			{"creature_id": "hylonomus", "stat": "endurance"},
		],
		"is_air_breather": true, "is_land_walker": true, "extinction_story": "",
	}

	creatures["eryops"] = {
		"id": "eryops", "name": "Eryops", "scientific_name": "Eryops megacephalus",
		"era": 4, "generation": 2,
		"period": "Early Permian", "mya": "295 MYA",
		"size": "2 m long, 90 kg", "diet": "Carnivore",
		"description": "A massive temnospondyl amphibian — one of the top predators of Carboniferous swamps. Its broad flat skull had powerful jaws lined with teeth. Eryops could live on land but needed to return to water to breed, like modern amphibians.",
		"stat_caps": {"attack": 44, "wisdom": 24, "vitality": 40, "endurance": 36},
		"base_hp": 100, "base_attack": 22, "base_defense": 14,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Skull Crush", "cost_hp": 8, "power": 32, "description": "Massive flat skull delivers a devastating headbutt."},
		],
		"color": Color(0.35, 0.4, 0.3), "sprite_size": Vector2(36, 18),
		"evolves_to": [],
		"is_air_breather": true, "is_land_walker": true,
		"extinction_story": "The giant amphibians ruled the swamps for millions of years. But they could never fully leave the water — they needed it to lay their eggs. When the climate dried, the amphibians were trapped. The future belonged to creatures that could lay eggs on land.",
	}

	creatures["hylonomus"] = {
		"id": "hylonomus", "name": "Hylonomus", "scientific_name": "Hylonomus lyelli",
		"era": 4, "generation": 2,
		"period": "Late Carboniferous", "mya": "312 MYA",
		"size": "20 cm long", "diet": "Insectivore",
		"description": "The oldest confirmed reptile. Tiny, lizard-like, but revolutionary: Hylonomus laid AMNIOTIC EGGS — eggs with a waterproof shell that could survive on dry land. This single innovation freed vertebrates from water forever. Every reptile, bird, and mammal descends from creatures like this.",
		"stat_caps": {"attack": 24, "wisdom": 36, "vitality": 32, "endurance": 44},
		"base_hp": 60, "base_attack": 8, "base_defense": 10,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Quick Bite", "cost_hp": 3, "power": 10, "description": "Small but fast insect-catching jaws."},
			{"name": "Burrow", "cost_hp": 4, "power": 0, "description": "Hide in hollow tree stump. Avoid all damage for 1 turn."},
		],
		"color": Color(0.5, 0.45, 0.35), "sprite_size": Vector2(20, 10),
		"evolves_to": [
			{"creature_id": "dimetrodon", "stat": "attack"},
			{"creature_id": "petrolacosaurus", "stat": "endurance"},
		],
		"is_air_breather": true, "is_land_walker": true, "extinction_story": "",
	}

	creatures["petrolacosaurus"] = {
		"id": "petrolacosaurus", "name": "Petrolacosaurus", "scientific_name": "Petrolacosaurus kansensis",
		"era": 4, "generation": 3,
		"period": "Late Carboniferous", "mya": "302 MYA",
		"size": "40 cm long", "diet": "Insectivore",
		"description": "One of the first diapsid reptiles — the lineage that would produce lizards, snakes, crocodiles, dinosaurs, and birds. Its skull had two temporal openings on each side, allowing stronger jaw muscles than its ancestors.",
		"stat_caps": {"attack": 28, "wisdom": 40, "vitality": 36, "endurance": 48},
		"base_hp": 70, "base_attack": 10, "base_defense": 12,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Diapsid Bite", "cost_hp": 4, "power": 14, "description": "Stronger jaw muscles from dual temporal openings."},
			{"name": "Sprint", "cost_hp": 3, "power": 0, "description": "Quick dash. Guaranteed escape from combat."},
		],
		"color": Color(0.45, 0.5, 0.35), "sprite_size": Vector2(24, 12),
		"evolves_to": [
			{"creature_id": "dimetrodon", "stat": "attack"},
		],
		"is_air_breather": true, "is_land_walker": true, "extinction_story": "",
	}

	creatures["dimetrodon"] = {
		"id": "dimetrodon", "name": "Dimetrodon", "scientific_name": "Dimetrodon grandis",
		"era": 4, "generation": 4,
		"period": "Early Permian", "mya": "295 MYA",
		"size": "3.5 m long, 250 kg", "diet": "Hypercarnivore",
		"description": "NOT a dinosaur — Dimetrodon was a synapsid, more closely related to YOU than to any dinosaur. Its iconic sail was a thermoregulation device: blood vessels in the sail absorbed heat in the morning, letting Dimetrodon become active before cold-blooded prey could move. The first warm-blooded advantage.",
		"stat_caps": {"attack": 48, "wisdom": 32, "vitality": 44, "endurance": 40},
		"base_hp": 130, "base_attack": 28, "base_defense": 18,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Sail Charge", "cost_hp": 10, "power": 38, "description": "Heated by the sail, Dimetrodon strikes first and strikes hard."},
			{"name": "Thermoregulate", "cost_hp": 0, "power": 0, "description": "The sail absorbs heat. Recover 20% HP and boost attack for 2 turns."},
		],
		"color": Color(0.6, 0.4, 0.3), "sprite_size": Vector2(40, 20),
		"evolves_to": [],
		"is_air_breather": true, "is_land_walker": true,
		"extinction_story": "",
	}

static func build_era4_enemies(enemies: Dictionary) -> void:
	enemies["arthropleura"] = {
		"id": "arthropleura", "name": "Arthropleura", "era": 4,
		"scientific_name": "Arthropleura armata",
		"hp": 50, "attack": 14, "defense": 18, "wisdom": 3,
		"evo_genes_reward": 20,
		"description": "The largest land arthropod EVER — a millipede over 2 meters long. Only possible because Carboniferous oxygen was 35%. They were likely herbivores despite their terrifying size.",
		"abilities": [
			{"name": "Body Slam", "cost_hp": 6, "power": 22, "description": "2 meters of armored segments crashing down."},
			{"name": "Coil", "cost_hp": 4, "power": 0, "description": "Curl into armored ball. Defense doubled for 1 turn."},
		],
		"color": Color(0.4, 0.3, 0.25), "generation": 2,
		"portrait": "res://assets/img/portrait_eurypterid.png",
	}

	enemies["meganeura"] = {
		"id": "meganeura", "name": "Meganeura", "era": 4,
		"scientific_name": "Meganeura monyi",
		"hp": 30, "attack": 16, "defense": 4, "wisdom": 10,
		"evo_genes_reward": 15,
		"description": "A dragonfly with a 70cm wingspan — the size of a hawk. The largest flying insect ever. Possible only in the hyperoxic Carboniferous atmosphere. A terrifyingly agile aerial predator.",
		"abilities": [
			{"name": "Dive Strike", "cost_hp": 5, "power": 24, "description": "Aerial dive attack. Always strikes first."},
			{"name": "Evasion", "cost_hp": 3, "power": 0, "description": "Insect agility. 50% dodge chance for 1 turn."},
		],
		"color": Color(0.3, 0.5, 0.4), "generation": 2,
		"portrait": "res://assets/img/portrait_eurypterid.png",
	}

	enemies["pulmonoscorpius"] = {
		"id": "pulmonoscorpius", "name": "Pulmonoscorpius", "era": 4,
		"scientific_name": "Pulmonoscorpius kirktonensis",
		"hp": 45, "attack": 18, "defense": 14, "wisdom": 5,
		"evo_genes_reward": 18,
		"description": "A scorpion 70cm long — the size of a small dog. Armed with massive pincers and a venomous stinger. One of the most dangerous predators of the Carboniferous coal forests.",
		"abilities": [
			{"name": "Pincer Crush", "cost_hp": 6, "power": 22, "description": "Massive pincers grab and crush."},
			{"name": "Venom Sting", "cost_hp": 8, "power": 15, "description": "Tail stinger injects venom. Poisons for 3 turns."},
		],
		"color": Color(0.35, 0.3, 0.25), "generation": 3,
		"portrait": "res://assets/img/portrait_eurypterid.png",
	}

static func build_era8_creatures(creatures: Dictionary) -> void:
	# Era 8: Cretaceous (145-66 MYA) — T-Rex, Triceratops, asteroid impact
	creatures["coelophysis"] = {
		"id": "coelophysis", "name": "Coelophysis", "scientific_name": "Coelophysis bauri",
		"era": 8, "generation": 1,
		"period": "Late Triassic", "mya": "215 MYA",
		"size": "3 m long, 20 kg", "diet": "Carnivore",
		"description": "One of the first dinosaurs — light, fast, and agile. Coelophysis hunted in packs, which was a new strategy in the Triassic. Its hollow bones (hence the name, 'hollow form') made it exceptionally light for its size.",
		"stat_caps": {"attack": 36, "wisdom": 40, "vitality": 32, "endurance": 36},
		"base_hp": 90, "base_attack": 16, "base_defense": 8,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Pack Hunt", "cost_hp": 6, "power": 22, "description": "Call packmates for a coordinated strike. Hits twice."},
			{"name": "Sprint", "cost_hp": 3, "power": 0, "description": "Hollow bones enable incredible speed. Guaranteed escape."},
		],
		"color": Color(0.5, 0.45, 0.35), "sprite_size": Vector2(28, 14),
		"evolves_to": [
			{"creature_id": "allosaurus", "stat": "attack"},
			{"creature_id": "stegosaurus", "stat": "endurance"},
		],
		"is_air_breather": true, "is_land_walker": true, "extinction_story": "",
	}

	creatures["allosaurus"] = {
		"id": "allosaurus", "name": "Allosaurus", "scientific_name": "Allosaurus fragilis",
		"era": 8, "generation": 2,
		"period": "Late Jurassic", "mya": "155 MYA",
		"size": "9.7 m long, 2 tonnes", "diet": "Hypercarnivore",
		"description": "The apex predator of the Late Jurassic. Allosaurus used its skull like a hatchet — opening its jaws wide and slamming them down on prey. Its arms were powerful with large claws, unlike the tiny arms of later tyrannosaurs.",
		"stat_caps": {"attack": 52, "wisdom": 32, "vitality": 44, "endurance": 40},
		"base_hp": 150, "base_attack": 32, "base_defense": 16,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Hatchet Jaw", "cost_hp": 10, "power": 42, "description": "Open wide, slam down. The skull is a weapon."},
			{"name": "Claw Rake", "cost_hp": 7, "power": 28, "description": "Powerful forelimb claws slash prey."},
		],
		"color": Color(0.45, 0.4, 0.35), "sprite_size": Vector2(40, 20),
		"evolves_to": [
			{"creature_id": "tyrannosaurus", "stat": "attack"},
		],
		"is_air_breather": true, "is_land_walker": true, "extinction_story": "",
	}

	creatures["stegosaurus"] = {
		"id": "stegosaurus", "name": "Stegosaurus", "scientific_name": "Stegosaurus stenops",
		"era": 8, "generation": 2,
		"period": "Late Jurassic", "mya": "155 MYA",
		"size": "9 m long, 5 tonnes", "diet": "Herbivore",
		"description": "Iconic plates along its back were likely for display and thermoregulation, not armor. But the thagomizer — four tail spikes — was absolutely a weapon. One Allosaurus vertebra has a Stegosaurus spike-shaped hole in it.",
		"stat_caps": {"attack": 36, "wisdom": 24, "vitality": 52, "endurance": 56},
		"base_hp": 180, "base_attack": 20, "base_defense": 28,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Thagomizer", "cost_hp": 8, "power": 35, "description": "Four tail spikes swing with devastating force. Named by Gary Larson."},
			{"name": "Plate Display", "cost_hp": 0, "power": 0, "description": "Flush blood to plates. Intimidates enemy, reducing their attack for 2 turns."},
		],
		"color": Color(0.4, 0.5, 0.35), "sprite_size": Vector2(42, 22),
		"evolves_to": [
			{"creature_id": "triceratops", "stat": "endurance"},
		],
		"is_air_breather": true, "is_land_walker": true, "extinction_story": "",
	}

	creatures["tyrannosaurus"] = {
		"id": "tyrannosaurus", "name": "Tyrannosaurus", "scientific_name": "Tyrannosaurus rex",
		"era": 8, "generation": 3,
		"period": "Late Cretaceous", "mya": "68 MYA",
		"size": "12.3 m long, 8.4 tonnes", "diet": "Hypercarnivore",
		"description": "The king. T. rex had the strongest bite force of any land animal ever measured — 57,000 Newtons, enough to crush bone. Its vision was better than a hawk's. Recent evidence suggests juveniles were feathered. Not just a predator — a force of nature.",
		"stat_caps": {"attack": 60, "wisdom": 36, "vitality": 52, "endurance": 44},
		"base_hp": 200, "base_attack": 45, "base_defense": 22,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Bone Crusher", "cost_hp": 15, "power": 60, "description": "57,000 Newtons of bite force. Crushes bone. The strongest bite in history."},
			{"name": "Roar", "cost_hp": 5, "power": 0, "description": "Terrifying roar. Enemy skips their next turn in fear."},
			{"name": "Charge", "cost_hp": 10, "power": 40, "description": "8 tonnes at full sprint. Devastating impact."},
		],
		"color": Color(0.35, 0.35, 0.3), "sprite_size": Vector2(48, 24),
		"evolves_to": [],
		"is_air_breather": true, "is_land_walker": true,
		"extinction_story": "The greatest predator the world has ever known. But on one day 66 million years ago, a rock from space ended 165 million years of dinosaur dominion in hours. No amount of strength could stop an asteroid. Size was, in the end, a liability — the larger you were, the more food you needed, and there was none.",
	}

	creatures["triceratops"] = {
		"id": "triceratops", "name": "Triceratops", "scientific_name": "Triceratops horridus",
		"era": 8, "generation": 3,
		"period": "Late Cretaceous", "mya": "68 MYA",
		"size": "9 m long, 12 tonnes", "diet": "Herbivore",
		"description": "Three horns and a massive frill made Triceratops one of the most recognizable dinosaurs. The frill was solid bone — not just display, but real armor. Triceratops and T. rex lived at the same time and place; bite marks on Triceratops frills prove they fought.",
		"stat_caps": {"attack": 40, "wisdom": 28, "vitality": 56, "endurance": 60},
		"base_hp": 220, "base_attack": 30, "base_defense": 35,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Horn Gore", "cost_hp": 10, "power": 40, "description": "Three horns — each a meter long — driven forward with 12 tonnes of force."},
			{"name": "Frill Shield", "cost_hp": 0, "power": 0, "description": "Solid bone frill blocks incoming damage. Reduce damage by 60% for 1 turn."},
		],
		"color": Color(0.5, 0.45, 0.4), "sprite_size": Vector2(44, 24),
		"evolves_to": [],
		"is_air_breather": true, "is_land_walker": true,
		"extinction_story": "The last of the great horned dinosaurs. Triceratops was one of the very last non-avian dinosaurs alive when the asteroid struck. Fossils found within meters of the K-Pg boundary prove they survived until the very end. Then, like all the rest, they were gone.",
	}

static func build_era10_creatures(creatures: Dictionary) -> void:
	# Era 10: Neogene-Quaternary (23-0 MYA) — Ice ages, megafauna, humans
	creatures["purgatorius"] = {
		"id": "purgatorius", "name": "Purgatorius", "scientific_name": "Purgatorius unio",
		"era": 10, "generation": 1,
		"period": "Early Paleocene", "mya": "65 MYA",
		"size": "15 cm long, 40 g", "diet": "Omnivore",
		"description": "One of the earliest primates — a tiny shrew-like creature that lived in trees. It survived the K-Pg extinction by being small, nocturnal, and eating anything. From this humble ancestor came every monkey, ape, and human.",
		"stat_caps": {"attack": 20, "wisdom": 44, "vitality": 28, "endurance": 36},
		"base_hp": 50, "base_attack": 6, "base_defense": 4,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Climb", "cost_hp": 2, "power": 0, "description": "Escape to trees. Guaranteed escape from ground predators."},
			{"name": "Forage", "cost_hp": 0, "power": 0, "description": "Omnivore flexibility. Recover HP by finding food."},
		],
		"color": Color(0.55, 0.45, 0.35), "sprite_size": Vector2(16, 10),
		"evolves_to": [
			{"creature_id": "aegyptopithecus", "stat": "wisdom"},
		],
		"is_air_breather": true, "is_land_walker": true, "extinction_story": "",
	}

	creatures["aegyptopithecus"] = {
		"id": "aegyptopithecus", "name": "Aegyptopithecus", "scientific_name": "Aegyptopithecus zeuxis",
		"era": 10, "generation": 2,
		"period": "Late Eocene", "mya": "30 MYA",
		"size": "68 cm long, 6.7 kg", "diet": "Frugivore",
		"description": "The 'dawn ape' of Egypt — one of the first catarrhine primates, the group that includes all Old World monkeys and apes. Forward-facing eyes gave it stereoscopic vision. Its brain was larger relative to body size than any primate before it.",
		"stat_caps": {"attack": 24, "wisdom": 48, "vitality": 32, "endurance": 40},
		"base_hp": 70, "base_attack": 10, "base_defense": 8,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Branch Throw", "cost_hp": 4, "power": 14, "description": "Hurl branches at threats. First tool use precursor."},
			{"name": "Social Call", "cost_hp": 3, "power": 0, "description": "Alert the troop. Boost defense for 2 turns."},
		],
		"color": Color(0.5, 0.4, 0.3), "sprite_size": Vector2(22, 14),
		"evolves_to": [
			{"creature_id": "australopithecus", "stat": "wisdom"},
		],
		"is_air_breather": true, "is_land_walker": true, "extinction_story": "",
	}

	creatures["australopithecus"] = {
		"id": "australopithecus", "name": "Australopithecus", "scientific_name": "Australopithecus afarensis",
		"era": 10, "generation": 3,
		"period": "Pliocene", "mya": "3.9 MYA",
		"size": "1.1 m tall, 29 kg", "diet": "Omnivore",
		"description": "Lucy. The most famous fossil hominin. Australopithecus walked upright on two legs — bipedalism freed the hands. The brain was still small (400cc, like a chimp), but the body was revolutionary. Upright posture, precision grip, endurance running. The foundation of humanity.",
		"stat_caps": {"attack": 32, "wisdom": 56, "vitality": 40, "endurance": 48},
		"base_hp": 90, "base_attack": 14, "base_defense": 10,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Stone Throw", "cost_hp": 4, "power": 18, "description": "Pick up a rock and hurl it. The first projectile weapon."},
			{"name": "Endurance Run", "cost_hp": 5, "power": 0, "description": "Bipedal endurance. Outlast any predator. Guaranteed escape."},
			{"name": "Social Bond", "cost_hp": 3, "power": 0, "description": "Strength in numbers. Boost all stats for 2 turns."},
		],
		"color": Color(0.5, 0.4, 0.3), "sprite_size": Vector2(20, 24),
		"evolves_to": [
			{"creature_id": "homo_sapiens", "stat": "wisdom"},
		],
		"is_air_breather": true, "is_land_walker": true, "extinction_story": "",
	}

	creatures["homo_sapiens"] = {
		"id": "homo_sapiens", "name": "Homo sapiens", "scientific_name": "Homo sapiens",
		"era": 10, "generation": 4,
		"period": "Pleistocene to Present", "mya": "0.3 MYA",
		"size": "1.7 m tall, 70 kg", "diet": "Omnivore",
		"description": "You. 86 billion neurons. Language. Art. Science. Tools. Fire. Agriculture. Civilization. The culmination of 4.6 billion years of evolution — from a single-celled organism in a primordial ocean to a creature that can contemplate its own origins and ask: 'How did I get here?'",
		"stat_caps": {"attack": 40, "wisdom": 80, "vitality": 44, "endurance": 52},
		"base_hp": 100, "base_attack": 15, "base_defense": 10,
		"abilities": [
			{"name": "Rest", "cost_hp": 0, "power": 0, "description": "Recover HP."},
			{"name": "Tool Craft", "cost_hp": 8, "power": 35, "description": "Create weapons from stone, bone, and wood. Intelligence multiplied."},
			{"name": "Fire", "cost_hp": 10, "power": 50, "description": "The ultimate technology. Terrifies predators, cooks food, shapes the world."},
			{"name": "Cooperation", "cost_hp": 5, "power": 0, "description": "Organize the tribe. Doubles all stats for 3 turns."},
			{"name": "Curiosity", "cost_hp": 0, "power": 0, "description": "Look at the stars and wonder. Fully heal. The power that brought you here."},
		],
		"color": Color(0.55, 0.45, 0.4), "sprite_size": Vector2(18, 28),
		"evolves_to": [],
		"is_air_breather": true, "is_land_walker": true,
		"extinction_story": "",
	}

static func build_era10_enemies(enemies: Dictionary) -> void:
	enemies["smilodon"] = {
		"id": "smilodon", "name": "Smilodon", "era": 10,
		"scientific_name": "Smilodon fatalis",
		"hp": 120, "attack": 35, "defense": 16, "wisdom": 12,
		"evo_genes_reward": 30,
		"description": "The sabertooth cat. 28cm canine teeth that could pierce mammoth hide. Smilodon was a ambush predator — too heavy to chase prey, it relied on explosive power. Its bite was actually weaker than a modern lion's; the sabres were precision tools, not battering rams.",
		"abilities": [
			{"name": "Sabre Strike", "cost_hp": 10, "power": 45, "description": "28cm canines driven into prey. Precision killing."},
			{"name": "Pounce", "cost_hp": 8, "power": 35, "description": "Explosive ambush from cover. Always strikes first."},
		],
		"color": Color(0.6, 0.5, 0.3), "generation": 3,
		"portrait": "res://assets/img/portrait_dunkleosteus.png",
	}

	enemies["mammoth"] = {
		"id": "mammoth", "name": "Woolly Mammoth", "era": 10,
		"scientific_name": "Mammuthus primigenius",
		"hp": 200, "attack": 25, "defense": 30, "wisdom": 15,
		"evo_genes_reward": 35,
		"description": "6 tonnes of fur, muscle, and curved tusks up to 4.2 meters long. Mammoths were social, intelligent, and well-adapted to ice age conditions. They went extinct just 4,000 years ago — some lived alongside the Egyptian pyramids.",
		"abilities": [
			{"name": "Tusk Sweep", "cost_hp": 8, "power": 30, "description": "4-meter curved tusks sweep with enormous force."},
			{"name": "Trumpeting Charge", "cost_hp": 12, "power": 40, "description": "6 tonnes of mammoth at full charge. Devastating."},
		],
		"color": Color(0.45, 0.35, 0.25), "generation": 3,
		"portrait": "res://assets/img/portrait_dunkleosteus.png",
	}
