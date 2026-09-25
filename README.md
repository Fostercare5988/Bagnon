# Bagnon

[![Interface: 1.12.1](https://img.shields.io/badge/Interface-1.12.1%20(5875)-orange.svg)](https://github.com/Fostercare5988/Bagnon)
[![Version: 2.0.1](https://img.shields.io/badge/Version-2.0.1-blue.svg)](https://github.com/Fostercare5988/Bagnon/releases)
[![ClassicAPI: v1.15.13+](https://img.shields.io/badge/ClassicAPI-v1.15.13+-green.svg)](https://github.com/brues-code/ClassicAPI)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Bagnon v2.0.1** is an inventory and bank engine engineered natively for **World of Warcraft 1.12.1 (Build 5875)** running on the **Enhanced Client Extension Stack** (**ClassicAPI v1.15.13+**).

Bagnon merges all fragmented inventory and bank bags into a unified, resizable grid. It enables remote bank viewing from anywhere in the world, memoized instant substring search, cross-character alt item aggregation on tooltips, total realm gold tracking, and modern one-click bag and bank sorting.

Created and actively maintained by **[Fostercare5988](https://github.com/Fostercare5988)**.

---

## 📸 Preview

![Bagnon Overview](assets/preview.jpg)

---

## 🚀 Engine Architecture & Performance

Bagnon is engineered around direct engine integration:

| Engine Component | Minimum Version | Architectural Role & Implementation |
| :--- | :--- | :--- |
| **ClassicAPI** | `v1.15.13+` | C++ hardware timers (`C_Timer.After`), modern EditBox text manipulation, native `table.wipe` memory recycling, native container sorting with Baganator-style equipment slot grouping (`C_Container.SortBags`, `C_Container.SortBankBags`), and source-rewritten Lua 5.1 syntax. |

### Elimination of 2006 Legacy Techniques
- **Zero OnUpdate Polling**: Eradicated legacy per-button `OnUpdate` polling loops across all 120+ bag/bank item slots; item slot states update exclusively on native events (`BAG_UPDATE`, `BAG_UPDATE_COOLDOWN`, `ITEM_LOCK_CHANGED`).
- **Pre-Cached Item Slot Arrays**: Replaced per-frame string concatenations and `getglobal` lookups with direct `frame.items[slot]` array caching across `Bagnon` and `Banknon`.
- **Direct Cooldown Loop Traversals**: Refactored `BAG_UPDATE_COOLDOWN` to iterate directly across pre-cached item arrays, eliminating string allocations during cooldown ticks.
- **In-Place Search Highlighting**: Optimized `spot/spot.lua` to update slot alphas directly in-place without triggering layout recalculations or rebuilding container geometry.
- **O(1) Alt Inventory Tooltip Cache**: Introduced memoized `playerTotalsCache` in `database/database.lua`, replacing $O(\text{alts} \times \text{slots})$ regex scans with $O(1)$ lookups on tooltip hover.
- **Tooltip Composition**: Adds historical holdings and optional ItemRack/TrinketMenu lines after item tooltip calls, using their read-only queries and clearing line guards when the tooltip resets.
- **Lazy Weapon Enchant Overlays**: Eliminated >600 eagerly allocated overlay UI elements across 120+ bag and bank slots, instantiating overlays on-demand only for weapons in bag slots `0..4`.
- **Library Modernization & Dead Code Elimination**: Removed obsolete wrapper libraries (`lib/Infield.lua`, `lib/TLib.lua`) in favor of native ClassicAPI frame methods and clean event dispatching; purged unused startup item queries and legacy `MerchantRepairAllIcon` tampering.
- **Strict Mouse Passthrough (Rule C8)**: Cooldown model frames (`item.cooldown`) have mouse capture explicitly disabled (`EnableMouse(false)`), guaranteeing 100% of the item slot square captures clicks, drag operations, and item splits without dead zones.
- **Native Memory Recycling**: Integrated native C++ `table.wipe` across search string caches and character list iterators, eliminating heap allocation churn during rapid search typing and dropdown navigation.
- **Consolidated DRY Architecture**: Merged legacy multi-folder dependencies (`Bagnon_Core`, `Bagnon_Forever`, `Bagnon_Spot`, `Bagnon_Options`) into a single, self-contained, high-performance module.

---

## ⚡ Key Features

### 1. Unified Grid & Offline Bank
- **Single Window Inventory**: Replaces scattered bag windows with a clean, resizable grid.
- **Cached Bank Viewing**: Inspect an exact offline snapshot of your bank slots and bank bags from anywhere in the world.
- **Quick Bank Button**: 1-click bank viewer icon integrated directly into the inventory window.

### 2. Item Rarity & Specialized Bag Highlighting
- **Native Quality Borders**: Crisp, engine-accelerated rarity borders (Uncommon, Rare, Epic, Legendary, Artifact) rendered natively using `Interface\Tooltips\UI-Tooltip-Border` and ClassicAPI `C_Container` direct memory lookups, eliminating any need for external UI tweak addons.
- **Color-Coded Special Bag Slots**:
  - **Yellow**: Ammo pouches and Soul shard bags.
  - **Green**: Profession bags (Herbalism, Mining, Enchanting, Engineering).
  - **Orange**: Keyring container.

### 3. Cross-Character Alt Tracker & Search
- **Instant Search Engine**: Double-click the title bar to open the search bar. Highlights matching items in real time while dimming non-matching items. Uses crash-free literal matching (`string.find(..., 1, true)`).
- **O(1) Alt Item Tracker**: Hover over any item in the game to see total counts across all characters on your realm, powered by memoized item total caching.
- **Realm Gold Aggregator**: Hover over the money display to view total gold aggregated across all your alts on the current realm.

### 4. Lazy Weapon Enchant Badges
- **Real-Time Enchant Overlays**: Automatically displays active temporary weapon enchants (Rogue poisons, wizard/mana oils, sharpening/weight stones, and Shaman weapon imbues) directly on weapon icons in your bags.
- **Duration & Charge Indicators**: Color-coded remaining duration and charges badge with warning tints when enchants are near expiration.
- **Lazy On-Demand Lifecycle**: Overlays and textures are only instantiated when a weapon is detected in bag slots `0..4`, saving hundreds of UI objects at startup.
- **Toggleable via Slash Command**: Toggle enchant badges on/off at any time using `/bgn enchants`.

### 5. Suite Synergy (ItemRack & TrinketMenu)
- **ItemRack Set Indicators**: Hovering over any item in your bags or bank displays which ItemRack sets it belongs to (`ItemRack: <Set Names>`), preventing accidental vendor sales or bank desynchronization.
- **TrinketMenu Queued Alerts**: Hovering over a trinket queued for swap displays an alert (`TrinketMenu: Queued (Top/Bottom Slot)`).
- **Zero Overhead Decoupling**: All integrations use safe runtime existence guards (`if Rack ...`, `if TrinketMenu ...`), incurring 0ms latency when running standalone.

### 6. Modern Bag & Bank Sorting (ClassicAPI v1.15.0+ / v1.15.13+)
- **One-Click Container Sorting**: Clean, modern broom/cleanup icon anchored in the top-right header next to the close button for both inventory and bank frames.
- **Engine-Native Performance**: Driven by ClassicAPI's C++ coroutine sorting engine (`C_Container.SortBags` and `C_Container.SortBankBags`) with built-in reentrancy safety locks.
- **Equipment Slot Grouping (ClassicAPI v1.15.13+)**: On ClassicAPI v1.15.13+, gear automatically groups by slot category (weapons -> shields/offhands -> head -> shoulder -> back -> chest -> wrist -> hands -> waist -> legs -> feet -> neck -> rings -> trinkets -> shirt/tabard) instead of quality tiers.
- **Bidirectional Sorting**: Right-click the sort icon at any time to toggle sort filling order between Top-Left to Bottom-Right and Bottom-Right to Top-Left (`C_Container.SetSortBagsRightToLeft`).
- **Safety Interlocks**: Dynamically dims and guards against sorting offline cached alts or sorting bank bags while away from the bank NPC.

---

## ⌨️ Commands & Shortcuts

| Command / Interaction | Description |
| :--- | :--- |
| `/bgn` or `/bagnon` or `/bo` | Opens the main configuration options dialog |
| `/bgn bags` | Toggles the unified inventory window |
| `/bgn bank` | Toggles the unified bank window |
| `/bgn sort` | Cleans up and sorts bags (or bank if bank is open) |
| `/bgn enchants` | Toggles weapon enchant badge overlays on bagged weapons |
| `/bgn delete <character> [realm]` | Deletes saved offline inventory data for a character |
| `/bgn help` | Displays available slash commands |
| `Left-Click` on Sort Icon | Sorts the current window's containers |
| `Right-Click` on Sort Icon | Toggles sort direction (Top-Left vs Bottom-Right) |
| `Right-Click` on Title Bar | Opens frame settings (columns, spacing, opacity, background color, scale) |
| `Double-Click` on Title Bar | Opens the instant search bar |
| `Shift-Click` on Bag Icon | Toggles visibility of that individual bag's slots |
| `Left-Click` on Bank Icon | Opens the remote offline bank view |
| `Left-Click Drag` on Title | Repositions the window and saves position across sessions |

---

## 📦 Installation & Engine Prerequisites

### Prerequisites
1. **World of Warcraft 1.12.1** (Build 5875).
2. [**ClassicAPI v1.15.13+**](https://github.com/brues-code/ClassicAPI) (`ClassicAPI.dll`).

### Step-by-Step Installation
1. Clone or download the repository into your WoW AddOns directory:
   ```text
   World of Warcraft/Interface/AddOns/Bagnon/
   ```
2. Verify that `Bagnon.toc` is located directly at:
   ```text
   World of Warcraft/Interface/AddOns/Bagnon/Bagnon.toc
   ```
3. Launch the game using your DLL loader or launcher with ClassicAPI enabled.
4. Ensure **Bagnon** is checked in the character selection AddOn screen.

---

## 📜 Changelog

### v2.0.1
- **ClassicAPI v1.15.13 Sorting Integration**: Fully aligned with ClassicAPI v1.15.13's native equipment-slot sorting engine. Non-poor gear now groups logically by item class and equipment slot rank (weapons, shields/offhands, armor slots, jewelry, and trinkets) rather than scattered quality tiers.
- **Documentation & Engine Guidance**: Updated engine architecture references and sorting documentation for the v1.15.13 C++ coroutine sorting semantics.

### v2.0.0
- **Enhanced Engine Modernization Milestone**: Complete architectural overhaul aligning the addon strictly with the Enhanced WoW 1.12.1 runtime and ClassicAPI v1.15.8+.
- **Hot-Path Zero-GC Optimization**: Replaced per-frame `getglobal` string concatenations with `frame.items[slot]` direct widget arrays across Bagnon and Banknon; modernized `BAG_UPDATE_COOLDOWN` loop to iterate directly over cached items.
- **In-Place Search Spot Filtering**: Refactored `spot/spot.lua` to modulate slot alphas directly without rebuilding frame geometry or recalculating layout coordinates.
- **O(1) Alt Inventory Tooltip Cache**: Implemented memoized `playerTotalsCache` in `database/database.lua`, eliminating multi-character regex slot scans on tooltip hover with automatic bag mutation invalidation.
- **Lazy Weapon Enchant Overlays**: Eradicated upfront allocation of >600 UI objects; overlays and fontstrings are now instantiated lazily on-demand only when an actual weapon in bag slots `0..4` is detected.
- **Cached Tooltip FontStrings**: Replaced repetitive tooltip line `getglobal` lookups in `core/Item.lua` with a static lookup cache (`GetEnchantTooltipLine`).
- **Slash Control**: Added `/bgn enchants` slash command to toggle weapon enchant badges on demand.
- **Dead Code Elimination**: Retired and deleted legacy `lib/TLib.lua` and `lib/Infield.lua`; converted frame scaling to native methods; removed dead startup item queries and `MerchantRepairAllIcon` tampering; fixed `OpenAllBags(forceOpen)` to respect `forceOpen`.
- **Startup Safety**: Resolved early `currentPlayer` nil-hazards during initial addon bootstrap.

### v1.6.0
- **Modern Bag & Bank Sorting Button**: Introduced an engine-native container sorting button in the top-right header of both Bagnon and Banknon frames. Powered by ClassicAPI v1.15.0 `C_Container.SortBags` and `C_Container.SortBankBags`.
- **Bidirectional Sort Direction**: Right-clicking the sort icon toggles between Left-to-Right and Right-to-Left packing (`C_Container.SetSortBagsRightToLeft`), with real-time GameTooltip updates and chat feedback.
- **Full Control Surfaces**: Added `/bgn sort` slash command and `BAGNON_SORT` keybinding for binding bag sorting to any hotkey.
- **Safety Interlocks**: Automatic visual dimming (40% alpha) and click guards preventing sorting offline cached characters or sorting bank bags while away from bank NPCs.
- **Engine Guard Upgrade**: Raised minimum engine contract to ClassicAPI v1.15.0+ (`MIN_CLASSIC_API = 11500`).

### v1.5.2
- **Native Modern Item Rarity Borders**: Replaced legacy blurry circular action borders with crisp, square backdrop frames (`Interface\Tooltips\UI-Tooltip-Border`) anchored directly to item slots. Powered by ClassicAPI `C_Container.GetContainerItemID` for zero-allocation, instant resolution directly from client memory without relying on external tweak addons.
- **Hide Bags Session Persistence**: Resolved a bug where toggling "Hide Bags" was deleted from `SavedVariables` across sessions due to `nil` assignment, causing bag slots to default back to visible on login/reload.

### v1.5.1 (Inventory Trio Synergy)
- **ItemRack Tooltip Integration**: Extended `GameTooltip.SetBagItem`, `GameTooltip.SetInventoryItem`, and `GameTooltip.SetHyperlink` to display active ItemRack set membership (`ItemRack: <Set Names>`).
- **TrinketMenu Queue Alert**: Highlights items staged in TrinketMenu's combat queue directly on bag item tooltips (`TrinketMenu: Queued`).
- **Bank Slot Inventory Hooking**: Hooked `GameTooltip.SetInventoryItem` to ensure main bank window (`-1`) items reflect set and queue data identically to standard bag containers.

### v1.5.0
- **Single-Pass Tooltip Aggregation**: Introduced `BagnonDB.GetPlayerItemTotals`, consolidating 13 individual container lookups into a single pass per character and eliminating ~90% of string pattern matching overhead on item tooltip hover.
- **Closure-Free Event Architecture**: Converted anonymous script closures in `BagnonForever` and `Infield` into static file-scoped handler functions, eliminating runtime heap allocations during combat and event bursts.
- **Modern Handler Signatures & Forward Compatibility**: Modernized all frame, item, bag, options, and event scripts with explicit `(self, ...)` parameter signatures and backward-compatible `self or this` resolution across XML and Lua dispatchers.
- **Rule H2 Pure English Localization**: Removed dead legacy multilingual locale branching (`deDE`, `frFR`, `zhCN`), enforcing 100% English formatting and zero localization bloat.
- **Loop Optimization**: Replaced legacy Lua 5.0 `for i in table` iteration with indexed traversal in bag lookups.

### v1.4.0
- **Engine Startup Guard Enforcement**: Upgraded engine dependency guards at module entry points (`lib/TLib.lua`, `Bagnon.lua`, `Banknon.lua`, `core/Utility.lua`) to strictly enforce `MIN_CLASSIC_API = 11400` (`v1.14.0+`) and `SUPERWOW_VERSION` (`v2.2+`).
- **Memory & Event-Driven Audit**: Re-verified zero-allocation search string caches, C++ `table.wipe` recycling, and event-driven item slot updates without `OnUpdate` polling loops.

### v1.3.0
- **Rule C8 Mouse Passthrough**: Applied `:EnableMouse(false)` to item cooldown models (`item.cooldown`), eliminating click interception and guaranteeing 100% item slot click reliability.
- **Universal Engine Guard**: Enforced strict dependency checks at the very first file entry point (`lib/TLib.lua`) and `Bagnon.lua` for ClassicAPI v1.14.0+ and SuperWoW v2.2+.
- **Zero-GC Pre-allocated Buffers**: Integrated pre-allocated arrays and `table.wipe` recycling in `BagnonDB.GetPlayers` and `Slash.lua`.
- **Search Engine Modernization**: Streamlined `BagnonSpot_ClearSearch` to use native C++ `table.wipe` and modern EditBox text clearing.
- **Updated Documentation**: Fully aligned README with ClassicAPI v1.14.0+ and SuperWoW standards.

### v1.2.0
- **Native Memory Operations**: Integrated native C++ `table.wipe` for instant search cache clearing.
- **ClassicAPI Source-Rewriter AST Syntax**: Modernized layout calculation math to native modulo `%` operator.
- **Universal Engine Stack Standardization**: Upgraded startup dependency guard to inspect `CLASSIC_API_VERSION` and `SUPERWOW_VERSION` globals.

### v1.1.0
- Eradicated per-slot `OnUpdate` polling overhead across all 120+ bag/bank item buttons.
- Consolidated duplicate border renderers into a single unified DRY function.
- Consolidated repetitive options triggers using a generic helper.

---

## 📄 License & Community

- **Authors**: **Tuller**, **McPewPew**, **[Fostercare5988](https://github.com/Fostercare5988)**
- **Maintainer**: **[Fostercare5988](https://github.com/Fostercare5988)**
- **GitHub Repository**: [https://github.com/Fostercare5988/Bagnon](https://github.com/Fostercare5988/Bagnon)
- **License**: MIT License - See [LICENSE](LICENSE) for details.
