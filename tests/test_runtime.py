"""Lua 5.1 control-flow regressions; mocks are not live-client tests.

Usage: python -B tests/test_runtime.py <directory containing lupa>
Set BAGNON_TEST_REVISION to exercise the same assertions against an older commit.
"""
import os
from pathlib import Path
import subprocess
import sys
import unittest

if len(sys.argv) > 1 and Path(sys.argv[1]).is_dir():
    sys.path.insert(0, sys.argv.pop(1))
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]

def source(path):
    revision = os.environ.get("BAGNON_TEST_REVISION")
    if revision:
        return subprocess.check_output(["git", "show", revision + ":" + path], cwd=ROOT, text=True, encoding="utf8")
    return (ROOT / path).read_text(encoding="utf-8-sig")

MOCKS = r'''
Bagnon_EngineReady=true; BagnonSets={}; KEYRING_CONTAINER=-2
UISpecialFrames={}; SlashCmdList={}; tinsert=table.insert; format=string.format
table.wipe=function(t) for k in pairs(t) do t[k]=nil end end
bagSizes={[0]=2,[1]=2,[2]=1}; contents={}; enchants={}; metadata={}; lookups={}
frames={}; messages={}; sortBags=0; sortBank=0; now=1
local methods={}
function methods:GetName() return self.name end
function methods:GetParent() return self.parent end
function methods:SetParent(v) self.parent=v end
function methods:SetID(v) self.id=v end
function methods:GetID() return self.id end
function methods:SetScript(k,v) self.scripts[k]=v end
function methods:GetScript(k) return self.scripts[k] end
function methods:RegisterEvent(k) self.events[k]=true end
function methods:UnregisterEvent(k) self.events[k]=nil end
function methods:SetAlpha(v) assert(type(v)=='number' and v>=0 and v<=1); self.alpha=v end
function methods:GetAlpha() return self.alpha or 1 end
function methods:SetScale(v) assert(type(v)=='number' and v>0); self.scale=v end
function methods:GetScale() return self.scale or 1 end
function methods:SetWidth(v) assert(v==v and v>0); self.width=v end
function methods:GetWidth() return self.width or 200 end
function methods:SetHeight(v) assert(v==v and v>0); self.height=v end
function methods:GetHeight() return self.height or 40 end
function methods:SetPoint(...) self.point={...} end
function methods:GetLeft() return self.left or 100 end
function methods:GetTop() return self.top or 400 end
function methods:GetRight() return 900 end
function methods:SetText(v) self.text=v end
function methods:GetText() return self.text end
function methods:SetTexture(v) self.texture=v end
function methods:SetTextColor(...) self.color={...} end
function methods:SetBackdropColor(r,g,b,a) assert(type(r)=='number' and type(g)=='number' and type(b)=='number' and type(a)=='number'); self.bg={r,g,b,a} end
function methods:SetFrameStrata(v) assert(v); self.strata=v end
function methods:SetValue(v) assert(type(v)=='number'); self.value=v end
function methods:SetChecked(v) self.checked=v end
function methods:Show() self.shown=true end
function methods:Hide() self.shown=false end
function methods:IsShown() return self.shown end
function methods:IsVisible() return self.shown end
function methods:GetFrameLevel() return 2 end
function methods:StartMoving() self.moving=true end
function methods:StopMovingOrSizing() self.moving=false end
function methods:CreateTexture() return CreateFrame('Texture',nil,self) end
function methods:CreateFontString() return CreateFrame('FontString',nil,self) end
function methods:NumLines() return 0 end
function methods:ClearLines() end
function methods:SetBagItem() end
for _,k in ipairs({'ClearAllPoints','SetBackdrop','SetBackdropBorderColor','EnableMouse','SetAllPoints',
 'SetFrameLevel','SetTexCoord','SetFont','SetShadowOffset','SetShadowColor','RegisterForClicks',
 'RegisterForDrag','SetClampedToScreen','SetVertexColor','SetOwner'}) do methods[k]=function() end end
function CreateFrame(kind,name,parent,template)
 local f=setmetatable({name=name,parent=parent,scripts={},events={},shown=true},{__index=methods})
 frames[#frames+1]=f; if name then _G[name]=f end
 if template=='BagnonItemTemplate' then
  for _,suffix in ipairs({'Border','Cooldown','NormalTexture','IconTexture','Count'}) do CreateFrame('Frame',name..suffix,f) end
 end
 return f
end
function getglobal(n) return _G[n] end
UIParent=CreateFrame('Frame','UIParent'); BankFrame=CreateFrame('Frame','BankFrame')
function UnitName() return 'Player' end
function GetRealmName() return 'Realm' end
function GetMoney() return 100 end
function GetTime() return now end
function GetContainerNumSlots(b) return bagSizes[b] or 0 end
function GetKeyRingSize() return 0 end
function ContainerIDToInventoryID(b) return b+19 end
function GetInventoryItemTexture() return 'bag' end
function GetInventoryItemCount() return 1 end
function GetInventoryItemLink() return 'item:123:0:0:0' end
function GetContainerItemInfo(b,s)
 local item=contents[b..':'..s]
 if item then return item.texture or 'weapon',item.count or 1,item.locked,nil,false end
end
function GetContainerItemLink(b,s) local item=contents[b..':'..s]; return item and item.link end
function GetItemInfo(id) return 'Item',id,3,60,'Weapon','Sword',1,'INVTYPE_WEAPON','weapon' end
function GetContainerItemCooldown() return 0,0,0 end
function CooldownFrame_SetTimer(f,...) f.cooldown={...} end
function SetItemButtonTexture(f,v) f.texture=v end
function SetItemButtonCount(f,v) f.count=v end
function SetItemButtonDesaturated(f,v) f.locked=v end
function SetItemButtonTextureVertexColor() end
function MoneyFrame_Update() end
function PlaySound() end
function BagnonMsg(v) messages[#messages+1]=v end
DEFAULT_CHAT_FRAME={AddMessage=function(self,v) messages[#messages+1]=v end}
function GetAddOnMetadata() return '2.2.1' end
function GetBuildInfo() return '1.12.1' end
function GetCursorPosition() return 100,400 end
C_Container={
 GetContainerItemID=function(b,s) return contents[b..':'..s] and 123 end,
 CalculateTotalNumberOfFreeBagSlots=function() return 3 end,
 GetContainerNumFreeSlots=function() return 1 end,
 SortBags=function() sortBags=sortBags+1 end,
 SortBankBags=function() sortBank=sortBank+1 end,
 GetSortBagsRightToLeft=function() return reverse end,
 GetBackpackAutosortDisabled=function() return excludeBackpack end,
 GetBankAutosortDisabled=function() return excludeBank end,
 SetSortBagsRightToLeft=function(v) reverse=v end
}
C_Item={
 GetItemTempEnchantInfo=function(loc)
  local key=loc.bagID..':'..loc.slotIndex; lookups[#lookups+1]=key
  local e=enchants[key]
  if e then return true,e.ms,e.charges,e.id end
  return false,0,0,0
 end,
 GetEnchantInfo=function(id) return metadata[id] end
}
C_Spell={GetSpellTexture=function(id) return 'spell:'..id end}
GameTooltip=CreateFrame('GameTooltip','GameTooltip')
function GameTooltip:IsOwned() return false end
function fire(f,e,...) f.scripts.OnEvent(f,e,...) end
'''

