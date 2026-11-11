local addon = CreateFrame("Frame")
local overlays, elapsed, overlayCount = {}, 0, 0
local trackedCount, eligibleCount = 0, 0
local COMPREHEND_SCROLL = 1296017
local scrollIDs = {
    [211780]=true, [211784]=true, [211785]=true, [211786]=true, [211787]=true,
    [211853]=true, [211854]=true, [211855]=true,
    [213543]=true, [213544]=true, [213545]=true, [213546]=true, [213547]=true,
    [281015]=true, [281016]=true, [281017]=true, [281018]=true,
}
local function say(s) print("|cff66ccffQuickProcess:|r " .. s) end
local scrolls = {}
for _, name in ipairs({"CHAP BALK WELLES", "CWAL", "KWYJIBO", "LOWER PING WHOMEVER", "OMIT KESA", "STHENIC LUNATE", "VOCE WELL", "WUBBA WUBBA", "PEATCHY ATTAX", "SHOOBEEDOOP", "THAW WORDS", "TOPAZ YORAK", "UPDOG", "DOST OREM", "FORGOT HOOF THUD", "KEEP CLEF FOCI", "RARE SERVICHI RADAR"}) do
    scrolls["Scroll: " .. name] = true
end
local function spellInfo(id)
    if id == "Comprehend Scroll" then id = COMPREHEND_SCROLL end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(id)
        return info and info.name, info and info.spellID
    elseif GetSpellInfo then
        local name = GetSpellInfo(id)
        return name, type(id) == "number" and id or nil
    end
end
local function learned(id)
    if id == "Comprehend Scroll" then id = COMPREHEND_SCROLL end
    local name, resolved = spellInfo(id)
    resolved = resolved or (type(id) == "number" and id)
    if not name or not resolved then return end
    local bank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player
    if (IsPlayerSpell and IsPlayerSpell(resolved)) or (IsSpellKnown and IsSpellKnown(resolved))
        or (C_SpellBook and C_SpellBook.IsSpellKnown and C_SpellBook.IsSpellKnown(resolved, bank)) then
        return name, resolved
    end
end
local function supportedSpell(value)
    local name, resolved = learned(value)
    if not name then return end
    for _, ability in ipairs({1804, 13262, "Comprehend Scroll"}) do
        if name == learned(ability) then return name, resolved end
    end
end
local function pickable(text)
    -- ContainerItemInfo.isLocked means busy/moving, not a lock to pick.
    local locked = LOCKED or "Locked"
    if ("\n" .. text .. "\n"):find("\n" .. locked .. "\n", 1, true) then return true end
    return text:find("Requires Lockpicking", 1, true) ~= nil
