# Bagnon

A unified inventory and bank for World of Warcraft 1.12.1.

## Features

- One adjustable window for your bags and one for your bank.
- Cached inventory and bank views for your other characters on the same realm.
- Free-space totals with a per-container breakdown.
- Native bag sorting, packing direction and container exclusions.
- Item quality borders and temporary weapon-enchant indicators.
- Item-count tooltips across characters and optional GearRack set information.

## Requirements

WoW 1.12.1, build 5875, with [ClassicAPI 1.15.15 or later](https://github.com/brues-code/ClassicAPI).

## Installation

Download **Bagnon-1.0.0.zip** from [Releases](https://github.com/Fostercare5988/Bagnon/releases).
Extract the `Bagnon` folder into `Interface/AddOns`. The TOC belongs at
`Interface/AddOns/Bagnon/Bagnon.toc`. Start your enhanced client and enable Bagnon.

## Controls

| Action | Control |
| --- | --- |
| Toggle bags | Your normal bag key, `/bgn bags` or `/bagnon bags` |
| Toggle bank or cached bank | `/bgn bank` |
| Open options | `/bgn` or `/bagnon` |
| Open window settings | Right-click the title bar |
| Move a window | Drag its title bar or free-space label |
| Show or hide a container | Shift-click its bag icon |
| Sort the current window | Click the broom or use `/bgn sort` |
| Change packing direction | Right-click the broom |
| Exclude a container from sorting | Alt-click or right-click its bag icon |
| View free space by container | Hover over the free-space label |

Cached views are read-only. Visit a banker to move or sort bank items.
Sorting is blocked when the backpack or main bank container is excluded.
Other container exclusions remain available. Let sorting finish before moving
items manually.

See the [user guide](docs/USER_GUIDE.md) for appearance, cached characters and indicators.
