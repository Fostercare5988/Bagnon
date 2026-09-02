# Bagnon

[![Version](https://img.shields.io/badge/Version-1.2.0-blue.svg)](https://github.com/Fostercare5988/Bagnon/releases)
[![Interface](https://img.shields.io/badge/Interface-1.12.1%20(Build%205875)-orange.svg)](https://github.com/Fostercare5988/Bagnon)
[![Engine](https://img.shields.io/badge/Engine-ClassicAPI%20%7C%20SuperWoW%20%7C%20NamPower%20%7C%20UnitXP%20%7C%20DXVK-green.svg)](https://github.com/Fostercare5988/Bagnon)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/Fostercare5988/Bagnon)

A high-performance, unified **bag and bank** engine for **World of Warcraft 1.12.1** engineered natively for the **Enhanced Client Extension Stack** (**ClassicAPI**, **SuperWoW 2.2+**, **NamPower 4.6.2+**, **UnitXP SP3**, and **DXVK**) created and maintained by **Fostercare5988**.

Bagnon merges all your inventory and bank bags into a single, clean window. It lets you view your bank from anywhere in the world, search for items by name with instant memoization, and inspect item counts and gold across all your alts on the realm.

![Bagnon Preview](assets/preview.jpg)

---

## ⚡ Quick Start & Slash Commands

You can use `/bgn`, `/bagnon`, or `/bo`:

* `/bgn` — Opens the main configuration options dialog.
* `/bgn bags` — Shows / hides your unified inventory window.
* `/bgn bank` — Shows / hides your unified bank window.
* `/bgn delete <character> [realm]` — Removes saved inventory data for a deleted or transferred character.
* `/bgn help` — Displays available slash commands.

### Key Shortcuts & Interactions:
* **Window Settings**: **Right-click** on the window title (e.g. *"Player's Inventory"*) to adjust columns, spacing, transparency, background color, and scale.
* **Instant Item Search**: **Double-click** on the window title to search for items. Press **Escape** or clear the box to reset the filter.
* **View Bank from Anywhere**: Click the **Bank Icon** at the bottom-left of your inventory window to view a cached snapshot of your bank.
* **Switch Character Views**: Click the **Arrow Dropdown** next to the title to inspect what your alts have in their bags or bank.
* **Filter / Hide Specific Bags**: **Shift-Click** any bag button at the bottom of the window to toggle its slots in and out of view.

---

## ✨ Core Features

* **Single Unified Window**: Replaces fragmented multiple bag windows with a clean, resizable grid.
* **Cached Bank Anywhere**: Access an exact offline snapshot of your bank slots and bank bags wherever you are.
* **Quality Border Highlighting**: Automatically tints item borders based on item rarity (Poor, Common, Uncommon, Rare, Epic, Legendary).
* **Color-Coded Special Bag Slots**:
  * 🟡 **Yellow**: Ammo and Soul shard pouches
  * 🟢 **Green**: Profession bags (Herbalism, Mining, Enchanting, Engineering)
  * 🟠 **Orange**: Keyring container
* **Cross-Character Alt Tracker**: Hover over any item in the world, trade window, auction house, or loot roll to see quantities across all characters on your realm (`[AltName] has 2 (Bags), 5 (Bank)`).
* **Realm Gold Aggregator**: Hover over the money display to view total aggregated gold across all your characters on the realm.
* **Optimized UI Defaults**: Pre-configured with 10 columns, a dark 85% opacity backdrop, and expanded bag bars out of the box.

---

## 💻 Technical Architecture & Zero-Bloat Optimizations

* **Strict Engine Dependency Guard**: Declares an active runtime requirement checking `CLASSIC_API_VERSION` and `SUPERWOW_VERSION` globals.
* **Zero-Overhead Item Slots**: Completely eradicated legacy per-button `OnUpdate` polling loops across all 120+ bag/bank item slots in favor of 100% event-driven updates (`BAG_UPDATE`, `BAG_UPDATE_COOLDOWN`, `ITEM_LOCK_CHANGED`).
* **Consolidated DRY Border & Quality Pipeline**: Unified duplicate 40-line border renderers into a single parameterized `BagnonItem_UpdateBorder(button, quality, player)` function.
* **O(1) Pre-Cached Widget Pointers**: Item buttons directly cache `.border`, `.cooldown`, `.normalTexture`, `.iconTexture`, and `.countText` references on load, eliminating runtime string concatenation and `getglobal()` overhead during rendering passes.
* **Consolidated Single-Package Architecture**: Merged legacy multi-folder dependencies (`Bagnon_Core`, `Bagnon_Forever`, `Bagnon_Spot`, `Bagnon_Options`) into a single, self-contained, ultra-lean addon.
* **Fast O(1) Offline Item Lookups**: Direct raw string parsing in `BagnonDB.GetItemTotal`, skipping redundant texture lookups and `GetItemInfo` queries during tooltip hovers.
* **Memoized Substring Search Engine**: In-memory LRU cache for normalized item names, ensuring zero garbage collection churn during rapid typing in the search box.
* **Crash-Free Exact Pattern Matching**: Uses exact plain-text substring searches (`string.find(..., 1, true)`), eliminating Lua parser crashes when searching for items containing brackets, braces, or arithmetic symbols (`[`, `]`, `+`, `-`).
* **Smooth DXVK Animations**: Hardware-synchronized cooldown spirals and frame repositioning with zero frametime jitter under Vulkan.

---

## 📦 Installation & Requirements

1. **Requirements**:
   - **World of Warcraft 1.12.1** (Build 5875).
   - [**ClassicAPI**](https://github.com/brues-code/ClassicAPI) (`ClassicAPI.dll`).
   - [**SuperWoW**](https://github.com/balakethelock/SuperWoW) (`SuperWoW.dll` v2.2+).
   - [**NamPower**](https://github.com/Emyrk/nampower) (`nampower.dll` v4.6.2+).
   - [**UnitXP SP3**](https://codeberg.org/konaka/UnitXP_SP3) (`UnitXP_SP3.dll`).
   - [**DXVK**](https://github.com/doitsujin/dxvk) & [**VanillaFixes**](https://github.com/hannesmann/vanillafixes).
2. **Installation**:
   - Place the `Bagnon` folder into:
     ```text
     World of Warcraft/Interface/AddOns/Bagnon/
     ```
   - Ensure `Bagnon.toc` is directly inside `Interface/AddOns/Bagnon/`.
   - Enable **Bagnon** in your AddOn list at character selection.

---

## 👥 Credits & Attribution

* **Tuller** — Original creator and developer of Bagnon, Banknon, Bagnon_Forever, and Bagnon_Spot.
* **McPewPew** — Created the single-folder build for Turtle WoW / Vanilla launcher and added the quick bank viewer button.
* **Fostercare5988** — Modernization, Enhanced 1.12.1 Engine Stack refactoring, zero-bloat optimizations, bugfixes, UI defaults, and repository maintenance.

---

## 📜 Changelog

### v1.2.0
* **Native Memory Operations**: Integrated native C++ `table.wipe` for instant garbage-free search cache clearing (`BagnonSpot_ClearSearch`).
* **ClassicAPI Source-Rewriter AST Syntax**: Modernized layout calculation math to native modulo `%` operator.
* **Universal Engine Stack Standardization**: Upgraded startup dependency guard to inspect `CLASSIC_API_VERSION` and `SUPERWOW_VERSION` globals.
* **Standard Open-Source Release**: Normalized TOC title and metadata (`X-Category`, `X-Website`) with comprehensive documentation under Master System Prompt Rule H5.

### v1.1.0
* Eradicated per-slot `OnUpdate` polling overhead across all 120+ bag/bank item buttons.
* Consolidated `BagnonItem_UpdateBorder` and `BagnonItem_UpdateLinkBorder` into a single unified DRY rendering function.
* Consolidated repetitive options event triggers in `Options.lua` using a generic helper.
* Net reduction of 137 lines of legacy boilerplate and dead code across the codebase.

### v1.0.0
* Initial release of the streamlined single-folder edition.
* Pre-configured default UI settings: 10 columns, 85% opacity, dark background, and expanded bag bar.
* High-performance zero-GC item border color rendering and widget caching.
* Fast O(1) offline database alt-item scanning for tooltips.
* Memoized crash-free search engine supporting symbols and brackets.
* Fixed cooldown animation updates for open bag and bank windows.
