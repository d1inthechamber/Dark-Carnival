# Dark Carnival

A choice-driven survival journey prototype built in Godot 4, inspired by classic trail/resource-management games and set inside a supernatural traveling carnival.

## Current playable slice

The Carnival of Carnage level is being expanded into a complete first-level loop. The current main branch includes:

- Player-defined town and player name
- Carnival entrance and locked-gate opening
- Health, Resolve, Cash, Food, Faygo and Ticket resources
- Hidden morality traits and persistent event-history tracking
- Branching pickpocket/carnival-worker encounter
- Playable card hand with Hatchet, Faygo Break, Carnival Sight and Back Door effects
- Midway bottle-game encounter with fair, dishonest and compassionate routes
- Mirror-maze encounter and onward level progression
- Mouse/keyboard plus controller-first navigation
- Controller text entry via an on-screen keyboard
- Controller rumble hooks for major impacts
- Replay/reset loop

## Run the development build

1. Install Godot 4.7.x.
2. Clone or download this repository.
3. In Godot Project Manager choose **Import**, then select `project.godot`.
4. Open the project and press **F6/F5** (or the Play button).

The project starts at `res://scenes/Main.tscn`.

## Controller layout

- D-pad / left stick: navigate focused choices
- A / Cross: confirm the focused choice
- B / Circle: back/cancel where supported
- LB / RB: cycle choices
- Y / Triangle: quick-open cards during supported encounters
- Town/name entry: choose **CONTROLLER KEYBOARD** to enter text without a physical keyboard

The UI is designed to preserve visible focus so the level can be completed from a controller without reaching for a mouse.

## First-level acceptance target

The first public test is considered ready only when the Carnival of Carnage path can be played from town entry through a clear level ending without dead ends, core resource changes remain coherent, controller and mouse/keyboard paths both work, and the project opens cleanly in Godot 4.7.x.

## Roadmap

After Carnival of Carnage: Ringmaster, Riddle Box, The Great Milenko, The Amazing Jeckel Brothers and The Wraith.

This repository is an early fan-game prototype. Third-party names, characters, marks, likenesses, and lore remain the property of their respective owners. Commercial distribution would require appropriate permissions/licensing.
