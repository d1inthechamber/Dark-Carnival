# Dark Carnival — Project Status

> Milestone tracker. It changes only when real project work is committed.

## Current milestone

**Build 0.4 — Visual demo foundation**

`[███████░░░] 70%`

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
- Godot validation workflow passes on the current main branch
- Main scene refactored into reusable comic UI components
- Comic encounter frame, HUD bar, choice panel, card-hand shell, and transition FX scene added
- Neon controller-focus styling and impact flashes integrated into the playable loop
- Visual bible and first-demo art asset checklist committed

### In progress / validation needed
- Replace encounter-panel placeholders with final illustrated Carnival of Carnage art
- Add authoritative recurring mascot/brand assets where appropriate
- Build illustrated versions of the first four playable cards
- Add layered animation/parallax, card motion, Faygo spray, mirror distortion, and page/ink transitions
- Regression-test every encounter branch with the new visual shell
- Improve remaining controller edge cases and focus transitions
- Package a clearly downloadable first-demo build

### First user-facing demo gate
The demo is considered ready only when the complete gate → pickpocket → midway → mirror maze → finale → judgment loop works without a blocking error **and** the visual presentation is representative of the intended finished game: gritty supernatural horror-comic panels, selective neon carnival color, illustrated cards, readable controller-first UI, and noticeable motion/impact polish.

## Larger roadmap

`[██░░░░░░░░] Early production`

1. Carnival of Carnage visual demo
2. Ringmaster
3. Riddle Box
4. The Great Milenko
5. The Amazing Jeckel Brothers
6. The Wraith
