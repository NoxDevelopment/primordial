# Primordial — A Scientific Evolution RPG

## Dimension: 2D

## Input Actions

| Action | Keys |
|--------|------|
| move_up | W, Up |
| move_down | S, Down |
| move_left | A, Left |
| move_right | D, Right |
| interact | Space, Enter |
| menu | Escape |
| confirm | Space, Enter |
| cancel | Escape, X |

## Scenes

### Main
- **File:** res://scenes/main.tscn
- **Root type:** Node2D
- **Children:** Camera2D, TileMapLayer (terrain), Player, EnemySpawner, HUD (CanvasLayer)

### Player
- **File:** res://scenes/player.tscn
- **Root type:** CharacterBody2D
- **Children:** Sprite2D, CollisionShape2D, HealTimer

### Enemy
- **File:** res://scenes/enemy.tscn
- **Root type:** CharacterBody2D
- **Children:** Sprite2D, CollisionShape2D, DetectionArea (Area2D)

### CombatScreen
- **File:** res://scenes/combat_screen.tscn
- **Root type:** CanvasLayer
- **Children:** EnemyPortrait (TextureRect), CombatMenu (VBoxContainer), HPBar, DamageLabel, CombatLog

### EvolutionChart
- **File:** res://scenes/evolution_chart.tscn
- **Root type:** CanvasLayer
- **Children:** ChartPanel (Control), StatBars (4x ProgressBar), CreatureInfo, TreeView

### HUD
- **File:** res://scenes/hud.tscn
- **Root type:** CanvasLayer
- **Children:** HPBar (ProgressBar), EvoGenesLabel, CreaturePortrait (TextureRect), EraLabel

## Scripts

### GameManager
- **File:** res://scripts/game_manager.gd
- **Extends:** Node
- **Autoload:** yes (GameManager)
- **Signals emitted:** era_changed(era_id), creature_evolved(old_id, new_id), game_over(reason)
- **Responsibility:** Global game state, era transitions, save/load

### PlayerController
- **File:** res://scripts/player_controller.gd
- **Extends:** CharacterBody2D
- **Attaches to:** Player:Player
- **Signals emitted:** entered_combat(enemy_data), hp_changed(current, max)
- **Responsibility:** Movement, collision with enemies, HP regen when idle, terrain damage

### EnemyController
- **File:** res://scripts/enemy_controller.gd
- **Extends:** CharacterBody2D
- **Attaches to:** Enemy:Enemy
- **Responsibility:** Wander AI, despawn if 2+ generations behind player

### EvolutionSystem
- **File:** res://scripts/evolution_system.gd
- **Extends:** Node
- **Autoload:** yes (EvoSystem)
- **Signals emitted:** stats_changed(stats), evolved(creature_data), dead_end(story_text)
- **Responsibility:** 4 EVO stats, gene distribution, evolution tree traversal, vertical/horizontal evolution logic

### CreatureDatabase
- **File:** res://scripts/creature_database.gd
- **Extends:** Node
- **Autoload:** yes (CreatureDB)
- **Responsibility:** All creature definitions (stats, caps, abilities, encyclopedia text, sprite paths, evolution connections)

### CombatSystem
- **File:** res://scripts/combat_system.gd
- **Extends:** Node
- **Attaches to:** CombatScreen:CombatScreen
- **Signals emitted:** combat_ended(victory, evo_genes), player_hp_changed(hp), enemy_hp_changed(hp)
- **Responsibility:** Turn-based combat loop: Fight/Special/Escape, damage calc, EVO Gene rewards

### HUDController
- **File:** res://scripts/hud_controller.gd
- **Extends:** Control
- **Attaches to:** HUD children
- **Responsibility:** Display HP, EVO Genes, creature portrait, era name

### EvolutionChartController
- **File:** res://scripts/evolution_chart_controller.gd
- **Extends:** Control
- **Attaches to:** EvolutionChart children
- **Responsibility:** Show evolution tree, stat bars, distribute EVO Genes

### EnemySpawner
- **File:** res://scripts/enemy_spawner.gd
- **Extends:** Node2D
- **Attaches to:** Main:EnemySpawner
- **Responsibility:** Spawn enemies on map, filter by generation gap

## Signal Map

- Player:PlayerController.entered_combat -> GameManager._on_combat_start
- CombatSystem.combat_ended -> GameManager._on_combat_ended
- EvoSystem.evolved -> GameManager._on_creature_evolved
- EvoSystem.evolved -> HUDController._on_creature_evolved
- EvoSystem.stats_changed -> EvolutionChartController._on_stats_changed
- GameManager.era_changed -> EnemySpawner._on_era_changed

## Asset Hints

- Tileset: underwater ocean floor tiles (sand, coral, rock, seaweed, vent) — 16x16 or 32x32 pixel art
- Player creature sprites: 32x32 pixel art for each creature form (start with 5: Pikaia, Anomalocaris, Cephalaspis, Dunkleosteus, Eusthenopteron)
- Enemy sprites: 32x32 pixel art (trilobite, eurypterid, nautiloid, jellyfish)
- Enemy combat portraits: 128x128 pixel art (large first-person view for combat)
- UI elements: HP bar, stat bar frames, menu backgrounds, pixel font
- Evolution chart background: parchment/stone texture