end
local scan = CreateFrame("GameTooltip", "QuickProcessScanTooltip", UIParent, "GameTooltipTemplate")
local function tooltipText(bag, slot)
    scan:SetOwner(UIParent, "ANCHOR_NONE")
    scan:ClearLines()
    scan:SetBagItem(bag, slot)
    local lines = {}
    for i = 1, scan:NumLines() do
        local line = _G["QuickProcessScanTooltipTextLeft" .. i]
        lines[#lines + 1] = line and line:GetText() or ""
    end
    scan:Hide()
    return table.concat(lines, "\n")
end
local function itemInfo(bag, slot)
    if C_Container and C_Container.GetContainerItemInfo then
        return C_Container.GetContainerItemInfo(bag, slot)
    end
    if GetContainerItemInfo then
        local texture, count, locked, quality, _, _, link = GetContainerItemInfo(bag, slot)
        if texture then return {stackCount=count, isLocked=locked, quality=quality, hyperlink=link} end
    end
end
local function choose(bag, slot)
    local info = itemInfo(bag, slot)
    if not info or info.isLocked or not info.hyperlink then return end
    local id = tonumber(info.hyperlink:match("item:(%d+)"))
    if not id then return end
    local custom = QuickProcessDB.items[id]
    if custom then
        local spell, spellID = supportedSpell(custom)
        if spell then return spell, spellID end
    end
    if scrollIDs[id] then return learned(COMPREHEND_SCROLL) end
    local getInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
    if not getInfo then return end
    local name, _, quality, _, _, _, _, _, _, _, _, classID = getInfo(info.hyperlink)
    if not name then return end -- Wait for uncached item data.
    local text = tooltipText(bag, slot)
    if pickable(text) then return learned(1804) end
    if scrolls[name] or text:find("Requires Comprehension", 1, true) then
        return learned("Comprehend Scroll")
    end
    if quality and quality >= 2 and quality <= 4 and (classID == 2 or classID == 4) then
        return learned(13262)
    end
end
local function location(button)
    if button.GetBagID and button.GetID then
        return button:GetBagID(), button:GetID()
    end
    local parent = button:GetParent()
    if parent and parent.GetID and button.GetID then return parent:GetID(), button:GetID() end
end
local function updateButton(button)
    if (type(button) ~= "table" and type(button) ~= "userdata") or not button.IsShown or not button:IsShown() then return end
    local bag, slot = location(button)
    if type(bag) ~= "number" or bag < 0 or bag > 4 or not slot or slot < 1 then return end
    trackedCount = trackedCount + 1
    local spell, spellID = choose(bag, slot)
    if spell then eligibleCount = eligibleCount + 1 end
    local overlay = overlays[button]
    if not spell then
        if overlay then
            UnregisterStateDriver(overlay, "visibility")
            overlay:Hide()
            overlay:SetAttribute("type2", nil)
            overlay:SetAttribute("spell2", nil)
            overlay:SetAttribute("target-bag2", nil)
            overlay:SetAttribute("target-slot2", nil)
            overlay.action = nil
        end
        return
    end
    if not overlay then
        overlayCount = overlayCount + 1
        overlay = CreateFrame("Button", "QuickProcessItemAction" .. overlayCount, button,
            "SecureActionButtonTemplate,SecureHandlerEnterLeaveTemplate,SecureHandlerShowHideTemplate")
        -- A bag action wins over any enemy-hover binding until the pointer leaves.
        overlay:SetAttribute("_onenter", [[
            self:SetBindingClick(true, "ALT-BUTTON2", self:GetName(), "RightButton")
        ]])
        overlay:SetAttribute("_onleave", [[ self:ClearBindings() ]])
        overlay:SetAttribute("_onhide", [[ self:ClearBindings() ]])
        overlay:SetAllPoints(button)
        overlay:SetFrameLevel(button:GetFrameLevel() + 10)
        overlay:RegisterForClicks("RightButtonUp", "RightButtonDown")
        overlay:SetAttribute("useOnKeyDown", false)
        if overlay.SetPassThroughButtons then overlay:SetPassThroughButtons("LeftButton", "MiddleButton") end
        overlay:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local b, s = location(button)
            GameTooltip:SetBagItem(b, s)
            GameTooltip:AddLine("Alt + right-click: " .. (self.processSpell or ""), 0.4, 0.8, 1)
            GameTooltip:Show()
        end)
        overlay:HookScript("OnLeave", function() GameTooltip:Hide() end)
        overlays[button] = overlay
        overlay:Hide()
    end
    -- All protected attributes are prepared outside combat, before the click.
    local action = tostring(spellID or spell) .. "\n" .. bag .. " " .. slot
    if overlay.action == action and overlay:IsShown() == IsAltKeyDown() then return end
    overlay.action = action
    overlay.processSpell = spell
    -- Forever's SecureTemplates.lua targets this bag slot immediately after casting.
    overlay:SetAttribute("type2", "spell")
    overlay:SetAttribute("spell2", spellID or spell)
    overlay:SetAttribute("target-bag2", bag)
    overlay:SetAttribute("target-slot2", slot)
    RegisterStateDriver(overlay, "visibility", "[combat] hide; [mod:alt] show; hide")
