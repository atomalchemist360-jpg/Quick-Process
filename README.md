# QuickProcess — Forever 1.60.1 beta

[Download the latest installable ZIP](https://github.com/atomalchemist360-jpg/Quick-Process/raw/refs/heads/main/downloads/QuickProcess.zip)


Interface 16001; intended for build 70888.

## Install

Exit WoW, extract the archive, and copy the QuickProcess folder into the game client's Interface/AddOns folder. The layout must be Interface/AddOns/QuickProcess/QuickProcess.toc. Restart the client and enable QuickProcess in the character-selection AddOns list.

## Performance update (0.5.1)

Bag processing now refreshes from inventory/spell changes and bag-open/layout hooks, rather than scanning five times per second. Event bursts are coalesced into one short deferred refresh. Enhance QoL bag modules loaded later are hooked when their addon loads. Unchanged secure actions retain their visibility driver; the game handles modifier changes without rescanning bags.

Hidden tooltip construction is used only when Pick Lock is learned and lock detection is needed. Spell lookups are shared within each refresh. Unrelated item-data loads no longer refresh bag processing or recheck a missing ranged weapon.

A mocked 100-slot, 10-second idle scenario changed from 4,600 item reads and 4,554 hidden tooltip builds to zero idle reads/builds. These are API work counts, not a measured in-game CPU percentage. Restart the client after installing before comparing addon CPU usage.

## Settings and addon conflicts

Click the QP minimap button or type `/qp settings` (or `/qp`) to open the settings menu. Choose Alt, Ctrl, Shift, or a combination with right-click for all bag processing. The choice saves automatically across sessions and takes effect immediately outside combat. Additional modifiers must match exactly.

For WoWdee's Alt-click conflict, select **Ctrl + right-click** or **Ctrl + Shift + right-click**. QuickProcess clears its old bag bindings, including those for closed bags. Enemy ranged attacks remain **Alt + right-click** and are configured independently of this bag setting. Settings changes are disabled during combat.

## Bag items

Hold the selected modifier (Alt by default) and right-click an eligible item in Blizzard or Enhance QoL bags outside combat. One click prepares and executes a cast on that bag slot. Wait for the cast and loot to finish before clicking again. Items are consumed according to the selected skill, including equipment destroyed by Disenchant.

Automatic selection:
- Disenchant: uncommon, rare, or epic weapons and armor, if Disenchant is learned. The game determines final eligibility and skill requirements; some equipment cannot be disenchanted.
- Comprehend Scroll: exactly the 17 item IDs in [Wowhead Forever’s Comprehension list](https://www.wowhead.com/forever/skill=3012/comprehension). Names and tooltip text are never used to recognize comprehension scrolls. Uses the learned Comprehend Scroll ability by spell ID 1296017.
- Pick Lock: items whose tooltip contains a standalone Locked line (using the client translation) or “Requires Lockpicking”, if Pick Lock is learned. Already unlocked boxes retain normal behavior. The game checks your lockpicking skill and any tool requirements.

Other items retain normal bag behavior. Left-click passes through the overlay where the client supports SetPassThroughButtons. Item processing is disabled during combat. Bank slots, equipped items, and bag replacements other than Enhance QoL are not supported in this beta.

Version 0.4.2 verifies the complete whitelist against the supplied Wowhead Forever Comprehension page and removes name/tooltip-based scroll detection.

Version 0.4.3 fixes the secure modifier lookup: bag actions use wildcard-modifier right-click attributes (`*type2`, `*spell2`, and matching item-target attributes). Previously the tooltip could recognize a scroll while Alt + right-click had no matching secure action. Overlays also sit above the bag's display layer. The startup message and `/qp status` show the installed version.

Version 0.4.4 adds detection of Enhance QoL's custom bag buttons, using its published `EnhanceQoL.Bags.variables.state.buttons` and `itemButtonsByBag` tables. Integration follows the layouts inspected in Enhance QoL 13.20.1-forever (CurseForge file 9563261). It supports load-on-demand bags and keeps the existing 17-ID Forever scroll list. No Enhance QoL settings or scripts are overwritten. Open its bag window and run `/qp status` to see the number of Enhance QoL bag buttons detected.

## Troubleshooting scrolls

Use your selected bag shortcut (**Alt + right-click** by default), outside combat. Ordinary right-click does not cast Comprehend Scroll. Version 0.4.1 fixes Forever's pooled bag-button discovery and the combined bag iterator, and uses a secure spell action with the selected bag/slot as its item target. It also resolves Comprehend Scroll by its canonical spell ID instead of an ambiguous English name.

With your bags open, type `/qp status` to show whether Comprehend Scroll is learned/detected and how many visible bag buttons/items are eligible. `/qp scan` lists each bag item's selected skill. If a click still fails, report these results, the exact scroll name, and whether you use a bag addon. Blizzard bags and Enhance QoL Bags are supported; other bag replacements are not supported in this beta.

## Ranged attacks

Equip a wand, bow, gun, crossbow, or thrown weapon and learn its attack. **Alt + right-click a living enemy under the pointer** to select it and attempt the equipped weapon's ranged attack. Hunters use Auto Shot for bows, guns, and crossbows when learned. Other characters use their weapon's Shoot ability; thrown weapons use Throw. Repeated clicks request auto-fire without toggling it off; Throw may require a click for each attack.

The ranged shortcut works during combat and attempts at any distance. The game still enforces weapon range, ammunition, facing, line of sight, and other requirements. There is no melee-distance check. It uses the enemy under the pointer, not an unrelated current target. The ranged binding is active only while hovering a living hostile unit, with the selected secure bag-item binding taking priority when processing an item. Ordinary right-click is not rebound.

Type `/qp ranged` to see the detected attack. Changes to equipment or learned attacks during combat apply after combat ends. Disable the standalone Rightclick Improvement addon if you no longer want its separate Shift + right-click shortcut; QuickProcess supplies the integrated Alt + right-click behavior.

## Minimap button

The minimap launcher has a turquoise Q and gold P inside a round border. Click it for shortcut settings, usage instructions and commands; drag it around the minimap to reposition it. Its position is saved between sessions. Press Escape or click the close button to dismiss the panel.

## Item assignments / localized items

Type /qp for help. To map an item to a learned Pick Lock, Comprehend Scroll, or Disenchant spell:

    /qp bind ITEM_ID SPELL_NAME_OR_ID
    /qp unbind ITEM_ID

Use a numeric spell ID where possible, especially on non-English clients. A custom mapping overrides automatic selection for that item. Only these three abilities are accepted. Comprehend Scroll assignments also require an item ID in the verified Forever list; assignments to unlisted scroll IDs are rejected or ignored. Old assignments to other abilities are ignored. Mapping validity, target eligibility, required quantities, and skill requirements are ultimately enforced by the game.

## Verification and limitations

Mocked API checks passed for disenchant selection, comprehension selection, pick-lock selection, already unlocked boxes, ordinary scroll exclusion, unsupported materials, unknown spells, restricted custom mappings, busy items, Alt-only visibility, and the combat update guard. Forever-layout regression checks cover pooled buttons, combined-bag index/value iteration, canonical spell ID, localized item IDs, uncached scroll names, explicit player spell bank, and recycled slot targets. The previous version fails the pooled-layout regression; the fixed version passes. Lua source loads under Lua 5.4 and uses syntax compatible with WoW's Lua 5.1.

Ranged-attack mock checks also passed for weapon selection, Hunter Auto Shot preference, custom attack discovery, enemy-hover binding, mouseover target/cast guards, auto-fire macro syntax, combat-safe routing, queued equipment updates, unequipping, and bag-binding cleanup. Alt-modifier resolution regressions also passed: the prior build has no matching secure action under Alt, while the fixed build resolves Comprehend Scroll and the intended bag slot for all 17 verified IDs. Enhance QoL layout regressions also passed for custom-button discovery, late module loading, deduplication, stable-slot table fallback, bank exclusion, and deferred overlay creation during combat. These mocks do not reproduce the game engine or validate both addons running together in the Forever client.

The addon has not been run inside WoW Forever. Secure-action behavior, spell-name lookup, tooltip detection, and bag button integration require in-game verification on build 70888. Start with an expendable item. Enable errors with /console scriptErrors 1 and report any error text, the item link, and which bag interface you use. Unlisted scroll IDs are not comprehended, even if their name or tooltip matches. Update the verified list if the Forever database adds more eligible scrolls. The repository documents each ID and source in docs/forever-scrolls.md.
