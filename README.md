# Bagnon

A unified inventory and bank interface for World of Warcraft 1.12.1.

## Features

- **Unified Grid Display**: Combines all separate inventory and bank bags into a single, clean, resizable container window.
- **Offline Bank Viewing**: Inspect an exact cached snapshot of your bank contents and bank bags from anywhere in the world.
- **Live Free Slot Counter**: Header badge displays real-time free bag capacity (`24 / 96 Free`) with a detailed container-by-container tooltip breakdown.
- **Container Sorting**: One-click bag and bank cleanup powered by native engine sorting, with support for toggling packing direction.
- **Cross-Character Alt Inventory**: Tooltips display total counts for items held by any character on your realm.
- **Realm Gold Tracker**: Hovering over the currency display reveals aggregated gold across all your alts on the current realm.
- **Enchant Badges & Rarity Borders**: Color-coded rarity borders on all items, plus visual badges and duration indicators for temporary weapon enchants.
- **ItemRack & TrinketMenu Integration**: Tooltips display ItemRack set membership and TrinketMenu queue statuses for stored gear.

## Requirements

- **World of Warcraft 1.12.1** (Build 5875)
- [ClassicAPI v1.15.15+](https://github.com/brues-code/ClassicAPI) (`ClassicAPI.dll`)

> Note: Completely restart the game client after installing or updating DLLs. `/reload` cannot reload DLLs.

## Installation

1. Copy or clone this repository into your WoW add-on directory:
   ```text
   World of Warcraft/Interface/AddOns/Bagnon/
   ```
2. Verify that `Bagnon.toc` is located directly at `Interface/AddOns/Bagnon/Bagnon.toc`.
3. Launch WoW using your ClassicAPI-enabled client loader.
4. Ensure Bagnon is checked on the character selection AddOn screen.

## Commands & Shortcuts

| Command / Interaction | Description |
| :--- | :--- |
| `/bgn` or `/bagnon` | Open configuration options dialog |
| `/bgn bags` | Toggle unified inventory window |
| `/bgn bank` | Toggle unified bank window |
| `/bgn sort` | Sort bags (or bank if open) |
| `/bgn freespace` | Toggle live free bag space counter |
| `/bgn enchants` | Toggle weapon enchant badge overlays |
| `Left-Click` on Broom Icon | Sort current container window |
| `Right-Click` on Broom Icon | Toggle sort packing direction (Top-Left vs Bottom-Right) |
| `Hover` on Free Slots Badge | View per-container capacity breakdown |
| `Alt-Click` on Bag Slot Icon | Toggle sort ignore exclusion for that bag |
| `Right-Click` on Title Bar | Open frame settings (columns, scale, spacing, opacity) |
| `Shift-Click` on Bag Icon | Toggle visibility of that individual bag's slots |
| `Left-Click Drag` on Title Bar | Reposition the window |

## Limitations & Notes

- **Sorting Safety Guard**: Sorting containers when the backpack or main bank is excluded is temporarily disabled to prevent an upstream engine issue. Exclusion settings are preserved, and sorting with non-excluded containers operates normally.
- **Sorting Speed**: Sorting requests process through the server across multiple update ticks; allow the server a moment to complete item movements.

---

For detailed configuration, customization options, and layout controls, see the [User Guide](docs/USER_GUIDE.md). Technical architecture notes and review history are located under [docs/](docs/).

## License

MIT License. Authors: Tuller, McPewPew, [Fostercare5988](https://github.com/Fostercare5988). Maintained by Fostercare5988.