end
local function refresh()
    if InCombatLockdown() or not QuickProcessDB then return end
    trackedCount, eligibleCount = 0, 0
    local seen, seenFrames = {}, {}
    local function visit(button)
        if not button or seen[button] then return end
        seen[button] = true
        updateButton(button)
    end
    local function container(frame)
        if not frame or seenFrames[frame] then return end
        seenFrames[frame] = true
        if frame.EnumerateItems then
            -- Forever returns ipairs(self.Items): the first value is an index.
            for first, second in frame:EnumerateItems() do visit(second or first) end
        elseif frame.itemButtonPool and frame.itemButtonPool.EnumerateActive then
            for button in frame.itemButtonPool:EnumerateActive() do visit(button) end
        elseif frame.Items then
            for _, button in ipairs(frame.Items) do visit(button) end
        end
    end
    if ContainerFrameUtil_EnumerateContainerFrames then
        for first, second in ContainerFrameUtil_EnumerateContainerFrames() do container(second or first) end
    end
    container(ContainerFrameCombinedBags)
    for index = 1, (NUM_CONTAINER_FRAMES or 13) do
        container(_G["ContainerFrame" .. index])
        -- Older layouts expose named slots instead of a pool.
        for slot = 1, 40 do visit(_G["ContainerFrame" .. index .. "Item" .. slot]) end
    end
end
local function status()
    if not InCombatLockdown() then refresh() end
    local spell, id = learned(COMPREHEND_SCROLL)
    say("Comprehend Scroll: " .. (spell and (spell .. " (" .. id .. ") learned") or "not learned/detected"))
    say("Visible bag buttons: " .. trackedCount .. "; eligible processing items: " .. eligibleCount .. ".")
    say("Use Alt + right-click outside combat. Ordinary right-click does not comprehend scrolls.")
end
local function scanBags()
    if not C_Container or not C_Container.GetContainerNumSlots then return end
    local getInfo = C_Item and C_Item.GetItemInfo or GetItemInfo
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = itemInfo(bag, slot)
            if info and info.hyperlink then
                local spell, id = choose(bag, slot)
                local name = getInfo and getInfo(info.hyperlink) or info.hyperlink
                say("Bag " .. bag .. " slot " .. slot .. ": " .. (name or info.hyperlink)
                    .. " -> " .. (spell and (spell .. " (" .. tostring(id) .. ")") or "no eligible learned skill"))
            end
        end
    end
end
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("PLAYER_REGEN_ENABLED")
addon:RegisterEvent("BAG_UPDATE_DELAYED")
addon:RegisterEvent("SPELLS_CHANGED")
addon:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        QuickProcessDB = QuickProcessDB or {}
        QuickProcessDB.items = QuickProcessDB.items or {}
        say("Loaded. Alt + right-click an eligible item in the default bags. /qp for help.")
    end
    refresh()
end)
addon:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed >= 0.2 then elapsed = 0; refresh() end
end)
SLASH_QUICKPROCESS1 = "/qp"
SlashCmdList.QUICKPROCESS = function(message)
    if message == "status" then status(); return end
    if message == "scan" then scanBags(); return end
    if message == "ranged" and QuickProcessRangedWeapon and QuickProcessRangedWeapon.Status then
        QuickProcessRangedWeapon.Status()
        return
    end
    if InCombatLockdown() then say("Change settings after combat."); return end
    local id, spell = message:match("^bind%s+(%d+)%s+(.+)$")
    if id then
        if spell:find("[\r\n]") or spell:find("/", 1, true) then say("Enter a spell name or ID."); return end
        local value = tonumber(spell) or spell
        if not supportedSpell(value) then
            say("Choose a learned Pick Lock, Comprehend Scroll or Disenchant ability.")
            return
        end
        QuickProcessDB.items[tonumber(id)] = value
        say("Item " .. id .. " assigned to " .. spell .. ". The spell must be learned.")
        refresh(); return
    end
    id = message:match("^unbind%s+(%d+)$")
    if id then QuickProcessDB.items[tonumber(id)] = nil; refresh(); say("Assignment removed."); return end
    say("Alt + right-click: Pick Lock, Comprehend Scroll or Disenchant when eligible and learned.")
    say("/qp status — show Comprehend Scroll and visible-bag detection. /qp scan — list bag-item decisions.")
    say("/qp ranged — show the detected ranged attack and pending equipment changes.")
    say("/qp bind ITEM_ID SPELL_NAME_OR_ID — assign Pick Lock, Comprehend Scroll or Disenchant.")
    say("/qp unbind ITEM_ID — remove an assignment. Default Blizzard bags only; outside combat.")
end
