# Carnival of Carnage — Demo Art Asset Checklist

This list is ordered by what most improves the first playable demo.

## Tier 1 — Must exist before the user-facing demo

### Global UI
- [ ] Authoritative Hatchet Man mascot/logo asset, cleaned for game use
- [ ] Main title treatment
- [ ] Comic panel border kit: wide, narrow, torn, impact
- [ ] Choice-button normal/focus/pressed treatment
- [ ] HUD frame/background
- [ ] Card back design
- [ ] Ticket icon
- [ ] Faygo bottle/resource icon treatment
- [ ] Health and Resolve icon treatment
- [ ] Ink splatter / halftone / paper texture overlays

### Opening / Gates
- [ ] Town-at-night establishing panel with carnival glow arriving behind familiar streets
- [ ] Carnival gate hero panel
- [ ] Silent gate-clown encounter panel
- [ ] Gate slam impact frame
- [ ] Locked-gate close-up

### Pickpocket sequence
- [ ] Crowded midway establishing panel
- [ ] Pickpocket shoulder-hit panel
- [ ] Chase panel
- [ ] Carnival worker catches thief panel
- [ ] Intervention / confrontation panel
- [ ] Aftermath panel

### Card system — first four cards
- [ ] HATCHET card illustration
- [ ] FAYGO BREAK card illustration
- [ ] CARNIVAL SIGHT card illustration
- [ ] BACK DOOR card illustration
- [ ] Card selection glow/focus frame
- [ ] Card slam impact overlay

### Midway bottle game
- [ ] Bottle-game booth establishing panel
- [ ] Booth operator portrait/panel
- [ ] Milk-bottle target panel
- [ ] Stuffed rabbit prize
- [ ] Girl watching prize panel
- [ ] Bottle-break / win impact frame

### Mirror maze
- [ ] Mirror-maze exterior
- [ ] Interior warped reflection panel
- [ ] Reflection-knocking-on-glass panel
- [ ] Broken mirror impact frame
- [ ] Exit seam / cold-night-air panel

### Finale / judgment
- [ ] Backside-of-midway locked exit panel
- [ ] Brass ticket reader close-up
- [ ] Lights-out transition frame
- [ ] Dawn-over-player-town ending panel
- [ ] Final judgment card/back panel

## Tier 2 — Animation layers

- [ ] slow Ferris-wheel rotation
- [ ] flickering sign lights
- [ ] drifting foreground fog
- [ ] paper/ink parallax layers
- [ ] subtle character idle motion
- [ ] card flip
- [ ] card slam
- [ ] neon impact flash
- [ ] ink-wipe transition
- [ ] comic panel tear/page transition
- [ ] Faygo spray particles
- [ ] mirror distortion shader or animated overlay
- [ ] exit-gate shake

## Tier 3 — Audio-reactive visual hooks

- [ ] gate CLANG screen/panel hit
- [ ] card impact pulse
- [ ] bottle crash pulse
- [ ] mirror shatter pulse
- [ ] ticket reader pulse
- [ ] level-complete visual sting

## Suggested source sizes

Background encounter art:
- master: 2560×1440 or larger
- safe composition for 16:9
- leave clear negative-space zones for dialogue/UI

Character panels:
- master height: 1600–2400 px
- transparent background where useful
- keep hands/important props fully inside frame unless intentionally cropped

Cards:
- master: 1024×1536
- consistent border/safe zone
- title and gameplay text should be rendered by Godot where practical rather than baked into generated art

Icons:
- master: 512×512 transparent PNG
- readable at 32–64 px

## File naming

Use lowercase snake_case:
- `coc_gate_establishing.png`
- `coc_pickpocket_hit.png`
- `card_hatchet.png`
- `card_faygo_break.png`
- `fx_ink_splatter_01.png`

Store final game art under:
- `assets/art/carnival_of_carnage/`
- `assets/cards/`
- `assets/ui/`
- `assets/fx/`

## Acceptance test for every generated illustration

Before committing:
1. Does it clearly belong to this exact game?
2. Does it avoid generic AI fantasy composition?
3. Are hands, props, logos, face paint, and text correct?
4. Is the palette purposeful rather than rainbow neon?
5. Does the crop leave room for gameplay UI?
6. Does it preserve visual continuity with the previous panel?
7. Would the image still look interesting in black-and-white inks?
8. Can useful parts be separated into animation layers?