class RuntimeTests(unittest.TestCase):
    def setUp(self):
        self.lua=LuaRuntime(unpack_returned_tuples=True)
        self.runlua(MOCKS)
        self.load('localization.lua','core/Utility.lua','core/Item.lua','core/Frame.lua')

    def runlua(self,code):
        self.lua.execute(code)

    def load(self,*files):
        for file in files:
            self.runlua(source(file))

    def inventory(self):
        self.runlua('''
            Bagnon=CreateFrame('Button','Bagnon',UIParent)
            CreateFrame('FontString','BagnonTitle',Bagnon)
            CreateFrame('Button','BagnonFreeSlots',Bagnon)
            BagnonFrame_Load(Bagnon,{0,1,2},'%s Inventory')
        ''')

    def test_exact_location_enchants_and_neutral_unknown_metadata(self):
        self.runlua('''
            contents['0:1']={}; contents['0:2']={}
            enchants['0:1']={ms=61000,charges=20,id=100}; metadata[100]={spellID=900}
            enchants['0:2']={ms=9000,charges=4,id=101}
        ''')
        self.inventory()
        self.runlua(r'''
            local a,b=Bagnon.items[1].enchantOverlay,Bagnon.items[2].enchantOverlay
            assert(a and b and a:IsShown() and b:IsShown())
            assert(a.icon.texture=='spell:900' and a.duration.text=='1m')
            assert(b.icon.texture=='Interface\\Icons\\INV_Misc_QuestionMark' and b.duration.text=='4c')
            assert(b.duration.color[2]==0.4)
        ''')

    def test_slot_replacement_and_expiration_clear_badge_on_refresh(self):
        self.runlua("contents['0:1']={}; enchants['0:1']={ms=1000,charges=0,id=100}")
        self.inventory()
        self.runlua('''
            local item=Bagnon.items[1]; assert(item.enchantOverlay:IsShown())
            enchants['0:1']=nil; BagnonFrame_Update(Bagnon,0)
            assert(not item.enchantOverlay:IsShown())
            enchants['0:1']={ms=50000,charges=8,id=200}; metadata[200]={spellID=901}
            BagnonFrame_Update(Bagnon,0)
            assert(item.enchantOverlay.icon.texture=='spell:901')
            assert(item.enchantOverlay.duration.text=='50s·8')
            contents['0:1']=nil; BagnonFrame_Update(Bagnon,0)
            assert(not item.enchantOverlay:IsShown())
        ''')

    def test_badge_toggle_and_cached_view_do_not_read_live_enchants(self):
        self.runlua("contents['0:1']={}; enchants['0:1']={ms=1000,charges=0,id=100}")
        self.inventory()
        self.load('options/Options.lua')
        self.runlua('''
            BagnonOptions_ShowEnchants(false)
            assert(not Bagnon.items[1].enchantOverlay:IsShown())
            BagnonOptions_ShowEnchants(true)
            assert(Bagnon.items[1].enchantOverlay:IsShown())
            local reads=#lookups
            BagnonDB={GetItemData=function() return 'item:123:0:0:0',1,'weapon',3 end}
            Bagnon.player='Other'; BagnonItem_Update(Bagnon.items[1])
            assert(#lookups==reads and not Bagnon.items[1].enchantOverlay:IsShown())
            Bagnon.items[1].isLink=nil; Bagnon.items[1]:GetParent():SetID(-1)
            BagnonItem_UpdateEnchant(Bagnon.items[1]); assert(#lookups==reads)
        ''')

    def test_hidden_bag_bar_resize_rebinds_all_item_buttons_before_update(self):
        self.inventory()
        self.load('Events.lua')
        self.runlua('''
            local events=frames[#frames]; fire(events,'ADDON_LOADED','Bagnon')
            assert(Bagnon.size==5 and Bagnon.items[5]:GetParent():GetID()==2)
            bagSizes[1]=4; fire(events,'BAG_UPDATE',1)
            assert(Bagnon.size==7)
            assert(Bagnon.items[5]:GetParent():GetID()==1 and Bagnon.items[5]:GetID()==3)
            assert(Bagnon.items[7]:GetParent():GetID()==2)
            bagSizes[1]=1; fire(events,'BAG_UPDATE',1)
            assert(Bagnon.size==4 and not Bagnon.items[5]:IsShown())
            assert(Bagnon.items[4]:GetParent():GetID()==2)
        ''')

    def test_equal_total_capacity_changes_still_rebind_each_bag(self):
        self.inventory()
        self.runlua('''
            bagSizes[1]=1; bagSizes[2]=2; BagnonFrame_Update(Bagnon,2)
            assert(Bagnon.size==5)
            assert(Bagnon.items[4]:GetParent():GetID()==2 and Bagnon.items[4]:GetID()==1)
        ''')

    def test_malformed_saved_layout_opens_and_valid_settings_survive(self):
        self.runlua("BagnonSets.Bagnon={cols=0,space='bad',alpha={},bg='old',strata=99,scale=-1,top='bad',left=200,bagsShown=0}")
        self.inventory()
        self.runlua('''
            assert(Bagnon.cols==10 and Bagnon.space==2 and Bagnon.alpha==0.85)
            assert(BagnonSets.Bagnon.bg.a==1 and BagnonSets.Bagnon.top==nil)
            assert(BagnonSets.Bagnon.bagsShown==0)
            BagnonFrame_Open('Bagnon'); assert(Bagnon:IsShown())
            BagnonSets.Bagnon={cols='8',space=4,alpha=.6,bg={r=.2,g=.3,b=.4,a=.8},scale=1.2,top=400,left=100}
            BagnonFrame_Load(Bagnon,{0,1,2},'%s Inventory')
            assert(Bagnon.cols==8 and Bagnon.space==4 and Bagnon.alpha==.6 and Bagnon.scale==1.2)
        ''')

    def test_options_open_drag_scale_and_default_settings_reload(self):
        self.inventory()
        self.load('options/Options.lua','menu/Menu.lua')
        self.runlua('''
            local options=CreateFrame('Frame','BagnonOptions')
            for _,suffix in ipairs({'Tooltips','ForeverTooltips','Quality','FreeSlots','Enchants',
                'ShowBagnon1','ShowBagnon3','ShowBagnon5','ShowBagnon6',
                'ShowBanknon1','ShowBanknon2','ShowBanknon3','ShowBanknon4','ShowBanknon5','ShowBanknon6'}) do
                CreateFrame('CheckButton','BagnonOptions'..suffix,options)
            end
            BagnonOptions_OnShow(options)
            BagnonFrame_StartMoving(Bagnon); assert(Bagnon.moving)
            BagnonFrame_StopMoving(Bagnon); assert(not Bagnon.moving and BagnonSets.Bagnon.left==100)
            BagnonMenu_SetScale(Bagnon,1.2); assert(Bagnon.scale==1.2)
            BagnonSets.Bagnon=nil; BagnonFrame_Load(Bagnon,{0,1,2},'%s Inventory')
            assert(Bagnon.cols==10 and Bagnon.alpha==.85)
        ''')

    def test_signed_item_link_round_trip_and_malformed_saved_item(self):
        self.load('database/database.lua','BagnonForever.lua')
        self.runlua('''
            local link='item:123:456:-789:-1234'
            local short=BagnonForever_HyperlinkToShortLink('|cff00ff00|H'..link..'|h[Item]|h|r')
            assert(short=='123:456:-789:-1234')
            BagnonForeverData.Realm.Player={[0]={[1]=short..',2',[2]='invalid'}}
            local actual,count=BagnonDB.GetItemData('Player',0,1)
            assert(actual==link and count==2)
            assert(BagnonDB.GetItemData('Player',0,2)==nil)
            assert(BagnonForever_HyperlinkToShortLink('invalid')==nil)
        ''')

    def test_live_sort_requests_and_cached_bank_guards(self):
        self.inventory()
        self.runlua('''
            BagnonFrameSort_OnClick(Bagnon,'LeftButton'); assert(sortBags==1)
            BagnonFrameSort_OnClick(Bagnon,'RightButton'); assert(reverse and sortBags==1)
            BagnonDB={}; Bagnon.player='Other'
            BagnonFrameSort_OnClick(Bagnon,'LeftButton'); assert(sortBags==1)
            Banknon=CreateFrame('Button','Banknon'); Banknon.player='Player'
            BagnonFrameSort_OnClick(Banknon,'LeftButton'); assert(sortBank==0)
            bgn_atBank=true; BagnonFrameSort_OnClick(Banknon,'LeftButton'); assert(sortBank==1)
        ''')

    def test_excluded_containers_block_button_slash_and_binding_requests(self):
        import xml.etree.ElementTree as ET
        self.inventory()
        self.load('Slash.lua')
        binding=next(b.text for b in ET.fromstring(source('Bindings.xml')) if b.attrib['name']=='BAGNON_SORT')
        self.runlua('''
            excludeBackpack=true
            BagnonFrameSort_OnClick(Bagnon,'LeftButton')
            SlashCmdList.BagnonCOMMAND('sort')
        ''')
        self.runlua(binding)
        self.runlua('''
            assert(sortBags==0 and excludeBackpack==true)
            excludeBackpack=false; excludeBank=true; bgn_atBank=true
            Banknon=CreateFrame('Button','Banknon')
            BagnonFrameSort_OnClick(Banknon,'LeftButton')
            SlashCmdList.BagnonCOMMAND('sort')
            assert(sortBank==0 and excludeBank==true)
            excludeBank=false; BagnonFrameSort_OnClick(Banknon,'LeftButton')
            assert(sortBank==1)
        ''')

    def test_exclusion_guard_is_specific_to_requested_container_set(self):
        self.inventory()
        self.runlua('''
            excludeBackpack=true; excludeBank=false
            assert(Bagnon_RequestSort(true) and sortBank==1)
            excludeBackpack=false; excludeBank=true
            assert(Bagnon_RequestSort(false) and sortBags==1)
        ''')

    def test_invalid_saved_root_is_replaced_on_addon_load(self):
        self.load('Events.lua')
        self.runlua('''
            BagnonSets='old'; fire(frames[#frames],'ADDON_LOADED','Bagnon')
            assert(type(BagnonSets)=='table' and BagnonSets.enchantBadges==1)
        ''')

    def test_engine_guard_accepts_required_metadata_and_rejects_missing_provider(self):
        self.runlua('CLASSIC_API_VERSION=11515; C_Timer={NewTicker=function() end}')
        self.load('Bootstrap.lua')
        self.runlua('assert(Bagnon_EngineReady); C_Item.GetItemTempEnchantInfo=nil')
        self.load('Bootstrap.lua')
        self.runlua('assert(not Bagnon_EngineReady)')

    def test_native_redraw_and_lock_events_use_current_slot(self):
        self.inventory()
        self.load('Events.lua')
        self.runlua('''
            local events=frames[#frames]
            contents['0:1']={texture='first',count=2,locked=true}
            fire(events,'BAG_UPDATE',0)
            assert(Bagnon.items[1].texture=='first' and Bagnon.items[1].count==2)
            Bagnon.items[1].texture='native redraw'
            contents['0:1']={texture='replacement',count=3}
            fire(events,'BAG_UPDATE',0); fire(events,'ITEM_LOCK_CHANGED'); fire(events,'BAG_UPDATE_COOLDOWN')
            assert(Bagnon.items[1].texture=='replacement' and not Bagnon.items[1].locked)
        ''')

if __name__ == '__main__':
    unittest.main(verbosity=2)
