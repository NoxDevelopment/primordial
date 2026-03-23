# Game Plan: Primordial — A Scientific Evolution RPG

## Game Description

A top-down RPG inspired by 46 Okunen Monogatari (E.V.O.: The Theory of Evolution), but grounded in real paleontology and evolutionary science. The player begins as a primitive chordate in the Cambrian seas and evolves through 5 geological eras — Primordial Seas, Conquest of Land, Rise of Reptiles, Age of Dinosaurs, Age of Mammals — guided by Gaia, the spirit of Earth. Evolution is driven by 4 stats (Attack, Wisdom, Vitality, Endurance) earned through turn-based combat. Filling a stat to 100% triggers evolution along a real phylogenetic tree of 15-25 creatures per era. Each era ends with a mass extinction event that resets the player into the next age. The game features 100+ real prehistoric creatures, scientifically accurate evolution paths, and multiple endings depending on which evolutionary branch the player follows.

Art style: 16-bit SNES pixel art, top-down overworld, first-person turn-based combat encounters (Dragon Quest style).

## 1. Core Systems — Evolution Engine & Turn-Based Combat
- **Status:** pending
- **Depends on:** (none)
- **Targets:** scenes/main.tscn, scripts/game_manager.gd, scripts/evolution_system.gd, scripts/combat_system.gd, scripts/creature_data.gd, scripts/evo_stats.gd
- **Goal:** Build the two foundational systems: the evolution stat/tree engine and the turn-based combat system. This is the game's core loop — fight enemies, earn EVO Genes, distribute into 4 stats, evolve when a stat hits 100%.
- **Requirements:**
  - 4 EVO stats: Attack (fight damage), Wisdom (special abilities + escape), Vitality (max HP), Endurance (defense + terrain adaptation)
  - EVO Genes earned from combat victories and random disaster events
  - Evolution tree data structure: each creature has stat caps, and filling the highest-cap stat triggers vertical evolution (next generation), filling other stats triggers horizontal evolution (same-generation alternate form)
  - Turn-based combat: Fight (normal attack), Special (costs HP, unlocked by Wisdom), Escape (Wisdom-based chance), with first-person enemy portrait view
  - HP regeneration when standing still on overworld
  - Creature database with at least 5 test creatures for Era 1 (Pikaia, Anomalocaris, Cephalaspis, Dunkleosteus, Coelacanth) each with unique stats, sprites, special abilities, and encyclopedia text
  - Evolution chart UI showing current position on the tree
  - Walking on water damages the player (terrain hazard system)
  - Enemies 2+ generations behind stop spawning (time passing)
  - Dead-end evolutions show a flavor text "extinction story" game over
- **Verify:** Player can move on a test map, encounter an enemy, fight in turn-based combat, earn EVO Genes, open the evolution chart, distribute points into stats, and evolve into a different creature when a stat hits 100%. The evolution chart UI shows the player's position. Standing still regenerates HP.

## 2. Era 1 — The Primordial Seas (540-380 MYA)
- **Depends on:** 1
- **Status:** pending
- **Targets:** scenes/era1.tscn, scenes/build_era1.gd, scripts/era1_map.gd, assets/img/era1_*.png
- **Goal:** Build the first playable era — an underwater world spanning the Cambrian through Devonian periods. The player starts as Pikaia and can evolve through ~15 real sea creatures.
- **Requirements:**
  - Tile-based underwater overworld map with coral reefs, ocean floor, deep trenches, seaweed forests, thermal vents
  - 15 real creatures in the evolution tree: Pikaia → Haikouichthys → Arandaspis → Sacabambaspis → Astraspis → Cephalaspis → Pteraspis → Birkenia → Climatius → Cladoselache → Bothriolepis → Eusthenopteron → Panderichthys → Tiktaalik → Dunkleosteus (branches possible)
  - Enemy creatures: Anomalocaris, trilobites, eurypterids, nautiloids, jellyfish, Cameroceras
  - NPC dialogue from Gaia (tutorial, guidance)
  - Era transition: when player evolves a creature capable of air-breathing (Eusthenopteron/Tiktaalik), trigger the "Conquest of Land" cutscene
  - Environmental hazards: deep pressure zones, volcanic vents (random disasters that give EVO Genes)
  - Each creature has an encyclopedia entry with real scientific facts
- **Verify:** Complete underwater map with varied terrain tiles. Player starts as Pikaia, can fight enemies, evolve through multiple creatures, see encyclopedia entries, and trigger the era transition by reaching an air-breathing form.

## 3. HUD, Menus, and UI Polish
- **Depends on:** 1
- **Status:** pending
- **Targets:** scenes/hud.tscn, scenes/build_hud.gd, scripts/hud_controller.gd, scripts/menu_system.gd, scripts/encyclopedia.gd
- **Goal:** Build the game's UI layer: HUD overlay, pause menu, evolution chart screen, creature encyclopedia, and era transition screens.
- **Requirements:**
  - HUD: HP bar, EVO Genes counter, current creature portrait, era name
  - Pause menu: Save EVO, Load EVO, Display Speed, EVO History, EVO Encyclopedia
  - Evolution chart: visual tree showing all discovered creatures, current position highlighted, stat bars for each EVO stat with fill percentages
  - Encyclopedia: creature name, scientific name, era, size, diet, real-world facts
  - Era transition: dramatic screen with geological event description, era name, time period
  - Combat UI: enemy portrait (large), Fight/Special/Escape buttons, HP display, damage numbers
- **Verify:** HUD displays correctly during gameplay. Pause menu opens with all options. Evolution chart shows creature tree with current position. Encyclopedia shows creature info. Combat UI shows during battle.

## 4. Presentation Video
- **Depends on:** 1, 2, 3
- **Status:** pending
- **Targets:** test/presentation.gd, screenshots/presentation/gameplay.mp4
- **Goal:** Create a ~30-second cinematic video showcasing the completed Era 1 gameplay.
- **Requirements:**
  - Write test/presentation.gd — a SceneTree script (extends SceneTree)
  - Showcase: overworld exploration, enemy encounter, combat sequence, evolution moment, evolution chart UI
  - ~900 frames at 30 FPS (30 seconds)
  - Use Video Capture (AVI via --write-movie, convert to MP4 with ffmpeg)
  - Output: screenshots/presentation/gameplay.mp4
  - Camera pans across the underwater map, smooth transitions between gameplay moments
- **Verify:** A smooth MP4 video showing polished gameplay with no visual glitches.
