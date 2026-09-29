# Bagnon User Guide

Detailed configuration, shortcuts, and features for **Bagnon**.

---

## 1. Frame Controls & Customization

- **Opening Bagnon**: Press your standard bag key (`B`), click your backpack, or type `/bgn bags`.
- **Opening the Bank**: Visit a bank teller or type `/bgn bank` to view your bank anywhere (offline cached view when away from a bank NPC).
- **Customizing Appearance**:
  - Right-click the title bar of the inventory or bank window to open frame settings.
  - Adjust column count, item spacing, window scale, background opacity, and color.
  - Drag the title bar or the free slots counter to reposition the window on your screen. Positions are saved per character.
- **Toggling Individual Bags**: In the bag bar, Shift-click any bag icon to toggle the visibility of that specific container's slots within the unified grid.

---

## 2. Bag & Bank Sorting

- **Sorting Containers**: Click the broom icon in the top-right header, use `/bgn sort`, or bind a key under the game Keybindings menu (`Bagnon`).
- **Sort Order**: Right-click the broom icon to toggle between packing items Top-Left to Bottom-Right or Bottom-Right to Top-Left.
- **Sort Exclusion (Bag Ignore)**:
  - You can exempt containers from being reorganized during a sort by Alt-clicking or Right-clicking the bag slot icon in Bagnon's bag bar.
  - An ignored container displays a status badge on its bag icon.
  - **Safety Notice**: Sorting while the backpack or main bank slot is set to ignored is temporarily disabled to prevent an upstream engine issue. All other containers can be sorted normally.
- **Server Timing**: Sorting executes via server-side moves over several updates. The button triggers the request; allow the server a brief moment to finish moving items.

---

## 3. Telemetry & Indicators

- **Live Free Slot Counter**: The header displays real-time free space (e.g. `24 / 96 Free`). Hovering over this badge reveals a tooltip breakdown showing free space container by container.
- **Weapon Enchant Badges**: Temporary weapon enchants (poisons, sharpening stones, oils) display an icon badge and duration indication directly on weapons in your bags.
- **Rarity Borders**: Items feature color-coded rarity borders (Uncommon, Rare, Epic, Legendary). Specialized profession and ammo bags also feature distinct colored backgrounds.

---

## 4. Multi-Character & Suite Features

- **Cross-Character Alt Inventory**: Hover over any item to view a tooltip summary showing how many copies of that item are held across all your characters on the current realm.
- **Realm Gold Tracker**: Hover over the money display in the bottom-right corner to see total gold across all your characters on the realm.
- **ItemRack & TrinketMenu Integration**:
  - Items belonging to saved ItemRack sets display their set names directly on the item tooltip (`ItemRack: <Set>`).
  - Trinkets currently staged in TrinketMenu's auto-swap queue show a queued notice (`TrinketMenu: Queued`).
