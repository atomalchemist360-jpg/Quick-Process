local frames, bindings, sequence = {}, {}, 0
local combat, hostile, weapon, sub, class = false, false, 100, 19, 'MAGE'
local known = {[5019]=true,[75]=true,[3018]=true,[7918]=true,[7919]=true}
local secure = false
UIParent={}; Enum={SpellBookSpellBank={Player=0}}
local function run(frame, snippet, state)
 secure=true
 local ok,err=pcall(assert(load('local self,newstate = ...; '..snippet)),frame,state)
 secure=false
 assert(ok,err)
end
function CreateFrame(_,name)
 local f={name=name,a={},scripts={},events={}}
 frames[name]=f
 function f:SetAttribute(k,v) assert(not combat or secure); self.a[k]=v end
 function f:GetAttribute(k) return self.a[k] end
 function f:GetName() return self.name end
 function f:RegisterForClicks(...) self.clicks={...} end
 function f:RegisterEvent(event) self.events[event]=true end
 function f:SetScript(event,fn) self.scripts[event]=fn end
 function f:ClearBindings() assert(not combat or secure); bindings[self.name]=nil end
 function f:SetBindingClick(priority,key,name,button)
  assert(not combat or secure); assert(priority and key=='ALT-BUTTON2')
  sequence=sequence+1; bindings[self.name]={name=name,button=button,sequence=sequence}
 end
 return f
end
function InCombatLockdown() return combat end
function ClearOverrideBindings(frame) assert(not combat); frame:ClearBindings() end
function UnregisterStateDriver(frame) assert(not combat); frame.driver=nil end
local function state(frame)
 if frame.driver then run(frame,frame.a['_onstate-enemy'],hostile and 'hostile' or 'none') end
end
function RegisterStateDriver(frame,id,condition)
 assert(not combat); assert(id=='enemy'); frame.driver=condition; state(frame)
end
function GetInventoryItemID() return weapon end
function UnitClass() return class,class end
C_Item={GetItemInfoInstant=function() return weapon,nil,nil,nil,nil,2,sub end}
C_SpellBook={IsSpellKnown=function(id) return known[id] end}
C_Spell={GetSpellName=function(id) return ({[5019]='Shoot',[75]='Auto Shot',[3018]='Shoot Bow',[7918]='Shoot Gun',[7919]='Shoot Crossbow'})[id] end}
dofile('QuickProcess/RangedWeapon.lua')
dofile('QuickProcess/Ranged.lua')
local owner=frames.QuickProcessRangedBindingOwner
local attack=frames.QuickProcessRangedAttackButton
local function event(event,slot) owner.scripts.OnEvent(owner,event,slot) end
local function active() return bindings[owner.name] end
event('PLAYER_LOGIN')
assert(not active())
assert(attack.a.macrotext=='/target [@mouseover,harm,nodead]\n/cast [@mouseover,harm,nodead] !Shoot')
assert(attack.a.type=='macro')
hostile=true; state(owner); assert(active().name==attack.name)
hostile=false; state(owner); assert(not active()) -- Friendly/dead/no mouseover state.
combat=true; hostile=true; state(owner); assert(active()) -- Secure binding allowed during combat.
local macro=attack.a.macrotext
sub=2; class='HUNTER'; event('PLAYER_EQUIPMENT_CHANGED',18)
assert(attack.a.macrotext==macro) -- No protected attribute changes while fighting.
QuickProcessRangedWeapon.Status()
combat=false; event('PLAYER_REGEN_ENABLED')
assert(attack.a.macrotext:find('!Auto Shot',1,true))
local oldMacro=attack.a.macrotext
sub=3; event('PLAYER_EQUIPMENT_CHANGED',16); assert(attack.a.macrotext==oldMacro)
class='ROGUE'; event('PLAYER_EQUIPMENT_CHANGED',18); assert(attack.a.macrotext:find('!Shoot Gun',1,true))
weapon=nil; event('PLAYER_EQUIPMENT_CHANGED',18)
assert(not active() and attack.a.type==nil and attack.a.macrotext==nil)
weapon=100; sub=18; event('PLAYER_EQUIPMENT_CHANGED',18)
assert(attack.a.macrotext:find('!Shoot Crossbow',1,true))
assert(owner.driver=='[@mouseover,harm,nodead] hostile; none')
print('PASS: enemy-hover-only Alt binding, guarded mouseover target/cast, non-toggle auto-fire, secure combat routing, equipment deferral, Hunter Auto Shot, unequipping, restoration')
