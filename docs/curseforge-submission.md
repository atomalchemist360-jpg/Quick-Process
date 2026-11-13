# CurseForge submission — QuickProcess

## Project fields

| Field | Entry |
| --- | --- |
| Game | World of Warcraft |
| Name | QuickProcess |
| Class | Addons |
| Main category | Bags & Inventory |
| Additional categories | Professions, Combat, Mage, Rogue |
| Allow comments | Enabled |
| Experimental | Disabled |
| Editor | Markdown |
| License | All Rights Reserved |
| Source | https://github.com/atomalchemist360-jpg/Quick-Process |
| Issues | CurseForge internal issue tracker |
| Required dependencies | None |

Summary:

Process scrolls, unlock lockboxes, disenchant equipment, and start ranged attacks with convenient modifier-click shortcuts.

## File fields

- File: current QuickProcess ZIP, optionally named QuickProcess-0.5.1-beta.zip.
- Display name: QuickProcess 0.5.1 Beta.
- Release type: Beta.
- Flavor: Forever.
- Game version: 1.60.1; interface 16001.
- Required dependencies: none.
- Preserve QuickProcess/QuickProcess.toc inside the ZIP.

## Donation details

Venmo: https://venmo.com/u/atom-Alchemist-55198

Cash App: https://cash.app/$AtomAlchemist

If CurseForge's dedicated donation settings do not offer these providers, use the links in the Support development section at the bottom of the description. Do not select a different payment provider merely to enter these handles.

## Copy-ready project description

# QuickProcess

QuickProcess adds convenient bag-processing shortcuts and ranged-weapon attacks to World of Warcraft: Forever.

## Bag processing

Use the selected modifier + right-click on an eligible bag item to apply an appropriate learned ability:

- **Mage: Comprehend Scroll.** Recognizes exactly 17 item IDs from Wowhead's Forever Comprehension list.
- **Rogue: Pick Lock.** Attempts to unlock eligible locked items.
- **Enchanter: Disenchant.** Attempts to disenchant uncommon, rare, or epic weapons and armor. Disenchant destroys the selected item.

The game checks your learned abilities, skill level, tools, and item eligibility. Bag processing works outside combat with Blizzard bags and supported Enhance QoL bags. Milling and Prospecting are not included.

## Shortcut settings

Click the QP minimap button or type `/qp settings` to choose Alt, Ctrl, Shift, or a combination with right-click. Your choice saves automatically. Change shortcuts outside combat.

Alt + right-click is the default. To avoid WoWdee's Alt-click conflict, choose Ctrl + right-click or another available combination.

## Ranged attacks

Alt + right-click a living enemy under the pointer to select it and attempt your equipped wand, bow, gun, crossbow, or thrown-weapon attack. Hunters use Auto Shot when learned. Repeated clicks request auto-fire without toggling it off; Throw may require another click for each attack.

The shortcut works during combat and attempts at any distance. Weapon range, ammunition, facing, line of sight, and other game requirements still apply. Enemy attacks remain Alt + right-click independently of your bag shortcut.

## Minimap button and commands

Drag the QP minimap button to reposition it. Click it for settings and instructions.

| Command | Purpose |
| --- | --- |
| `/qp` or `/qp settings` | Open settings |
| `/qp status` | Show version, detection, and current bag shortcut |
| `/qp scan` | List bag items and processing decisions |
| `/qp ranged` | Show the detected ranged attack |
| `/qp bind ITEM_ID SPELL_NAME_OR_ID` | Assign a supported learned processing ability |
| `/qp unbind ITEM_ID` | Remove an assignment |

Comprehend Scroll assignments also require an item ID from the verified Forever list.

## Compatibility and installation

Built for WoW Forever 1.60.1, interface 16001. No required addon dependencies. Supports Blizzard bags and Enhance QoL's custom bag layout, developed against Enhance QoL 13.20.1-forever. Bank slots, equipped-item processing, and other replacement bag interfaces are not supported in this beta.

Install through CurseForge, or extract the QuickProcess folder into Interface/AddOns. The resulting path must be `Interface/AddOns/QuickProcess/QuickProcess.toc`. Restart WoW after installing or updating.

## Performance and feedback

Version 0.5.1 replaces continuous bag polling with relevant inventory, spell, bag-opening, and layout updates. Event bursts are grouped together. Hidden lock-detection tooltip scans are limited to characters with Pick Lock learned.

This is a beta. Reports should include your QuickProcess version, game build, class, item name and ID, bag addon, selected shortcut, `/qp status` output, and any Lua error. Mocked checks do not replace testing in the game client.

## Credits and license

Includes ranged-weapon selection adapted from the author's AutoattackImprovement addon. Enhance QoL and WoWdee are separate projects and are not bundled.

All Rights Reserved. Copyright (c) 2026 atomalchemist360-jpg. Personal installation and use are permitted under the included license.

## Support development

If you would like to support QuickProcess development, donations are appreciated and optional. All addon features are available without donating.

- [Venmo: @atom-Alchemist-55198](https://venmo.com/u/atom-Alchemist-55198)
- [Cash App: $AtomAlchemist](https://cash.app/$AtomAlchemist)

## Submission notes — do not paste into the description

- Use an original 400 x 400 PNG logo, such as the turquoise-and-gold QP design.
- Confirm the project name is available.
- Keep donation links at the bottom of the public description.
- Do not add external ZIP download links to the public description. Use the Source field for GitHub.
- Refer to the complete development changelog supplied in chat for version history.

Submission guide: https://support.curseforge.com/support/solutions/articles/9000199552-project-submission-guide-and-tips
Moderation policies: https://support.curseforge.com/support/solutions/articles/9000197279-project-and-modpack-moderation-policies
