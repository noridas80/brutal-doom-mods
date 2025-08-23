# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GZDoom/ZDoom mod that implements a "swap to last weapon" functionality for Doom. The mod allows players to quickly switch between their current weapon and the previously equipped weapon using a hotkey (default: Q key).

## Code Architecture

The mod consists of three interconnected components implemented in `zscript/lastswap.zs`:

1. **Event Handler** (`LastWeaponEvent`, lines 1-14): Initializes the tracking system when players enter the game by giving them the necessary inventory items.

2. **Weapon Tracker** (`LastWeaponTracker`, lines 16-84): 
   - Monitors weapon changes with a 10-tick update delay to avoid rapid switching issues
   - Maintains `CurrClass` (current weapon) and `PrevClass` (previous weapon) 
   - Uses `ExpectedWeapon` to handle swap transitions properly
   - Prevents duplicate tracking when swapping back and forth

3. **Swap Activator** (`LastWeaponActivator`, lines 86-121):
   - Triggered by the Q key via the `Use` method
   - Validates weapon availability before switching
   - Immediately swaps the current/previous weapon references after initiating the switch
   - Sets `ExpectedWeapon` to prevent the tracker from incorrectly updating during the transition

## File Structure

- `KEYCONF` - Defines the keybinding configuration (Q key bound to swap_weapon alias)
- `ZMAPINFO` - Registers the event handler for the mod
- `zscript.txt` - Main ZScript entry point specifying version 4.8
- `zscript/lastswap.zs` - Core implementation of the weapon swapping logic

## Key Implementation Details

- **Update Delay**: The tracker uses a 10-tick delay (`updateDelay`) to prevent rapid updates during weapon transitions
- **Swap State Management**: The `ExpectedWeapon` field prevents the tracker from misinterpreting player-initiated swaps as manual weapon changes
- **Class Tracking**: Tracks weapon classes (not instances) to handle weapon pickups/drops correctly
- **Immediate State Swap**: After initiating a swap, the tracker immediately exchanges `CurrClass` and `PrevClass` to maintain correct state

## Development Commands

### Testing the Mod
```bash
# Load the mod with GZDoom (assuming GZDoom is in PATH)
gzdoom -file .

# Test with a specific IWAD
gzdoom -iwad doom2.wad -file .

# Test with debug output (if needed)
gzdoom -file . +logfile debug.log
```

### Packaging for Distribution
```bash
# Create a PK3 archive
zip -r swap-last-weapon.pk3 KEYCONF ZMAPINFO zscript.txt zscript/

# Verify the archive structure
unzip -l swap-last-weapon.pk3
```

## Technical Requirements

- ZScript version 4.8 or higher
- GZDoom 4.8.0 or later
- Compatible with multiplayer (each player gets their own tracker instance)