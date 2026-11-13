-- Work-count regression, not a measurement of real game CPU time.
local reads,tooltips,drivers=0,0,0
local timers,frames={},{}
UIParent={}; SlashCmdList={}; NUM_CONTAINER_FRAMES=1
local visible=true
local function frame()
 local f={attributes={},scripts={},shown=true}
 function f:SetScript(k,v) self.scripts[k]=v end
 function f:HookScript(k,v) self.scripts[k]=v end
 function f:SetAttribute(k,v) self.attributes[k]=v end
 function f:IsShown() return self.shown and visible end
 function f:Hide() self.shown=false end
 function f:Show() self.shown=true end
 function f:GetFrameLevel() return 1 end
 function f:GetFrameStrata() return 'MEDIUM' end
 function f:GetBagID() return 0 end
 function f:NumLines() return 0 end
 function f:SetBagItem() tooltips=tooltips+1 end
 for _,k in ipairs({'RegisterEvent','SetAllPoints','SetFrameStrata','SetFrameLevel','RegisterForClicks','SetPassThroughButtons','SetOwner','ClearLines'}) do f[k]=function() end end
 return f
end
function CreateFrame() local f=frame(); frames[#frames+1]=f; return f end
function InCombatLockdown() return false end
function IsAltKeyDown() return false end
function IsPlayerSpell(id) return id==1296017 end
function RegisterStateDriver() drivers=drivers+1 end
function UnregisterStateDriver() end
function ClearOverrideBindings() end
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
local function drain()
 local pending=timers; timers={}; for _,fn in ipairs(pending) do fn() end
 assert(#timers==0,'Unexpected self-scheduling loop')
end
function hooksecurefunc(owner,key,callback)
 local original=owner[key]
 owner[key]=function(...) original(...); callback(...) end
end
C_Spell={GetSpellInfo=function(id) return {name=tostring(id),spellID=id} end}
C_Container={GetContainerItemInfo=function(_,slot)
 reads=reads+1; return {hyperlink='item:'..(slot==1 and 211786 or (10000+slot)),quality=1}
end}
C_Item={GetItemInfo=function() return 'Ordinary item',nil,1,nil,nil,nil,nil,nil,nil,nil,nil,7 end}
ContainerFrame1=frame(); ContainerFrame1.Items={}
function ContainerFrame1:EnumerateItems() return ipairs(self.Items) end
for i=1,100 do local b=frame(); b.GetID=function() return i end; ContainerFrame1.Items[i]=b end
dofile('QuickProcess/Settings.lua')
dofile(os.getenv('QP_TEST_SOURCE') or 'QuickProcess/QuickProcess.lua')
local addon=frames[1]
addon.scripts.OnEvent(addon,'PLAYER_LOGIN'); drain()
local initialReads,initialTooltips=reads,tooltips
for i=1,600 do if addon.scripts.OnUpdate then addon.scripts.OnUpdate(addon,1/60) end end
drain()
print('10s idle / 100 bag slots: item reads='..(reads-initialReads)..', hidden tooltip builds='..(tooltips-initialTooltips))
if os.getenv('QP_TEST_SOURCE') then return end
assert(addon.scripts.OnUpdate==nil,'No perpetual bag polling')
assert(reads==initialReads and tooltips==0)
local before=reads
local registered=drivers
for i=1,100 do addon.scripts.OnEvent(addon,'BAG_UPDATE_DELAYED') end
assert(#timers==1,'A burst should queue only one refresh')
drain(); assert(reads-before==100)
assert(drivers==registered,'Unchanged actions must not re-register visibility drivers')
for i=1,100 do addon.scripts.OnEvent(addon,'GET_ITEM_INFO_RECEIVED',999999) end
assert(#timers==0,'Unrelated item loads must not trigger bag work')
ContainerFrame1.scripts.OnShow(); assert(#timers==1); drain()
EnhanceQoL={Bags={functions={ShowFrame=function() end,RequestLayoutUpdate=function() end},Core={AssignStableButtonsToLayout=function() end},variables={state={buttons={}}}}}
addon.scripts.OnEvent(addon,'ADDON_LOADED'); drain()
EnhanceQoL.Bags.functions.ShowFrame(); EnhanceQoL.Bags.Core.AssignStableButtonsToLayout()
assert(#timers==1); drain()
print('PASS: zero idle scans, zero hidden tooltips without Pick Lock, event coalescing, unchanged-driver reuse, unrelated-item filtering, Blizzard reopen hook, late-loaded EQoL layout hooks')
