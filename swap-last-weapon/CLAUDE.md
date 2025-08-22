# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GZDoom/ZDoom mod that implements a "swap to last weapon" functionality for Doom. The mod allows players to quickly switch between their current weapon and the previously equipped weapon using a hotkey (default: Q key).

## Code Architecture

The mod consists of the following core components:

1. **Event System** (`zscript/lastswap.zs:1-14`): `LastWeaponEvent` handles player initialization, ensuring each player receives the necessary inventory items when entering the game.

2. **Weapon Tracking** (`zscript/lastswap.zs:16-45`): `LastWeaponTracker` continuously monitors the player's equipped weapon and maintains both the current and previous weapon classes.

3. **Weapon Swapping** (`zscript/lastswap.zs:47-69`): `LastWeaponActivator` handles the actual weapon swap when activated, checking weapon availability before switching.

## File Structure

- `KEYCONF` - Defines the keybinding configuration (Q key bound to swap_weapon alias)
- `ZMAPINFO` - Registers the event handler for the mod
- `zscript.txt` - Main ZScript entry point specifying version 4.8
- `zscript/lastswap.zs` - Core implementation of the weapon swapping logic

## Development Commands

### Testing the Mod
To test this mod with GZDoom:
```bash
# Load the mod with GZDoom (assuming GZDoom is in PATH)
gzdoom -file .

# Or if testing with a specific WAD
gzdoom -iwad doom2.wad -file .
```

### Packaging
To create a PK3/WAD file for distribution:
```bash
# Create a PK3 archive
zip -r swap-last-weapon.pk3 KEYCONF ZMAPINFO zscript.txt zscript/
```

## Key Technical Notes

- The mod uses ZScript version 4.8 features
- Weapon tracking occurs every tick via the `Tick()` override
- The system tracks weapon classes, not instances, to handle weapon respawns/pickups correctly
- The swap will fail silently if the player no longer has the previous weapon in inventory