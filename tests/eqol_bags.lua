local frames, scripts, attrs = {}, {}, {}
UIParent = {}; SlashCmdList = {}; NUM_CONTAINER_FRAMES = 1
local alt = true
local combat, known, item = false, true, {stackCount=1, hyperlink='item:123',quality=2}
local kind, itemName, tip = 2, 'Sword', ''
local function frame()
 local f = {shown=true, attributes={},name='TestBagAction'}
 function f:GetName() return self.name end
 function f:GetAttribute(key) return self.attributes[key] end
 function f:SetBindingClick(priority,key,name,button) self.binding={priority,key,name,button} end
 function f:ClearBindings() self.binding=nil end
 function f:SetScript(k,v) self[k]=v end
 function f:HookScript(k,v) self[k]=v end
 function f:SetAttribute(k,v) self.attributes[k]=v end
 function f:IsShown() return self.shown end
 function f:Hide() self.shown=false end
 function f:Show() self.shown=true end
 function f:GetFrameLevel() return 1 end
 function f:GetFrameStrata() return 'MEDIUM' end
 function f:SetFrameStrata(value) self.strata=value end
 function f:GetID() return 1 end
 function f:GetBagID() return 0 end
 function f:NumLines() return 1 end
 for _, k in ipairs({'SetOwner','ClearLines','SetBagItem','SetAllPoints','SetFrameLevel','RegisterForClicks','SetPassThroughButtons','RegisterEvent'}) do f[k]=function() end end
 return f
