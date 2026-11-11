local addon = CreateFrame("Frame")
local overlays, elapsed = {}, 0
local function say(s) print("|cff66ccffQuickProcess:|r " .. s) end
local scrolls = {}
for _, name in ipairs({"CHAP BALK WELLES", "CWAL", "KWYJIBO", "LOWER PING WHOMEVER", "OMIT KESA", "STHENIC LUNATE", "VOCE WELL", "WUBBA WUBBA", "PEATCHY ATTAX", "SHOOBEEDOOP", "THAW WORDS", "TOPAZ YORAK", "UPDOG", "DOST OREM", "FORGOT HOOF THUD", "KEEP CLEF FOCI", "RARE SERVICHI RADAR"}) do
    scrolls["Scroll: " .. name] = true
end
local function spellInfo(id)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(id)
        return info and info.name, info and info.spellID
    elseif GetSpellInfo then
        local name = GetSpellInfo(id)
        return name, type(id) == "number" and id or nil
    end
end
local function learned(id)
    local name, resolved = spellInfo(id)
    resolved = resolved or (type(id) == "number" and id)
    if not name or not resolved then return end
    if (IsPlayerSpell and IsPlayerSpell(resolved)) or (IsSpellKnown and IsSpellKnown(resolved))
        or (C_SpellBook and C_SpellBook.IsSpellKnown and C_SpellBook.IsSpellKnown(resolved)) then
        return name
    end
end
local function supportedSpell(value)
    local name = learned(value)
    if not name then return end
    for _, ability in ipairs({1804, 13262, "Comprehend Scroll"}) do
        if name == learned(ability) then return name end
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
        local spell = supportedSpell(custom)
        if spell then return spell end
    end
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
    if not button or not button:IsShown() then return end
    local bag, slot = location(button)
    if type(bag) ~= "number" or bag < 0 or bag > 4 or not slot or slot < 1 then return end
    local spell = choose(bag, slot)
    local overlay = overlays[button]
    if not spell then
        if overlay then
            UnregisterStateDriver(overlay, "visibility")
            overlay:Hide()
            overlay:SetAttribute("type2", nil)
            overlay.action = nil
        end
        return
    end
    if not overlay then
        overlay = CreateFrame("Button", nil, button, "SecureActionButtonTemplate")
        overlay:SetAllPoints(button)
        overlay:SetFrameLevel(button:GetFrameLevel() + 10)
        overlay:RegisterForClicks("RightButtonUp", "RightButtonDown")
        if overlay.SetPassThroughButtons then overlay:SetPassThroughButtons("LeftButton", "MiddleButton") end
        overlay:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local b, s = location(button)
            GameTooltip:SetBagItem(b, s)
            GameTooltip:AddLine("Alt + right-click: " .. (self.processSpell or ""), 0.4, 0.8, 1)
            GameTooltip:Show()
        end)
        overlay:SetScript("OnLeave", function() GameTooltip:Hide() end)
        overlays[button] = overlay
        overlay:Hide()
    end
    -- All protected attributes are prepared outside combat, before the click.
    local action = spell .. "\n" .. bag .. " " .. slot
    if overlay.action == action and overlay:IsShown() == IsAltKeyDown() then return end
    overlay.action = action
    overlay.processSpell = spell
    overlay:SetAttribute("type2", "macro")
    overlay:SetAttribute("macrotext2", "/cast " .. spell .. "\n/use " .. bag .. " " .. slot)
    RegisterStateDriver(overlay, "visibility", "[combat] hide; [mod:alt] show; hide")
end
local function refresh()
    if InCombatLockdown() or not QuickProcessDB then return end
    for frame = 1, (NUM_CONTAINER_FRAMES or 13) do
        for slot = 1, 40 do updateButton(_G["ContainerFrame" .. frame .. "Item" .. slot]) end
    end
    local combined = ContainerFrameCombinedBags
    if combined and combined.EnumerateItems then
        for button in combined:EnumerateItems() do updateButton(button) end
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
    say("/qp bind ITEM_ID SPELL_NAME_OR_ID — assign Pick Lock, Comprehend Scroll or Disenchant.")
    say("/qp unbind ITEM_ID — remove an assignment. Default Blizzard bags only; outside combat.")
end
