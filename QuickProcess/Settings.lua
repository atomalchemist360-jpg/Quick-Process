QuickProcessSettings = {}
local settings = QuickProcessSettings
settings.choices = {
    {key="alt", label="Alt"}, {key="ctrl", label="Ctrl"}, {key="shift", label="Shift"},
    {key="altctrl", label="Alt + Ctrl"}, {key="altshift", label="Alt + Shift"},
    {key="ctrlshift", label="Ctrl + Shift"}, {key="altctrlshift", label="Alt + Ctrl + Shift"},
}
local callbacks = {}
local function valid(key)
    for _, choice in ipairs(settings.choices) do if choice.key == key then return true end end
end
function settings.Initialize()
    QuickProcessDB = QuickProcessDB or {}
    if not valid(QuickProcessDB.bagModifier) then QuickProcessDB.bagModifier = "alt" end
end
function settings.GetBagModifier()
    local key = QuickProcessDB and QuickProcessDB.bagModifier
    return valid(key) and key or "alt"
end
function settings.BagLabel()
    local key = settings.GetBagModifier()
    for _, choice in ipairs(settings.choices) do
        if choice.key == key then return choice.label .. " + right-click" end
    end
end
function settings.BagBinding()
    local key, parts = settings.GetBagModifier(), {}
    for _, mod in ipairs({"alt", "ctrl", "shift"}) do
        if key:find(mod, 1, true) then parts[#parts + 1] = mod:upper() end
    end
    return table.concat(parts, "-") .. "-BUTTON2"
end
function settings.BagVisibility()
    local key, conditions = settings.GetBagModifier(), {}
    for _, mod in ipairs({"alt", "ctrl", "shift"}) do
        conditions[#conditions + 1] = (key:find(mod, 1, true) and "mod:" or "nomod:") .. mod
    end
    return "[combat] hide; [" .. table.concat(conditions, ",") .. "] show; hide"
end
function settings.BagModifierDown()
    local key = settings.GetBagModifier()
    local down = {
        alt = IsAltKeyDown and IsAltKeyDown() or false,
        ctrl = IsControlKeyDown and IsControlKeyDown() or false,
        shift = IsShiftKeyDown and IsShiftKeyDown() or false,
    }
    for _, mod in ipairs({"alt", "ctrl", "shift"}) do
        if (key:find(mod, 1, true) ~= nil) ~= down[mod] then return false end
    end
    return true
end
function settings.RegisterCallback(callback) callbacks[#callbacks + 1] = callback end
function settings.SetBagModifier(key)
    if not valid(key) then return false, "Choose a listed modifier." end
    if InCombatLockdown() then return false, "Change the bag shortcut after combat." end
    settings.Initialize()
    if QuickProcessDB.bagModifier == key then return true end
    QuickProcessDB.bagModifier = key
    for _, callback in ipairs(callbacks) do callback() end
    return true
end
