# DPSMate - Project Legacy

A **Project Legacy-compatible DPSMate fork** for **World of Warcraft 1.12.1**.

This fork carries over my DPSMate work originally developed for VanillaPlus and adapts it for **Project Legacy**, while keeping the original DPSMate experience and modular structure intact.

---

## Features

- Original DPSMate combat-meter functionality
- **Mana Gained** tracking
- **Rage Gained** tracking
- **Energy Gained** tracking
- Project Legacy-specific compatibility fixes
- Corrected Project Legacy Paladin resource and damage attribution
- Modular DPSMate addon structure preserved
- Built for the **WoW 1.12.1 Vanilla client**

---

# Installation

> [!IMPORTANT]
> **You must install all 6 DPSMate folders directly into your `Interface\AddOns` folder.**

The six required folders are:

```text
DPSMate
DPSMate_DataDamage
DPSMate_DataHealing
DPSMate_DataHistory
DPSMate_DataResources
DPSMate_DataUtility
```

## Correct folder structure
<img width="986" height="632" alt="image" src="https://github.com/user-attachments/assets/5c7de8b1-a307-4054-b652-d278e62a229c" />


Your Project Legacy addon folder should look like this:

```text
Project Legacy
└── Interface
    └── AddOns
        ├── DPSMate
        ├── DPSMate_DataDamage
        ├── DPSMate_DataHealing
        ├── DPSMate_DataHistory
        ├── DPSMate_DataResources
        └── DPSMate_DataUtility
```

### In other words:

**Copy all 6 folders into:**

```text
Project Legacy\Interface\AddOns\
```

Do **not** leave the six folders inside an extra downloaded repository folder.

---

## Step-by-step

1. Click **Code** on GitHub.
2. Choose **Download ZIP**.
3. Extract the downloaded ZIP.
4. Open the extracted folder.
5. Select these **6 folders**:

   ```text
   DPSMate
   DPSMate_DataDamage
   DPSMate_DataHealing
   DPSMate_DataHistory
   DPSMate_DataResources
   DPSMate_DataUtility
   ```

6. Copy all six folders into:

   ```text
   Project Legacy\Interface\AddOns\
   ```

7. Start or restart World of Warcraft.
8. At the character-select screen, open **AddOns** and make sure the DPSMate modules are enabled.

---

## Updating

When updating to a newer version:

1. Close World of Warcraft.
2. Replace the existing six DPSMate folders inside `Interface\AddOns`.
3. Start the game again.

Your DPSMate settings and recorded data are stored separately in WoW's `WTF` folder, so replacing the addon folders normally does not erase your SavedVariables.

---

## Modules

| Folder | Purpose |
|---|---|
| `DPSMate` | Core addon |
| `DPSMate_DataDamage` | Damage-related modules |
| `DPSMate_DataHealing` | Healing-related modules |
| `DPSMate_DataHistory` | History / stored combat data modules |
| `DPSMate_DataResources` | Mana, Rage, Energy and resource-related modules |
| `DPSMate_DataUtility` | Utility / additional data modules |

---
## Project Legacy-Specific Fixes

This fork includes fixes for mechanics on Project Legacy that the original DPSMate could not correctly detect or attribute.

### Bulwark of Faith - Mana Gained from Blocking

Project Legacy's **Bulwark of Faith** restores mana when the Paladin blocks.

The important problem is that this mana restoration is **not reported as a normal mana-gain event in the combat log**.

On the VMaNGOS backend, the server directly raises the player's mana value, so DPSMate cannot simply parse a combat-log line and assign the restored mana to Bulwark of Faith.

This fork adds special handling so DPSMate can recognize these server-side mana increases and correctly attribute the appropriate mana restoration to:

```text
Bulwark of Faith
```
<img width="741" height="351" alt="image" src="https://github.com/user-attachments/assets/c497cddb-b4b2-49b6-bd99-d7f8c651c63c" />

This allows **Mana Gained** to properly show mana returned by Bulwark of Faith instead of silently missing it.

### Crusader's Inquest - Periodic Damage Attribution

Project Legacy's **Crusader's Inquest** periodic damage could appear as though it were coming from a separate source instead of the Paladin who caused it.

This resulted in entries such as:

```text
Crusader's Inquest (Periodic)
```
<img width="796" height="387" alt="image" src="https://github.com/user-attachments/assets/0db3e5d7-d971-4ec1-956b-d174e3aa859d" />

being separated from the Paladin's own damage totals.

This fork fixes that attribution so **Crusader's Inquest (Periodic)** damage is properly credited back to the Paladin character who caused it.

That means the Paladin's DPS and total damage now include the periodic Crusader's Inquest damage instead of DPSMate treating it like an unrelated damage source.

---

## Notes

This is a community-maintained DPSMate fork and is not an official Project Legacy addon.

If something is not being tracked correctly, please include as much information as possible when reporting it, especially:

- Character class
- Spell or ability name
- What DPSMate recorded
- What you expected it to record
- Any Lua error message
- A screenshot or combat-log example when possible

---

## Credits

DPSMate was originally created by its original authors and contributors.

This fork contains additional work and adaptations for **Project Legacy**, including resource-tracking, Paladin-specific fixes, and server-specific compatibility changes.

Enjoy!
