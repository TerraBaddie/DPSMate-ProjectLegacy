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

## Incorrect

```text
Project Legacy
└── Interface
    └── AddOns
        └── DPSMate-ProjectLegacy
            ├── DPSMate
            ├── DPSMate_DataDamage
            ├── DPSMate_DataHealing
            ├── DPSMate_DataHistory
            ├── DPSMate_DataResources
            └── DPSMate_DataUtility
```

The WoW client needs to see each DPSMate module as its own addon folder directly inside `AddOns`.

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

## Project Legacy

This repository is specifically intended for **Project Legacy**.

It includes changes needed for Project Legacy while retaining the DPSMate layout and functionality familiar from Vanilla 1.12.1.

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

This fork contains additional work and adaptations for **Project Legacy**, including resource-tracking and server-specific compatibility changes.

Enjoy!
