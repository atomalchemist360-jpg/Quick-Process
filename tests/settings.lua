local combat=false
function InCombatLockdown() return combat end
local alt,ctrl,shift=false,false,false
function IsAltKeyDown() return alt end
function IsControlKeyDown() return ctrl end
function IsShiftKeyDown() return shift end
dofile('QuickProcess/Settings.lua')
QuickProcessSettings.Initialize()
assert(QuickProcessDB.bagModifier=='alt')
local changes=0
QuickProcessSettings.RegisterCallback(function() changes=changes+1 end)
assert(QuickProcessSettings.SetBagModifier('ctrlshift'))
assert(QuickProcessSettings.BagBinding()=='CTRL-SHIFT-BUTTON2')
assert(QuickProcessSettings.BagVisibility()=='[combat] hide; [nomod:alt,mod:ctrl,mod:shift] show; hide')
ctrl=true; shift=true; assert(QuickProcessSettings.BagModifierDown())
alt=true; assert(not QuickProcessSettings.BagModifierDown())
assert(not QuickProcessSettings.SetBagModifier('bad'))
assert(QuickProcessDB.bagModifier=='ctrlshift')
combat=true; assert(not QuickProcessSettings.SetBagModifier('shift'))
assert(QuickProcessDB.bagModifier=='ctrlshift' and changes==1)
combat=false
-- Reloading the module reads the persisted choice without resetting it.
dofile('QuickProcess/Settings.lua'); QuickProcessSettings.Initialize()
assert(QuickProcessSettings.GetBagModifier()=='ctrlshift')
QuickProcessDB.bagModifier='invalid'; QuickProcessSettings.Initialize()
assert(QuickProcessDB.bagModifier=='alt')
print('PASS: shortcut persistence, validation, exact modifier matching, binding/driver generation, combat rejection, reload and invalid setting recovery')
