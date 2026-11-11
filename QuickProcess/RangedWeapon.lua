-- Weapon selection adapted from the user's AutoattackImprovement addon.
-- This module only selects attacks; it never casts or changes bindings.
QuickProcessRangedWeapon = {}
local ranged = QuickProcessRangedWeapon
local candidates = {
    [2] = {75, 3018},   -- Bow: Hunter Auto Shot, Shoot Bow.
    [3] = {75, 7918},   -- Gun: Hunter Auto Shot, Shoot Gun.
    [16] = {2764},     -- Thrown.
    [18] = {75, 7919}, -- Crossbow: Hunter Auto Shot, Shoot Crossbow.
    [19] = {5019},     -- Wand: Shoot.
}
local function known(spellID)
    local bank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player
    if C_SpellBook and C_SpellBook.IsSpellKnown then
        return C_SpellBook.IsSpellKnown(spellID, bank)
    end
    return (IsPlayerSpell and IsPlayerSpell(spellID)) or (IsSpellKnown and IsSpellKnown(spellID))
end
function ranged.FindSpell()
    local itemID = GetInventoryItemID("player", 18)
    if not itemID then return end
    local instant = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
    if not instant then return end
    local _, _, _, _, _, classID, subclass = instant(itemID)
    if classID ~= 2 or not candidates[subclass] then return end
    local _, class = UnitClass("player")
    for _, spellID in ipairs(candidates[subclass]) do
        if (spellID ~= 75 or class == "HUNTER") and known(spellID) then return spellID end
    end
    -- Custom Forever ranged auto attacks: accept only one known, unambiguous match.
    if not (C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines
        and C_SpellBook.GetSpellBookSkillLineInfo and C_SpellBook.GetSpellBookItemInfo
        and C_SpellBook.IsRangedAutoAttackSpellBookItem) then return end
    local bank = Enum.SpellBookSpellBank.Player
    local found
    for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local info = C_SpellBook.GetSpellBookSkillLineInfo(line)
        if info then
            for slot = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do
                if C_SpellBook.IsRangedAutoAttackSpellBookItem(slot, bank) then
                    local spell = C_SpellBook.GetSpellBookItemInfo(slot, bank)
                    if spell and spell.spellID and not spell.isOffSpec and known(spell.spellID) then
                        if found and found ~= spell.spellID then return end
                        found = spell.spellID
                    end
                end
            end
        end
    end
    return found
end
function ranged.SpellName(spellID)
    if not spellID then return end
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(spellID) end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        return info and info.name
    end
    if GetSpellInfo then return GetSpellInfo(spellID) end
end
