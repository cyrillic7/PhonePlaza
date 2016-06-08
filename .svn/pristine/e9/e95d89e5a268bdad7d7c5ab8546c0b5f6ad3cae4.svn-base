local Matcthinfo=class("Matcthinfo", function()
	return cc.uiloader:load("errenlandmatch/matchinfo.json")end) 

function Matcthinfo:ctor(Kernel)
    self:setTouchEnabled(false)

    self.m_GameKernel=Kernel
    self.ClientKernel=Kernel:getClientKernel()
    self.m_cbShowNext=false
    self.meRank=0
    self.havecount=0
    --self.meuserid=userid
    local back=cc.uiloader:seekNodeByName(self,"Panel_11")
    back:setPositionY(display.height-290)

    --dump(self.m_GameKernel:GetMeUserID())

        -------------------------
    local GameUserManager = require("common.GameUserManagerController").Message
    local eventListeners = eventListeners or {}
    --eventListeners[GameUserManager.GAME_MatchUserItemAcitve] = handler(self, self.UserEnter)
    --eventListeners[GameUserManager.GAME_MatchUserItemLeave] = handler(self, self.UserLeave)
    eventListeners[GameUserManager.GAME_MatchUserItemStatusUpdate] = handler(self, self.OnEventMatchUserStatus)
    eventListeners[GameUserManager.GAME_MatchUserListUpdate] = handler(self, self.OnEventUpdateMatchUserList)
  
    self.CardeventHandles = self.ClientKernel:addEventListenersByTable( eventListeners )
end

function Matcthinfo:OnEventMatchUserStatus(evt)

  --自己判断

  local MeRank=cc.uiloader:seekNodeByName(self,"MeRank")
  if self.m_GameKernel:GetMeUserID()==evt.para.dwUserID and self.m_cbShowNext==false then
  

    self.meRank=evt.para.dwUserRank
    MeRank:setString(tostring(evt.para.dwUserRank))

  end

end
function Matcthinfo:OnEventUpdateMatchUserList(evt)
  -- body
  local leftuser=cc.uiloader:seekNodeByName(self,"leftuser")
  self.havecount=evt.para
  if self.havecount<self.meRank then
    self.havecount=self.meRank
  end
  leftuser:setString(tostring(self.havecount))
end
function Matcthinfo:setLastRank(rank)
  local MeRank=cc.uiloader:seekNodeByName(self,"MeRank")
  self.meRank=rank
  if self.havecount<self.meRank then
    self.havecount=self.meRank
    local leftuser=cc.uiloader:seekNodeByName(self,"leftuser")
    leftuser:setString(tostring(self.havecount))
  end
  MeRank:setString(tostring(rank))
  self.m_cbShowNext=true
end
function Matcthinfo:SetInfo(enddb)
 
 
    local jishunum=cc.uiloader:seekNodeByName(self,"jishunum")

    jishunum:setString(tostring(enddb.wJishu))

    local diyu=cc.uiloader:seekNodeByName(self,"diyu")
    local diyufen=cc.uiloader:seekNodeByName(self,"diyufen")
    local fenchuju=cc.uiloader:seekNodeByName(self,"fenchuju")

    local di=cc.uiloader:seekNodeByName(self,"second1")
    local lunnum=cc.uiloader:seekNodeByName(self,"lunnum")
    local lundi=cc.uiloader:seekNodeByName(self,"lun")
    local junum=cc.uiloader:seekNodeByName(self,"junum")
    local ju=cc.uiloader:seekNodeByName(self,"ju")

   if enddb.wGameRound == 3  then-- 打立出局 

      diyu:show()
      diyufen:show()
      fenchuju:show()

      di:hide()
      lunnum:hide()
      lundi:hide()
      junum:hide()
      ju:hide()
      diyufen:setString(tostring(enddb.lOutScore))
      local posx=diyufen:getPositionX()+diyufen:getContentSize().width
      fenchuju:setPositionX(posx)
   end

   if enddb.wGameRound == 6  then-- 定局积分 

      diyu:hide()
      diyufen:hide()
      fenchuju:hide()

      di:show()
      lunnum:show()
      lundi:show()
      junum:show()
      ju:show()

      lunnum:setString(tostring(enddb.wGameRoundCount))
      junum:setString(tostring(enddb.wGameCount))
      local posx=lunnum:getPositionX()+lunnum:getContentSize().width
      lundi:setPositionX(posx)
      posx=lundi:getPositionX()+lundi:getContentSize().width
      junum:setPositionX(posx)
      posx=junum:getPositionX()+junum:getContentSize().width
      ju:setPositionX(posx)
   end



end

return Matcthinfo