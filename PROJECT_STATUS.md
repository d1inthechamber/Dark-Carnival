# Dark Carnival — Project Status

> Milestone tracker. It changes only when real project work is committed.

## Current milestone

**Build 0.3 — Carnival of Carnage vertical slice**

`[████████░░] 80%`

### Complete
- Godot project boots from `scenes/Main.tscn`
- Town and player-name setup, including controller virtual keyboard
- Core HUD/resources: Health, Resolve, Cash, Food, Faygo, Tickets
- Hidden morality and choice-history tracking
- Branching locked-gate and pickpocket encounters
- Four-card hand prototype with Faygo interaction
- Midway bottle game with fair, dishonest, generous, and skip routes
- Mirror-maze encounter whose outcome reacts to prior morality
- Multiple exit routes and end-of-level Carnival judgment
- Controller navigation foundation, shoulder cycling, back behavior, card shortcut, rumble
- Godot 4.7.1 headless validation workflow committed

### In progress / validation needed
- Confirm the new GitHub Actions Godot check runs successfully
- Regression-test every encounter branch in Godot 4.7.x
- Improve controller edge cases and focus transitions
- Visual/UI pass so the vertical slice feels like a game rather than a systems prototype
- Package a clearly downloadable first-test build

### First playable-test gate
The test is considered ready only after the Godot validation passes and the complete gate → pickpocket → midway → mirror maze → finale → judgment loop has been regression-tested without a blocking error.

## Larger roadmap

`[██░░░░░░░░] Early production`

1. Carnival of Carnage vertical slice
2. Ringmaster
3. Riddle Box
4. The Great Milenko
5. The Amazing Jeckel Brothers
6. The Wraith
