# Bagnon integration review — 2026-09-29

Task: source audit, bounded fixes, final integration review. Baseline
`06273847e7069690371f0f0c63df44431f99e921` was clean and matched actual remote
main. Reused the local September 26 sorting and September 27 portfolio audits;
reviewed the intervening header/search removal and container modernization.

## Architecture

TOC order: Bootstrap/localization; Utility/Overrides; Bag, Item and Frame Lua/XML;
menu; slash/event dispatcher; database/access UI/recorder/tooltips; options;
inventory and bank Lua/XML. The graph resolves 17 Lua and eight XML files.
Root `Bindings.xml` is client-managed and intentionally outside the TOC.

`BagnonSets` persists per-character presentation/options. `BagnonForeverData`
persists realm/character bag snapshots and money. Item button/location state,
capacity snapshots and tooltip total caches are runtime-only. Events own bag,
bank, lock, cooldown, money, login and automatic window transitions. Rendering
and enchant reads are event/open driven; no new polling or timer is introduced.

Frame owns the reusable item-button grid and drag/scale/layout; Bag owns the
bag bar; Item owns native click dispatch, quality/cooldown/enchant decorations;
Forever/database own historical data; Options/menu own controls. Live inventory
operations remain native. Historical slots remain link-only. Tooltip integrations
query ItemRack/TrinketMenu without moving items; optional KC_Items is unchanged.

Consumed enhancement: ClassicAPI container ID/free-space/sort/CVar functions,
`table.wipe`, hooks and frame methods, plus exact-location `C_Item` enchant and
`C_Spell` texture queries in this patch. No direct SuperWoW, NamPower or UnitXP
requirement is added. ClassicAPI minimum remains 1.15.15. No DXVK dependency.

## Findings

Addon locations refer to the baseline. All five are [SOURCE-VERIFIED]; mock
reproductions establish Lua control flow only, not gameplay.

| Priority | Location | Reproduction / consequence | Bounded correction |
| --- | --- | --- | --- |
| P1 | ClassicAPI `src/container/SortBags.cpp:784,810`; addon `core/Frame.lua:707`, `Slash.lua:51`, `Bindings.xml:9` | Exclude backpack/main bank, then sort with mergeable stacks. `StartSortExcluding` creates local vector `kept`; `StartSort` retains `kept.data()` in `g_activeBags`. The vector dies before deferred `OnBagUpdate` reads it. This is a dangling-pointer lifetime defect; wrong-container moves/crash are possible, not observed in game here. | Maintainer explicitly chose to block excluded-container sort requests until a native correction is source-verified. One guard covers button, slash and keybinding. The exclusion settings remain intact. No guessed version threshold unlocks it. |
| P2 | `core/Item.lua:246,428` | A localized/custom tooltip line is missing or resembles a timed enchant. Scraping can miss or misclassify the badge, and English name fragments guess an icon. | Query the exact current bag/slot with `C_Item.GetItemTempEnchantInfo`; use enchant spell metadata for the icon, or a neutral question mark if absent. Preserve toggle, charge warnings and event-driven redraw. |
| P2 | `core/Bag.lua:67`, `core/Frame.lua:293` | Hide the bag bar, replace a container with a different capacity, then receive `BAG_UPDATE`. Bag-bar generation is skipped; partial updates assume new offsets over old button bindings. Equal total capacity can also hide per-bag changes. | Snapshot each generated bag size; rebuild before partial updates if any selected container changes. Use that same snapshot for offsets. |
| P2 | `BagnonForever.lua:42`, `database/database.lua:220` | Record/read an item link with signed random-suffix/unique fields. The writer concatenates nil fields; the reader truncates the identity. | Preserve signed fields through the compact cache round trip; reject malformed text instead of concatenating nil. No cache schema migration. |
| P2 | `Events.lua:58`, `core/Frame.lua:41,61,352` | Old/manual non-table roots, string backgrounds, invalid opacity/columns/scale reach arithmetic or native setters. | Normalize these known settings at load, keeping valid values and toggles. Layout ranges follow the existing menu controls; invalid coordinates remain unset. |

## Authoritative sources

Pinned ClassicAPI v1.15.15 commit
`71805db62f1e8a154477033dc1f50960c535af8b`:

