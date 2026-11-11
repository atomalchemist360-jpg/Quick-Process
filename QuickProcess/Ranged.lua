-- Enemy clicks use secure mouseover bindings, so bag clicks keep their own action.
local weapon = QuickProcessRangedWeapon
local owner = CreateFrame("Frame", "QuickProcessRangedBindingOwner", UIParent, "SecureHandlerStateTemplate")
local attack = CreateFrame("Button", "QuickProcessRangedAttackButton", UIParent, "SecureActionButtonTemplate")
attack:RegisterForClicks("AnyDown", "AnyUp")
local selectedSpell, pending
owner:SetAttribute("_onstate-enemy", [[
    self:ClearBindings()
    if newstate == "hostile" and self:GetAttribute("attack-ready") then
        self:SetBindingClick(true, "ALT-BUTTON2", "QuickProcessRangedAttackButton", "LeftButton")
    end
]])
local function refresh()
    if InCombatLockdown() then pending = true; return end
    pending = false
    UnregisterStateDriver(owner, "enemy")
    owner:SetAttribute("state-enemy", nil)
    ClearOverrideBindings(owner)
    selectedSpell = weapon.FindSpell()
    local name = weapon.SpellName(selectedSpell)
    attack:SetAttribute("type", nil)
    attack:SetAttribute("macrotext", nil)
    owner:SetAttribute("attack-ready", name ~= nil)
    if name then
        -- Select the enemy under the pointer, rather than firing at an unrelated target.
        -- ! starts auto-fire without turning it off when the shortcut is repeated.
        attack:SetAttribute("macrotext", "/target [@mouseover,harm,nodead]\n/cast [@mouseover,harm,nodead] !" .. name)
        attack:SetAttribute("type", "macro")
        RegisterStateDriver(owner, "enemy", "[@mouseover,harm,nodead] hostile; none")
    else
        selectedSpell = nil
    end
end
function weapon.Status()
    local name = weapon.SpellName(selectedSpell)
    if name then
        print("|cff66ccffQuickProcess:|r Alt + right-click an enemy to start " .. name .. ". No melee-range check.")
    else
        print("|cff66ccffQuickProcess:|r No ranged attack ready. Equip a ranged weapon and learn its attack.")
    end
    if pending then print("|cff66ccffQuickProcess:|r Weapon/skill updates are queued until combat ends.") end
end
for _, event in ipairs({"PLAYER_LOGIN", "SPELLS_CHANGED", "PLAYER_EQUIPMENT_CHANGED",
    "PLAYER_REGEN_ENABLED", "GET_ITEM_INFO_RECEIVED"}) do
    owner:RegisterEvent(event)
end
owner:SetScript("OnEvent", function(_, event, slotOrID)
    if event == "PLAYER_EQUIPMENT_CHANGED" and slotOrID ~= 18 then return end
    if event == "PLAYER_REGEN_ENABLED" and not pending then return end
    if event == "GET_ITEM_INFO_RECEIVED" and selectedSpell then return end
    refresh()
end)
