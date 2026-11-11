# QuickProcess — Forever 1.60.1 beta

[Download the latest installable ZIP](https://github.com/atomalchemist360-jpg/Quick-Process/raw/refs/heads/main/downloads/QuickProcess.zip)


Interface 16001; intended for build 70888.

## Install

Exit WoW, extract the archive, and copy the QuickProcess folder into the game client's Interface/AddOns folder. The layout must be Interface/AddOns/QuickProcess/QuickProcess.toc. Restart the client and enable QuickProcess in the character-selection AddOns list.

## Bag items

Hold Alt and right-click an eligible item in the default Blizzard bags outside combat. One click prepares and executes a cast on that bag slot. Wait for the cast and loot to finish before clicking again. Items are consumed according to the selected skill, including equipment destroyed by Disenchant.

Automatic selection:
- Disenchant: uncommon, rare, or epic weapons and armor, if Disenchant is learned. The game determines final eligibility and skill requirements; some equipment cannot be disenchanted.
- Comprehend Scroll: 17 documented English scroll names or an English tooltip containing “Requires Comprehension”, if Comprehend Scroll is learned.
- Pick Lock: items whose tooltip contains a standalone Locked line (using the client translation) or “Requires Lockpicking”, if Pick Lock is learned. Already unlocked boxes retain normal behavior. The game checks your lockpicking skill and any tool requirements.

Other items retain normal bag behavior. Left-click passes through the overlay where the client supports SetPassThroughButtons. Item processing is disabled during combat. Bank slots, equipped items, and third-party bag addons are not supported in this beta.

## Ranged attacks

Equip a wand, bow, gun, crossbow, or thrown weapon and learn its attack. **Alt + right-click a living enemy under the pointer** to select it and attempt the equipped weapon's ranged attack. Hunters use Auto Shot for bows, guns, and crossbows when learned. Other characters use their weapon's Shoot ability; thrown weapons use Throw. Repeated clicks request auto-fire without toggling it off; Throw may require a click for each attack.

The ranged shortcut works during combat and attempts at any distance. The game still enforces weapon range, ammunition, facing, line of sight, and other requirements. There is no melee-distance check. It uses the enemy under the pointer, not an unrelated current target. The ranged binding is active only while hovering a living hostile unit, with a secure bag-item binding taking priority over it when processing an item. Ordinary right-click is not rebound.

Type `/qp ranged` to see the detected attack. Changes to equipment or learned attacks during combat apply after combat ends. Disable the standalone Rightclick Improvement addon if you no longer want its separate Shift + right-click shortcut; QuickProcess supplies the integrated Alt + right-click behavior.

## Minimap button

The minimap launcher has a turquoise Q and gold P inside a round border. Click it for usage instructions and commands; drag it around the minimap to reposition it. Its position is saved between sessions. Press Escape or click the close button to dismiss the panel.

## Item assignments / localized items

Type /qp for help. To map an item to a learned Pick Lock, Comprehend Scroll, or Disenchant spell:

    /qp bind ITEM_ID SPELL_NAME_OR_ID
    /qp unbind ITEM_ID

Use a numeric spell ID where possible, especially on non-English clients. A custom mapping overrides automatic selection for that item. Only these three abilities are accepted. Old assignments to other abilities are ignored. Mapping validity, target eligibility, required quantities, and skill requirements are ultimately enforced by the game.

## Verification and limitations

Mocked API checks passed for disenchant selection, comprehension selection, pick-lock selection, already unlocked boxes, ordinary scroll exclusion, unsupported materials, unknown spells, restricted custom mappings, busy items, Alt-only visibility, and the combat update guard. Lua source loads under Lua 5.4 and uses syntax compatible with WoW's Lua 5.1.

Ranged-attack mock checks also passed for weapon selection, Hunter Auto Shot preference, custom attack discovery, enemy-hover binding, mouseover target/cast guards, auto-fire macro syntax, combat-safe routing, queued equipment updates, unequipping, and bag-binding cleanup. These mocks do not reproduce the game engine.

The addon has not been run inside WoW Forever. Secure-action behavior, spell-name lookup, tooltip detection, and bag button integration require in-game verification on build 70888. Start with an expendable item. Enable errors with /console scriptErrors 1 and report any error text, the item link, and which bag interface you use. Ordinary non-English scroll detection requires manual mappings until localized item IDs are added.
