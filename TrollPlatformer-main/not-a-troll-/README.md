# NOT A TROLL – Minimalist 2D Platformer

## Overview
A small **Godot 4** platformer inspired by the "Level Devil" concept.  The game features a single‑player character that can run, jump, and interact with a series of troll‑style obstacles across four sequential levels.  A clean main menu (Play / Quit) is built using the provided assets, and the player sprite uses a custom spritesheet.

## Assets (provided by the user)
- `assets/menu_background.jpg` – background image for the main menu.
- `assets/menu_buttons.jpg` – button sheet containing Play and Quit button states (normal, hover, pressed).
- `assets/spritesheet.jpg` – pixel‑art spritesheet for the player character (idle, run, jump, fall, hurt, defeated, victory).

Only the above assets are used; no extra textures or scripts are introduced.

## Project Structure
```
not-a-troll-
│   project.godot               # Godot project file
│   README.md                  # <-- this file
│
├───assets
│       menu_background.jpg
│       menu_buttons.jpg
│       spritesheet.jpg
│
├───scenes
│       MainMenu.tscn          # Main menu UI
│       player.tscn            # Player scene with AnimatedSprite2D
│       Level1.tscn … Level4.tscn
│       ExitDoor.tscn
│       GameOver.tscn
│       ... (other level objects)
│
└───scripts
        Main_menu.gd          # UI logic (Play / Quit)
        player.gd             # Player controller, state machine, troll interactions
        exit_door.gd          # Door logic, level transition, optional key lock
        level_1.gd … level_4.gd
        extract.gd             # Helper script (not used at runtime)
```

## Controls
| Action | Key |
|--------|-----|
| Move Left | **A** (or Left Arrow) |
| Move Right | **D** (or Right Arrow) |
| Jump | **W**, **Space**, or **Up Arrow** |
| Invert Controls (troll) | Toggle `controls_inverted` in the inspector |
| Lock Input (troll) | Toggle `input_locked` in the inspector |

## How to Run
1. **Open the project** in Godot 4.x:
   - Launch Godot.
   - Click **Import** → select `project.godot` located in the `not-a-troll-` folder.
2. **Run the game** (play button). The main menu appears.
   - Press **Play** to start Level 1.
   - Press **Quit** to close the application.
3. **From the command line** (optional):
   ```powershell
   cd "C:\Users\natha\OneDrive\Desktop\TrollPlatformer-main\TrollPlatformer-main\not-a-troll-"
   godot --path . --scene res://scenes/MainMenu.tscn
   ```
   Add `--quit` after a single run if you only need a quick sanity check.

## Gameplay Flow
1. **Main Menu** → loads `Level1.tscn`.
2. Each level contains an **ExitDoor** (`scripts/exit_door.gd`). When the player touches it, the door opens, emits a `door_entered` signal, and after a short delay loads the next level via `next_scene_path`.
3. **Level 4**’s door points back to the main menu (or you can change it to a victory screen).
4. If the player falls below the death boundary or triggers a lethal obstacle, `player.gd` calls `die()` and switches to `GameOver.tscn`.

## Tweaking & Extending
- **Add new obstacles**: create a scene (e.g., a spike or spring) and instance it in any level. Hook into the player's public methods (`bounce()`, `launch()`, `take_hit()`).
- **Lock a door**: set `requires_key` to `true` on an `ExitDoor` and give the player a `Key` node that sets `has_key = true` when collected.
- **Modify player speed**: edit the exported variables (`speed`, `jump_velocity`, etc.) in the inspector or directly in `player.gd`.
- **Swap the spritesheet**: replace `assets/spritesheet.jpg` and update the atlas region rectangles in `scenes/player.tscn`.

## Known Issues / TODO
- No sound effects are attached; consider adding `AudioStreamPlayer`s for button clicks, jumps, and door opening.
- The `extract.tscn` and `extract.gd` were used only for a one‑off slicing experiment and are not required at runtime.
- Level design is minimal; feel free to expand the geometry or add more troll‑style traps.

---
*Created with the help of Google Antigravity (AGY) – a code‑centric AI assistant.*

