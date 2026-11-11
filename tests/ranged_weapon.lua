local weapon, subclass, class, learned, custom = 100, 19, 'MAGE', {}, {}
Enum={SpellBookSpellBank={Player=0}}
function GetInventoryItemID() return weapon end
function UnitClass() return class,class end
C_Item={GetItemInfoInstant=function() return weapon,nil,nil,nil,nil,2,subclass end}
C_SpellBook={
 IsSpellKnown=function(id) return learned[id] end,
 GetNumSpellBookSkillLines=function() return 1 end,
 GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=#custom} end,
 IsRangedAutoAttackSpellBookItem=function(slot) return custom[slot].ranged end,
 GetSpellBookItemInfo=function(slot) return custom[slot] end,
}
dofile('QuickProcess/RangedWeapon.lua')
local function expect(sub,job,spells,result)
 subclass=sub; class=job; learned=spells
 assert(QuickProcessRangedWeapon.FindSpell()==result)
end
expect(19,'MAGE',{[5019]=true},5019)
expect(2,'WARRIOR',{[3018]=true},3018)
expect(3,'ROGUE',{[7918]=true},7918)
expect(18,'WARRIOR',{[7919]=true},7919)
for _, sub in ipairs({2,3,18}) do expect(sub,'HUNTER',{[75]=true,[3018]=true,[7918]=true,[7919]=true},75) end
expect(16,'ROGUE',{[2764]=true},2764)
expect(19,'MAGE',{},nil)
expect(0,'WARRIOR',{[75]=true},nil)
weapon=nil; expect(2,'HUNTER',{[75]=true},nil); weapon=100
custom={{spellID=9001,ranged=true}}; expect(2,'WARRIOR',{[9001]=true},9001)
custom[2]={spellID=9002,ranged=true}; expect(2,'WARRIOR',{[9001]=true,[9002]=true},nil)
print('PASS: wand, bow, gun, crossbow, thrown, Hunter Auto Shot preference, unknown skills, missing/unsupported equipment, custom discovery and ambiguity')
