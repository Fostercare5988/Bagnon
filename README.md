# Bagnon

[![Interface: 1.12.1](https://img.shields.io/badge/Interface-1.12.1%20(5875)-orange.svg)](https://github.com/Fostercare5988/Bagnon)
[![Version: 1.6.0](https://img.shields.io/badge/Version-1.6.0-blue.svg)](https://github.com/Fostercare5988/Bagnon/releases)
[![ClassicAPI: v1.15.0+](https://img.shields.io/badge/ClassicAPI-v1.15.0+-green.svg)](https://github.com/brues-code/ClassicAPI)
[![SuperWoW: v2.2+](https://img.shields.io/badge/SuperWoW-v2.2+-brightgreen.svg)](https://github.com/balakethelock/SuperWoW)
[![NamPower: v4.6.3+](https://img.shields.io/badge/NamPower-v4.6.3+-blueviolet.svg)](https://github.com/Emyrk/nampower)
[![UnitXP: SP3](https://img.shields.io/badge/UnitXP-SP3-teal.svg)](https://codeberg.org/konaka/UnitXP_SP3)
[![DXVK: Vulkan](https://img.shields.io/badge/DXVK-Vulkan-red.svg)](https://github.com/doitsujin/dxvk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Bagnon v1.6.0** is an enterprise-grade, single-window inventory and bank engine engineered natively for **World of Warcraft 1.12.1 (Build 5875)** running on the **Enhanced Client Extension Stack** (**ClassicAPI v1.15.0+**, **SuperWoW v2.2+**, **NamPower 4.6.3+**, **UnitXP SP3**, and **DXVK**).

Bagnon merges all fragmented inventory and bank bags into a unified, resizable grid. It enables remote bank viewing from anywhere in the world, memoized instant substring search, cross-character alt item aggregation on tooltips, total realm gold tracking, and modern one-click bag and bank sorting.

Created and actively maintained by **[Fostercare5988](https://github.com/Fostercare5988)**.

---

## 📸 Preview

![Bagnon Overview](assets/preview.jpg)

---

## 🚀 Engine Architecture & Performance

Bagnon is engineered around strict low-level system integration:

| Engine Component | Minimum Version | Architectural Role & Implementation |
| :--- | :--- | :--- |
| **ClassicAPI** | `v1.15.0+` | C++ hardware timers (`C_Timer.After`), modern EditBox text manipulation, native `table.wipe` memory recycling, native container sorting (`C_Container.SortBags`, `C_Container.SortBankBags`), and source-rewritten Lua 5.1 syntax. |
| **SuperWoW** | `v2.2+` | Direct memory state access, zero-latency container sync, and OS-level window notifications. |
| **NamPower** | `v4.6.3+` | Microsecond-precision combat pipeline and frame-0 event dispatching for bag swaps and item movement. |
| **UnitXP** | `SP3` | High-precision unit state inspection and alt character inventory synchronization. |
| **DXVK** | `Latest` | Decoupled high-refresh frame pacing with zero garbage collection heap churn and hardware-synchronized cooldown spirals. |

### Elimination of 2006 Legacy Techniques
- **Zero OnUpdate Polling**: Eradicated legacy per-button `OnUpdate` polling loops across all 120+ bag/bank item slots; item slot states update exclusively on native events (`BAG_UPDATE`, `BAG_UPDATE_COOLDOWN`, `ITEM_LOCK_CHANGED`).
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
- **Alt Item Tracker**: Hover over any item in the game to see total counts across all characters on your realm.
- **Realm Gold Aggregator**: Hover over the money display to view total gold aggregated across all your alts on the current realm.

### 4. Suite Synergy (ItemRack & TrinketMenu)
- **ItemRack Set Indicators**: Hovering over any item in your bags or bank displays which ItemRack sets it belongs to (`ItemRack: <Set Names>`), preventing accidental vendor sales or bank desynchronization.
- **TrinketMenu Queued Alerts**: Hovering over a trinket queued for swap displays an alert (`TrinketMenu: Queued (Top/Bottom Slot)`).
- **Zero Overhead Decoupling**: All integrations use safe runtime existence guards (`if Rack ...`, `if TrinketMenu ...`), incurring 0ms latency when running standalone.

### 5. Modern Bag & Bank Sorting (ClassicAPI v1.15.0+)
- **One-Click Container Sorting**: Clean, modern broom/cleanup icon anchored in the top-right header next to the close button for both inventory and bank frames.
- **Engine-Native Performance**: Driven by ClassicAPI v1.15.0's C++ coroutine sorting engine (`C_Container.SortBags` and `C_Container.SortBankBags`) with built-in reentrancy safety locks.
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
2. [**ClassicAPI v1.15.0+**](https://github.com/brues-code/ClassicAPI) (`ClassicAPI.dll`).
3. [**SuperWoW v2.2+**](https://github.com/balakethelock/SuperWoW) (`SuperWoW.dll`).
4. [**NamPower v4.6.3+**](https://github.com/Emyrk/nampower) (`nampower.dll`).
5. [**UnitXP SP3**](https://codeberg.org/konaka/UnitXP_SP3) (`UnitXP_SP3.dll`).
6. [**DXVK**](https://github.com/doitsujin/dxvk) & [**VanillaFixes**](https://github.com/hannesmann/vanillafixes).

### Step-by-Step Installation
1. Clone or download the repository into your WoW AddOns directory:
   ```text
   World of Warcraft/Interface/AddOns/Bagnon/
   ```
2. Verify that `Bagnon.toc` is located directly at:
   ```text
   World of Warcraft/Interface/AddOns/Bagnon/Bagnon.toc
   ```
3. Launch the game using your DLL loader or launcher with ClassicAPI and SuperWoW enabled.
4. Ensure **Bagnon** is checked in the character selection AddOn screen.

---

## 📜 Changelog

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

## 🧩 Suite Compatibility

Bagnon operates seamlessly alongside the enhanced client addon suite:
- **[ItemRack](https://github.com/Fostercare5988/ItemRack)**: Fully compatible with ItemRack's bank detection and gear set transfers. ItemRack's blue-border bank indicators and automated bank-to-bag set transfers update Bagnon's unified grid in real time with zero frame hijacking or state desync.
- **[TrinketMenu](https://github.com/Fostercare5988/TrinketMenu)**: Instant inventory grid updates during automated and combat-queued trinket swaps.

---

## 📄 License & Community

- **Authors**: **Tuller**, **McPewPew**, **[Fostercare5988](https://github.com/Fostercare5988)**
- **Maintainer**: **[Fostercare5988](https://github.com/Fostercare5988)**
- **GitHub Repository**: [https://github.com/Fostercare5988/Bagnon](https://github.com/Fostercare5988/Bagnon)
- **License**: MIT License - See [LICENSE](LICENSE) for details.
