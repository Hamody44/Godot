# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**Dungeon Escape** is a 2D platformer game built with Godot 4.5 using GDScript. The player controls an adventurer navigating through dungeon levels, fighting enemies (skeletons and venoms), and progressing through multiple levels to escape.

## Development Commands

### Running the Project
- Open the project in Godot 4.5 editor and press F5, or use the Play button
- The main scene is defined in `project.godot` as `uid://0aos1h7rpr3r`
- Starting screen: `res://scenes/start.tscn`

### Project Structure
- **Scenes**: `.tscn` files in `scenes/` directory
- **Scripts**: `.gd` files colocated with scenes in `scenes/` or in `scripts/` directory  
- **Assets**: Located in `assets/` with subdirectories for different asset packs

## Architecture

### Scene Hierarchy
The game uses a level-based scene structure:
- **start.tscn**: Main menu/starting screen
- **level_1.tscn, level_2.tscn, level_3.tscn**: Playable levels
- **end.tscn**: End screen after completing all levels
- **player.tscn**: Player character (instantiated in levels)
- **skeleton.tscn**: Skeleton enemy (instantiated in levels)
- **venom.tscn**: Venom enemy (instantiated in levels)

### Core Game Systems

#### 1. Player System (`player.gd`)
- **Movement**: WASD/Arrow keys for horizontal movement, Space for jump
- **Combat**: Left mouse click for attack (ground and air variants)
- **Health**: 3 HP, displayed via Label node in level scenes
- **State Management**: Tracks attacking, dead, cooldowns
- **Attack Range**: 80 pixels to hit enemies in range

Key mechanics:
- Attack cooldown: 0.5 seconds
- Jump velocity: -400
- Movement speed: 300
- Death triggers scene reload after 2-second delay

#### 2. Enemy AI System
Both `skeleton.gd` and `venom.gd` share similar AI patterns:

**Skeleton Enemy**:
- Speed: 150
- Health: 1 HP
- Damage: 1 HP per attack
- Detection range: 200 pixels
- Attack range: 50 pixels
- Attack cooldown: 2 seconds

**Venom Enemy**:
- Speed: 100 (slower than skeleton)
- Health: 1 HP
- Damage: 2 HP per attack (more dangerous)
- Detection range: 200 pixels
- Attack range: 50 pixels
- Attack cooldown: 2 seconds

AI Behavior Flow:
1. Idle when player is out of detection range
2. Chase player when within detection range
3. Attack when within attack range and cooldown complete
4. Play death animation and queue_free() when health reaches 0

#### 3. Level Progression System (`door.gd`)
- Doors are Area2D nodes that detect player collision
- Automatically loads next level (level_1 → level_2 → level_3 → end)
- Uses ResourceLoader.exists() to check if next level exists
- Falls back to `end.tscn` when no more levels exist

#### 4. Manager Singleton (`manager.gd`)
- Autoloaded globally (defined in project.godot)
- Currently minimal implementation
- Use this for global game state, score tracking, or cross-scene data

### Group System
The game uses Godot's group system for entity management:
- **"player"** group: Player character (for enemy targeting and door detection)
- **"enemy"** group: All enemy types (for player attack targeting)

### Animation System
All entities use AnimatedSprite2D with SpriteFrames:
- **Player animations**: idle, run, jump, attack, air_attack, death
- **Enemy animations**: idle, walk, attack, death
- Sprites are flipped horizontally based on movement direction

### Physics and Collision
- Uses CharacterBody2D for player and enemies
- TileMapLayer for level terrain with physics_layer_0 collision
- Area2D for interactive elements (doors, enemy attack zones)
- Gravity applied via `get_gravity()` when not `is_on_floor()`

## Asset Organization

```
assets/
├── 2D Pixel Dungeon Asset Pack v2.0/  # Tileset and dungeon assets
│   └── 2D Pixel Dungeon Asset Pack/
│       ├── character and tileset/
│       ├── Character_animation/
│       ├── interface/
│       └── items and trap_animation/
├── Adventurer-1.5/                     # Player sprites
│   └── Individual Sprites/
└── Enemy_Animations_Set/               # Enemy sprites
    └── Enemy_Animations_Set/
```

## Input Configuration

Defined in `project.godot`:
- **right**: D key, Right Arrow
- **left**: A key, Left Arrow  
- **jump**: Space key
- **attack**: Left Mouse Button

## Coding Conventions

- **Language**: GDScript (Godot 4.5 syntax)
- **Node references**: Use `@onready` for child node caching
- **Naming**: snake_case for variables/functions, PascalCase for class names
- **Constants**: UPPER_SNAKE_CASE
- **Signal naming**: Use descriptive past-tense names (e.g., `health_changed`)
- **Type hints**: Use static typing (`var name: Type`, `func name() -> Type`)
- **Groups**: Add nodes to groups in _ready() with `add_to_group("group_name")`
- **Async operations**: Use `await` for timers and animation delays
- **Comments**: Some Arabic comments exist in the codebase (particularly in enemy scripts)
- **Null safety**: Always check node references before use (e.g., `if label:` before `label.text = ...`)
- **Instance validation**: Use `is_instance_valid()` when checking references to nodes that might be freed
- **Physics callbacks**: Never change scenes or free nodes directly in physics callbacks (e.g., `_on_body_entered`). Use `call_deferred()` instead to defer the action until after the physics step completes

## Common Development Patterns

### Adding a New Enemy
1. Create new scene extending CharacterBody2D
2. Add AnimatedSprite2D with attack/walk/death animations
3. Add collision shapes (main body + Area2D for attacks)
4. Create script following skeleton.gd pattern
5. Add to "enemy" group in _ready()
6. Implement: handle_ai(), chase_player(), attack_player(), take_damage(), die()
7. Instance in level scenes

### Adding a New Level
1. Create `level_N.tscn` following existing level structure
2. Add TileMapLayer with physics collision
3. Instance player at spawn point
4. Add enemies and door Area2D
5. Door system will automatically detect and load it

### Modifying Player Stats
Key constants in `player.gd`:
- `SPEED`: Movement speed
- `JUMP_VELOCITY`: Jump height (negative value)
- `ATTACK_COOLDOWN_TIME`: Time between attacks
- `max_health`: Maximum HP
- `ATTACK_RANGE`: Attack reach in pixels

## Scene Script Colocations

- `scenes/player.tscn` → `scenes/player.gd`
- `scenes/skeleton.tscn` → `scenes/skeleton.gd`
- `scenes/venom.tscn` → `scenes/venom.gd`
- `scenes/door.gd` → Used as script on Area2D nodes in level scenes
- `scripts/manager.gd` → Autoloaded singleton
- `scripts/texture_button.gd` → UI button handler for start screen
