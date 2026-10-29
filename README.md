# TrollPlatformer

A 2D precision trap platformer built with **Godot 4 (GDScript)**, inspired by *Level Devil*. Designed around a minimalist cavern aesthetic, the game looks like a straightforward corridor run—until the floor vanishes, the ceiling drops, and the exit door turns against you.

## Overview

**TrollPlatformer** tests player reflexes and pattern memorization across a multi-stage gauntlet. Every level introduces proximity-triggered environmental hazards designed to subvert standard platforming instincts. Dying is instant, respawns are immediate, and every death is tracked.

## Key Features

* **Proximity-Triggered Traps:** Dynamic floor bridges, pop-up spikes, falling stalactites, sliding hazard rows, and ceiling crushers triggered by player coordinates.
* **Deceptive Objectives:** Exit doors that slide away on approach, require hidden keys, or transform into lethal mimic traps.
* **4-Level Gauntlet Progression:**
  * **Level 1 – The Sudden Pit & Hidden Spikes:** Dropping bridge sections and last-second floor spikes before the exit.
  * **Level 2 – Falling Spikes & Runaway Door:** Overhead stalactite ambushes and an exit door that relocates as the floor opens beneath it.
  * **Level 3 – Crumbling Bridge, Crusher & Fake Door:** Sequential crumbling blocks over a spike pit, a high-speed piston crusher, and a fake door ambush that spawns the real exit back at the start.
  * **Level 4 – The Troll Gauntlet:** Bait spring launchers positioned under ceiling spikes, horizontally sliding spike rows, and a synchronized dropping floor/lowering ceiling finale.
* **Instant Respawn Loop:** Zero-loading-screen resets on death with a persistent level and death counter HUD.
* **Custom 2D Pixel Art:** High-contrast silhouette character animations, modular cave autotiles, interactive door states, and hazard sprites.

## Controls

| Action | Keys |
| :--- | :--- |
| **Move Left / Right** | `Left Arrow` / `Right Arrow` (or `A` / `D`) |
| **Jump** | `Up Arrow` / `Space` / `Enter` |
| **Restart Run** | `R` |

## Tech Stack

* **Engine:** Godot Engine 4.x
* **Language:** GDScript
* **Resolution:** `1152 x 648` (2D Pixel-Art Import Preset / Filter Disabled)

## Getting Started

1. Clone this repository:
   ```bash
   git clone [https://github.com/](https://github.com/)<your-username>/TrollPlatformer.git
