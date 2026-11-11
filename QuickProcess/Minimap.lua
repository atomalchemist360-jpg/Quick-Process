-- A lightweight minimap launcher; no external libraries or artwork required.
local launcher = CreateFrame("Frame")
launcher:RegisterEvent("PLAYER_LOGIN")
launcher:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    QuickProcessDB = QuickProcessDB or {}
    QuickProcessDB.minimapAngle = tonumber(QuickProcessDB.minimapAngle) or 220

    local panel = CreateFrame("Frame", "QuickProcessHelpPanel", UIParent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    panel:SetSize(360, 250)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
    })
    panel:SetBackdropColor(0.025, 0.045, 0.065, 0.98)
    panel:SetBackdropBorderColor(0.35, 0.75, 0.85, 1)
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -20)
    title:SetText("|cff66ddedQP|r  QuickProcess")
    local text = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", 20, -58)
    text:SetWidth(320)
    text:SetJustifyH("LEFT")
    text:SetSpacing(5)
    text:SetText("|cff66ddedCtrl + right-click|r an eligible bag item.\n\nDisenchant equipment or Comprehend Scroll.\nProspect or mill when supported and learned.\n\n|cffffd166Additional item skills|r\n/qp bind ITEM_ID SPELL_NAME_OR_ID\n/qp unbind ITEM_ID\n\nDefault bags only. Processing requires leaving combat.")
    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)
    close:SetScript("OnClick", function() panel:Hide() end)
    UISpecialFrames = UISpecialFrames or {}
    table.insert(UISpecialFrames, "QuickProcessHelpPanel")
    panel:Hide()

    local button = CreateFrame("Button", "QuickProcessMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetPoint("CENTER")
    background:SetSize(24, 24)
    background:SetVertexColor(0.04, 0.14, 0.19, 1)
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", 0, 0)
    local letters = button:CreateFontString(nil, "OVERLAY")
    letters:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    letters:SetPoint("CENTER", 0, 1)
    letters:SetText("|cff66ddedQ|r|cffffd166P|r")
    letters:SetShadowColor(0, 0, 0, 1)
    letters:SetShadowOffset(1, -1)

    local function position()
        local radians = math.rad(QuickProcessDB.minimapAngle)
        local radiusX = Minimap:GetWidth() / 2 + 5
        local radiusY = Minimap:GetHeight() / 2 + 5
        button:ClearAllPoints()
        button:SetPoint("CENTER", Minimap, "CENTER",
            math.cos(radians) * radiusX, math.sin(radians) * radiusY)
    end
    local dragging = false
    button:SetScript("OnDragStart", function()
        dragging = true
        GameTooltip:Hide()
        button:SetScript("OnUpdate", function()
            local x, y = GetCursorPosition()
            local centerX, centerY = Minimap:GetCenter()
            local scale = Minimap:GetEffectiveScale()
            if not centerX or not centerY or not scale or scale == 0 then return end
            local dx = (x / scale - centerX) / (Minimap:GetWidth() / 2 + 5)
            local dy = (y / scale - centerY) / (Minimap:GetHeight() / 2 + 5)
            QuickProcessDB.minimapAngle = math.deg(math.atan2(dy, dx))
            position()
        end)
    end)
    button:SetScript("OnDragStop", function()
        button:SetScript("OnUpdate", nil)
        -- Keep the drag release from opening the help panel.
        dragging = true
    end)
    button:SetScript("OnMouseDown", function() dragging = false end)
    button:SetScript("OnClick", function()
        if dragging then dragging = false; return end
        panel:SetShown(not panel:IsShown())
    end)
    button:SetScript("OnEnter", function()
        if dragging then return end
        GameTooltip:SetOwner(button, "ANCHOR_LEFT")
        GameTooltip:AddLine("QuickProcess", 0.4, 0.87, 0.93)
        GameTooltip:AddLine("Click: instructions and commands", 1, 1, 1)
        GameTooltip:AddLine("Drag: move around the minimap", 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    Minimap:HookScript("OnSizeChanged", position)
    position()
end)