- [SortBags.cpp](https://github.com/brues-code/ClassicAPI/blob/71805db62f1e8a154477033dc1f50960c535af8b/src/container/SortBags.cpp#L784): two-stage merge/placement, shared in-flight state, exclusions and the pointer lifetime defect. No completion return is provided.
- [WeaponEnchant.cpp](https://github.com/brues-code/ClassicAPI/blob/71805db62f1e8a154477033dc1f50960c535af8b/src/item/WeaponEnchant.cpp#L121): location/GUID resolution and `(hasEnchant, remainingMilliseconds, charges, enchantID)`; inactive/unavailable returns false and zeroes.
- [EnchantInfo.cpp](https://github.com/brues-code/ClassicAPI/blob/71805db62f1e8a154477033dc1f50960c535af8b/src/item/EnchantInfo.cpp): optional `spellID` derives from proc/equip/use effects; source-item identity is not derivable.
- [API.md](https://github.com/brues-code/ClassicAPI/blob/71805db62f1e8a154477033dc1f50960c535af8b/docs/API.md): `C_Spell.GetSpellTexture`, container and item-link contracts. Cached enchant source blobs were matched to the pinned Git tree.

The native engine still owns ordinary sorting; no alternate comparator, cursor
clearing, speculative move retry or fake completion message was introduced.
Its actual behavior under latency/concurrent moves is not proven by Lua mocks.

## Integration result and validation

1. Correctness: PASS for covered Lua flows; native exclusion hazard mitigated.
2. Ownership: PASS; slot bindings rebuild before reads, current instances drive
   badges, cached views do not query live enchants.
3. APIs/dependencies: PASS; source-backed primitives, unchanged minimum. Startup
   checks the newly consumed metadata functions.
4. Hot paths: PASS by inspection; no new polling, one reused location table per
   encountered item button. No measured CPU/latency claim.
5. Persistence: PASS; normalization only, signed cache fields retained; capacity
   and location scratch state remain outside SavedVariables.
6. UI/load graph: PASS; 17 Lua files compile, 25 TOC/XML entries resolve, zero
   orphan Lua files. Binding dispatch separately exercised.
7. Validation: 14 Lua 5.1 tests pass; seven selected defect tests reproduce on
   the original commit (assertion failures or original invalid-value errors).
   Strict VanillaForge lint: zero errors/advisories. `git diff --check` passes.
8. Repository: full runtime/test/documentation diff reviewed; addon-only scope.

READY for publication of this mitigation and bounded fixes. Gameplay remains
unverified; the upstream native defect remains open behind the dispatch guard.

## In-game acceptance — pending

1. Back up SavedVariables with WoW closed. Exercise malformed layout/background
   values, normal `/bgn` options and menu opening, fresh defaults, drag, scale,
   saved position and UI-scale redraw. Preserve valid toggles/hidden bags.
2. Hide the bag bar; replace a bag with larger/smaller capacity. Check every
   displayed slot and tooltip against the actual bag, then swap two capacities
   keeping the same total. Test bank open/close and cached-character transitions.
3. Compare two copies of one weapon with different temporary enchants. Swap,
   remove, reapply and expire them; trigger bag redraw/reopen. Check duration,
   charges, metadata icon/neutral icon, toggle off/on, and no live badge in cache.
   Duration is sampled on redraw, not a continuous countdown.
4. Record a signed-suffix item, reload and inspect/link it from cached bags and
   bank. Verify identity/count and tooltip ownership totals after moving it.
5. With backpack/main-bank exclusion enabled, button, `/bgn sort` and binding
   must refuse the relevant sort and preserve the setting. Do not bypass this
   guard to test the known native defect.
6. With no exclusion, sort mixed items/partial stacks/specialty bags in both
   directions. Let server updates settle; compare complete item identities and
   quantities. Test cached views, unavailable bank, occupied cursor and repeated
   clicks. Native transaction behavior under latency is [UNVERIFIED - TEST FIRST].

## Retrospective

The old audit correctly identified native enchant metadata, but the current
source audit also exposed a native deferred-lifetime bug. Reading the actual
dependency implementation changed the integration decision. Broad output reads
were less useful than inspecting specific event/ownership paths. Existing
framework principles already cover identity and deferred ownership; no framework
edit is proposed. An upstream correction and runtime acceptance are separate work.