end
function CreateFrame(_,name,parent,template)
 local f=frame(); frames[#frames+1]=f
 if template and template:find('SecureActionButtonTemplate',1,true) then attrs[#attrs+1]=f end
 return f
end
function InCombatLockdown() return combat end
function IsAltKeyDown() return alt end
function RegisterStateDriver(f,_,condition) assert(not combat); f.condition=condition; if alt then f:Show() else f:Hide() end end
function UnregisterStateDriver() assert(not combat) end
function ClearOverrideBindings(frame) assert(not combat); frame:ClearBindings() end
function IsPlayerSpell() return known end
C_Spell={GetSpellInfo=function(id) return {name=({[1296017]='Comprehend Scroll',[1804]='Pick Lock',[13262]='Disenchant',[31252]='Prospecting',[51005]='Milling'})[id] or id,spellID=type(id)=='number' and id or 999} end}
C_Container={GetContainerItemInfo=function() return item end}
C_Item={GetItemInfo=function() return itemName,nil,item.quality,nil,nil,nil,nil,nil,nil,nil,nil,kind end}
QuickProcessScanTooltipTextLeft1={GetText=function() return tip end}
local bagButton=frame()
-- EQoL replaces Blizzard's bag frames and creates unnamed, stable slot buttons.
local eqolState={buttons={bagButton},itemButtonsByBag={[0]={[1]=bagButton}}}
dofile('QuickProcess/Settings.lua')
dofile('QuickProcess/QuickProcess.lua')
local addon=frames[1]
addon.OnEvent(addon,'PLAYER_LOGIN')
assert(#attrs==0) -- The load-on-demand EQoL module has not created its state yet.
EnhanceQoL={Bags={variables={state=eqolState}}}
addon.OnUpdate(addon,0.21)
local overlay=attrs[1]
assert(overlay) -- Polling discovers the late-loaded module, no global bag hooks.
local bankButton=frame(); bankButton.GetBagID=function() return -1 end
eqolState.itemButtonsByBag[-1]={[1]=bankButton}
addon.OnUpdate(addon,0.21); assert(#attrs==1) -- No bank overlay.

local function modified(frame,name,button,prefix)
 -- WoW Frame:GetAttribute(prefix,name,suffix) accepts exact modifier/button,
 -- wildcard modifier/button, then the bare attribute. It does not try type2
 -- as an Alt-specific fallback.
 local suffix=button=='RightButton' and '2' or '1'
 return frame.attributes[prefix..name..suffix] or frame.attributes['*'..name..suffix]
  or frame.attributes[prefix..name..'*'] or frame.attributes['*'..name..'*']
  or frame.attributes[name]
end
local function click(frame,prefix,button)
 if modified(frame,'type',button,prefix)~='spell' then return end
 return modified(frame,'spell',button,prefix),modified(frame,'target-bag',button,prefix),modified(frame,'target-slot',button,prefix)
end
assert(overlay.strata=='HIGH')
assert(click(overlay,'alt-','LeftButton')==nil)
local initialSpell,initialBag,initialSlot=click(overlay,'alt-','RightButton')
assert(initialSpell==13262 and initialBag==0 and initialSlot==1)
assert(overlay.attributes.useOnKeyDown==false)
assert(overlay.attributes['*type2']=='spell' and overlay.attributes['*spell2']==13262)
assert(overlay.attributes['*target-bag2']==0 and overlay.attributes['*target-slot2']==1)
assert(overlay.condition=='[combat] hide; [mod:alt,nomod:ctrl,nomod:shift] show; hide')
assert(load('local self=...; '..overlay.attributes._onenter))(overlay)
assert(overlay.binding[2]=='ALT-BUTTON2' and overlay.binding[4]=='RightButton')
assert(load('local self=...; '..overlay.attributes._onleave))(overlay); assert(not overlay.binding)
assert(load('local self=...; '..overlay.attributes._onenter))(overlay)
assert(load('local self=...; '..overlay.attributes._onhide))(overlay); assert(not overlay.binding)
kind=7; itemName='Scroll: CWAL'; item.quality=1; item.hyperlink='item:211785'
addon.OnEvent(addon,'BAG_UPDATE_DELAYED')
assert(overlay.attributes['*type2']=='spell' and overlay.attributes['*spell2']==1296017)
assert(overlay.attributes['*target-bag2']==0 and overlay.attributes['*target-slot2']==1)
-- All IDs come from the requested Forever skill page, not name-based lookup.
for _, id in ipairs({211780,211784,211785,211786,211787,211853,211854,211855,213543,213544,213545,213546,213547,281015,281016,281017,281018}) do
 item.hyperlink='item:'..id; itemName='Localized scroll label'; tip=''
 addon.OnEvent(addon,'BAG_UPDATE_DELAYED')
 assert(overlay.attributes['*spell2']==1296017 and overlay.attributes['*type2']=='spell')
 local clickedSpell,clickedBag,clickedSlot=click(overlay,'alt-','RightButton')
 assert(clickedSpell==1296017 and clickedBag==0 and clickedSlot==1)
end
-- A duplicate name and matching tooltip cannot qualify an unlisted ID.
item.hyperlink='item:999999'; itemName='Scroll: CHAP BALK WELLES'; tip='Requires Comprehension (1)'
addon.OnEvent(addon,'BAG_UPDATE_DELAYED'); assert(overlay.attributes['*type2']==nil)
QuickProcessDB.items[999999]=1296017
addon.OnEvent(addon,'BAG_UPDATE_DELAYED'); assert(overlay.attributes['*type2']==nil)
QuickProcessDB.items[999999]=nil
SlashCmdList.QUICKPROCESS('bind 999999 1296017'); assert(QuickProcessDB.items[999999]==nil)
item.hyperlink='item:123'
itemName='Scroll of Strength'; tip=''; addon.OnEvent(addon,'BAG_UPDATE_DELAYED')
assert(overlay.attributes['*type2']==nil)
tip='Locked'; itemName='Iron Lockbox'; addon.OnEvent(addon,'BAG_UPDATE_DELAYED')
assert(overlay.attributes['*type2']=='spell' and overlay.attributes['*spell2']==1804)
assert(overlay.attributes['*target-bag2']==0 and overlay.attributes['*target-slot2']==1)
tip='Requires Lockpicking (125)'; addon.OnEvent(addon,'BAG_UPDATE_DELAYED')
assert(overlay.attributes['*type2']=='spell' and overlay.attributes['*spell2']==1804)
assert(overlay.attributes['*target-bag2']==0 and overlay.attributes['*target-slot2']==1)
LOCKED='Verrouillé'; tip=LOCKED; addon.OnEvent(addon,'BAG_UPDATE_DELAYED')
assert(overlay.attributes['*type2']=='spell' and overlay.attributes['*spell2']==1804)
assert(overlay.attributes['*target-bag2']==0 and overlay.attributes['*target-slot2']==1)
tip='Unlocked'; addon.OnEvent(addon,'BAG_UPDATE_DELAYED'); assert(overlay.attributes['*type2']==nil)
for _, marker in ipairs({'Prospectable','Millable'}) do
 tip=marker; item.stackCount=20; addon.OnEvent(addon,'BAG_UPDATE_DELAYED'); assert(overlay.attributes['*type2']==nil)
end
QuickProcessDB.items[123]=51005; addon.OnEvent(addon,'BAG_UPDATE_DELAYED'); assert(overlay.attributes['*type2']==nil)
SlashCmdList.QUICKPROCESS('bind 123 31252'); assert(QuickProcessDB.items[123]==51005)
known=false; tip='Locked'; addon.OnEvent(addon,'SPELLS_CHANGED'); assert(overlay.attributes['*type2']==nil)
known=true; tip=''; SlashCmdList.QUICKPROCESS('bind 123 1804'); assert(overlay.attributes['*type2']=='spell' and overlay.attributes['*spell2']==1804)
assert(overlay.attributes['*target-bag2']==0 and overlay.attributes['*target-slot2']==1)
item.isLocked=true; addon.OnEvent(addon,'BAG_UPDATE_DELAYED'); assert(overlay.attributes['*type2']==nil)
item.isLocked=false; addon.OnEvent(addon,'BAG_UPDATE_DELAYED')
alt=false; addon.OnEvent(addon,'BAG_UPDATE_DELAYED'); assert(not overlay:IsShown())
alt=true; addon.OnEvent(addon,'BAG_UPDATE_DELAYED'); assert(overlay:IsShown())
combat=false
QuickProcessDB.items={}
item.hyperlink='item:211780'; itemName='Localized untranslated scroll'; tip=''
addon.OnEvent(addon,'BAG_UPDATE_DELAYED')
assert(overlay.attributes['*spell2']==1296017)
-- Standard C_SpellBook signature must receive the player bank.
IsPlayerSpell=nil
Enum={SpellBookSpellBank={Player=7}}
C_SpellBook={IsSpellKnown=function(id,bank) assert(bank==7); return id==1296017 end}
addon.OnEvent(addon,'SPELLS_CHANGED'); assert(overlay.attributes['*spell2']==1296017)
SlashCmdList.QUICKPROCESS('status')
assert(#attrs==1) -- EQoL buttons and itemButtonsByBag entries are deduplicated.
eqolState.buttons={} -- Stable-slot table also works without the visible-order array.
addon.OnUpdate(addon,0.21); assert(overlay.attributes['*spell2']==1296017)
-- A recycled button must target its new bag slot.
bagButton.GetBagID=function() return 2 end
bagButton.GetID=function() return 8 end
addon.OnEvent(addon,'BAG_UPDATE_DELAYED')
assert(overlay.attributes['*target-bag2']==2 and overlay.attributes['*target-slot2']==8)
-- Known scroll IDs do not need cached localized names.
C_Item.GetItemInfo=function() return nil end
addon.OnEvent(addon,'BAG_UPDATE_DELAYED'); assert(overlay.attributes['*spell2']==1296017)
combat=true; addon.OnEvent(addon,'BAG_UPDATE_DELAYED')
-- Loading an EQoL bag button in combat does not create a protected overlay.
local nextButton=frame(); nextButton.GetID=function() return 9 end
eqolState.buttons={bagButton,nextButton}
addon.OnUpdate(addon,0.21); assert(#attrs==1)
combat=false; addon.OnEvent(addon,'PLAYER_REGEN_ENABLED'); assert(#attrs==2)

print('PASS: EQoL-only bags, load-on-demand, stable-slot table, bank exclusion, deferred combat creation, actual Alt-right-click attribute resolution, left-click exclusion, higher bag overlay strata, verified 17 Forever IDs, duplicate name/tooltip rejection, unlisted comprehension assignment rejection, pooled/combined bag enumeration, canonical spell ID, localized scroll IDs, explicit spell bank, recycled slot targeting, uncached scrolls, disenchant, comprehension, ordinary scroll exclusion, locked/unlocked boxes, translated Locked label, material exclusion, removed old mappings, restricted assignments, unlearned spells, busy items, Alt visibility, combat guard')
