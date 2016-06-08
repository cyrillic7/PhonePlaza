
local UsersitItem=import("..View.UserSitItem")

local Player=class("Player")
	


--构造
function Player:ctor(Json,Kernel)
	self.Node=Json
    self.m_GameKernel=Kernel
    self.ClientKernel=Kernel:getClientKernel()

    self:RegistUserManager()

    --self.gameUserItems = {}

	--头像框-自己
    self.FaceFrame_me=cc.uiloader:seekNodeByName(self.Node,"Player_bk_me")
    --头像-自己
    self.Face_me=cc.uiloader:seekNodeByName(self.Node,"Image_Face_Me")
    --身份-自己
    self.Lander_me=cc.uiloader:seekNodeByName(self.Node,"Image_Lander_Me")
    --昵称-自己
    self.Name_me=cc.uiloader:seekNodeByName(self.Node,"Label_Name_ME")
    --分数-自己
    self.SCORE_me=cc.uiloader:seekNodeByName(self.Node,"ME_SCORE")
    --准备-自己
    self.Ready_me=cc.uiloader:seekNodeByName(self.Node,"Image_Ready_me")
    --时钟-自己
    self.Clock_me=cc.uiloader:seekNodeByName(self.Node,"Image_Clock_me")
    --时钟数字-自己
    self.Clock_Num_me=cc.uiloader:seekNodeByName(self.Node,"Time_num_me")
    --操作显示位置-自己
    self.Oprview_Me=cc.uiloader:seekNodeByName(self.Node,"Image_Me_oper")



    --不出
    self.OprPasss=cc.uiloader:seekNodeByName(self.Node,"Image_buchu")
    --叫地主
    self.OprCall=cc.uiloader:seekNodeByName(self.Node,"Image_jiao")
    --不叫
    self.OprNoCall=cc.uiloader:seekNodeByName(self.Node,"Image_bujiao")
    --抢地主
    self.OprQiang=cc.uiloader:seekNodeByName(self.Node,"Image_qiang")
    --不抢
    self.OprNoQiang=cc.uiloader:seekNodeByName(self.Node,"Image_buqiang")



    --头像框-对家
    self.FaceFrame_Oth=cc.uiloader:seekNodeByName(self.Node,"Player_bk_other")
    --头像-对家
    self.Face_Oth=cc.uiloader:seekNodeByName(self.Node,"Image_Face_Other")
    --身份-对家
    self.Lander_Oth=cc.uiloader:seekNodeByName(self.Node,"Image_Lander_Other")
    --昵称-对家
    self.Name_Oth=cc.uiloader:seekNodeByName(self.Node,"Label_Name_Other")
    --分数-对家
    self.SCORE_Oth=cc.uiloader:seekNodeByName(self.Node,"Label_Other_Score")
    --准备-对家
    self.Ready_Oth=cc.uiloader:seekNodeByName(self.Node,"Image_Ready_Other")
    --时钟-对家
    self.Clock_Oth=cc.uiloader:seekNodeByName(self.Node,"Image_Clock_Other")
    --时钟数字-对家
    self.Clock_Num_Oth=cc.uiloader:seekNodeByName(self.Node,"Time_num_Other")

    self.Tuoguan_Oth=cc.uiloader:seekNodeByName(self.Node,"Image_otuoguan")

    --操作显示位置-对家
    self.Oprview_Oth=cc.uiloader:seekNodeByName(self.Node,"Image_Oth_oper")

    self.Oprview_Me:setPositionY(300)

    --self.dizhu=cc.uiloader:seekNodeByName(self.Node,"Image_dizhu")
    --self.nongmin=cc.uiloader:seekNodeByName(self.Node,"Image_nongmin")


    self.CurClockViewID=-1
    self.UserClock=-1
    self.CurOperID=-1
    self.m_tuoguan=false
    self.times=2

    local warnningpaot=
    {
      cc.p(self.Face_Oth:getPositionX()+300, self.Face_Oth:getPositionY()-60),
      cc.p(self.Face_me:getPositionX()+140, self.Face_me:getPositionY()+50)
    }

    self.UserSitItem={}
    for i=1,ErRenLandDefine.GAME_PLAYER do
        self.UserSitItem[i]=UsersitItem.new()
        self.UserSitItem[i]:addTo(self.Node)
        self.UserSitItem[i]:setWarnningPort(warnningpaot[i])
    end

    self.Event = { CLOCK_END = "CLOCK_END",USER_LEAVE = "USER_LEAVE",}--触摸牌消息


end
--重置数据
function Player:FreePlayer()
    self.CurClockViewID=-1
    self.UserClock=-1 
    self.CurOperID=-1


end
--释放注册的消息
function Player:OnFreeInterface()
    self.ClientKernel:removeListenersByTable(self.eventHandles)
end

--事件管理
function Player:RegistUserManager()  
    --用户类事件 
    local GameUserManager = require("common.GameUserManagerController").Message
    local eventListeners = eventListeners or {}
    eventListeners[GameUserManager.GAME_UserItemAcitve] = handler(self, self.UserEnter)
    eventListeners[GameUserManager.GAME_UserItemDelete] = handler(self, self.UserLeave)
    eventListeners[GameUserManager.GAME_UserItemScoreUpdate] = handler(self, self.UserScoreUpdate)
    eventListeners[GameUserManager.GAME_UserItemStatusUpdate] = handler(self, self.UserStatusUpdate)
    eventListeners[GameUserManager.GAME_UserItemAttribUpdate] = handler(self, self.UserAttribUpdate)
 
    self.eventHandles=self.ClientKernel:addEventListenersByTable(eventListeners)
end
--用户角色
function Player:SetBankerUser(viewID)
    local imagedizhu="errenlandmatch/dizhu.png"
    local imagenongmin="errenlandmatch/nongmin.png"

   -- self.Face_me:hide()
    --self.Face_Oth:hide()
    self.Lander_me:show()
    self.Lander_Oth:show()
    --自己
    if viewID==ErRenLandDefine.MYSELF_VIEW_ID then
       -- self.dizhu:setPosition(self.Face_me:getPositionX(),self.Face_me:getPositionY())
        --self.nongmin:setPosition(self.Face_Oth:getPositionX(),self.Face_Oth:getPositionY())






        self.Lander_me:setTexture(imagedizhu) 
        self.Lander_me:setScale(1)
        self.Lander_Oth:setTexture(imagenongmin)
        self.Lander_Oth:setScale(1)
        
    --对家
    else

        self.Lander_me:setTexture(imagenongmin) 
        self.Lander_me:setScale(1)
        self.Lander_Oth:setTexture(imagedizhu)
        self.Lander_Oth:setScale(1)
        --self.dizhu:setPosition(self.Face_Oth:getPositionX(),self.Face_Oth:getPositionY())
       -- self.nongmin:setPosition(self.Face_me:getPositionX(),self.Face_me:getPositionY())
        --self.dizhu:show()
        --self.nongmin:show()   
    end
end
--用户报警
function Player:SetWarning(viewID)
    --自己
    if viewID==ErRenLandDefine.MYSELF_VIEW_ID then
        self.UserSitItem[viewID+1]:showAlarm(true)
    --对家
    else
        self.UserSitItem[viewID+1]:showAlarm(true)
    end
end
--重置报警
function Player:ClearWarning()
    for i=1,ErRenLandDefine.GAME_PLAYER do
        self.UserSitItem[i]:Reset()  
    end
end

--设置托管
function Player:SetUserTuoguan(viewID,cbtuoguan)
    --自己
    if viewID==ErRenLandDefine.MYSELF_VIEW_ID then
        self.m_tuoguan=cbtuoguan
        self.times=2
    --对家
    else
        if cbtuoguan==true then
            self.Tuoguan_Oth:show()
        else
            self.Tuoguan_Oth:hide()
        end
        
    end

end
function Player:ClearBankerUser()
end
--清空用户角色self.Image_TuoguanMe
function Player:ClearBankerUser()

    --self.dizhu:hide()
    --self.nongmin:hide() 
    self.Lander_me:hide()
    self.Lander_Oth:hide()
    --self.Face_me:show()
    --self.Face_Oth:show()

end
--------------------[[用户管理接口]]--------------------
--用户进来
function Player:UserEnter(evt)
   
    local ViewID=self.m_GameKernel:SwitchViewChairID(evt.para.wChairID)
   -- print("用户进来 我的椅子号------》" ,evt.para.wChairID)
   -- print("用户进来 我的视图号------》", ViewID)
--    self.gameUserItems[tostring(ViewID)] = evt.para

    --自己
    if ViewID==ErRenLandDefine.MYSELF_VIEW_ID then
        --头像框-自己
        self.FaceFrame_me:show()
        --头像-自己
        self.Face_me:setSpriteFrame("pic/face/"..evt.para.wFaceID..".png")
        self.Face_me:setScale(0.48)
        self.Face_me:show()

        --昵称-自己


        self.Name_me:setString(G_TruncationString(evt.para.szNickName,21))
        self.Name_me:show()

        --分数-自己
       -- evt.para.lScore=-1323
        local scorestr
        if evt.para.lScore>=0 then
            scorestr=tostring(evt.para.lScore)
        end
        if evt.para.lScore<0 then
            scorestr=":"..tostring(-evt.para.lScore)
        end
        --print("eeeeeeeeeeeeeeeeeeeeee")
       -- print(scorestr)
        self.SCORE_me:setString(scorestr)
        self.SCORE_me:show()

        if evt.para.cbUserStatus==US_READY then
            self.Ready_me:show()
        else
            self.Ready_me:hide()
        end
    --对家
    else

        --头像框-对家
        self.FaceFrame_Oth:show()
        --头像-对家
        self.Face_Oth:setSpriteFrame("pic/face/"..evt.para.wFaceID..".png")
        self.Face_Oth:setScale(0.48)
        self.Face_Oth:show()

        --昵称-对家
        self.Name_Oth:setString(G_TruncationString(evt.para.szNickName,21))
        --self.Name_Oth:show()

        --分数-对家
        self.SCORE_Oth:setString(tostring(evt.para.lScore))
        --self.SCORE_Oth:show()

        if evt.para.cbUserStatus==US_READY then
            self.Ready_Oth:show()
        else
            self.Ready_Oth:hide()
        end
        --todo
    end

   -- dump(evt.para);
end
--用户离开
function Player:UserLeave(evt)
    local ViewID=self.m_GameKernel:SwitchViewChairID(evt.para.wChairID)
    --print("用户离开"..ViewID)
--    self.gameUserItems[tostring(ViewID)] = nil

    --自己
    if ViewID==ErRenLandDefine.MYSELF_VIEW_ID then
        --头像框-自己
        self.FaceFrame_me:hide()
        --头像-自己
        self.Face_me:hide() 
        --昵称-自己
        self.Name_me:setString("")
        --self.Name_me:hide()
        --分数-自己
        self.SCORE_me:setString("")
        --self.SCORE_me:hide()
        --准备-自己
        self.Ready_me:hide()
        --时钟-自己
        self.Clock_me:hide()
        self.Lander_me:hide()
    

    --对家
    else
        --头像框-对家
        self.FaceFrame_Oth:hide()
        --头像-对家
        self.Face_Oth:hide() 
        --昵称-对家
        self.Name_Oth:setString("")
        --self.Name_Oth:hide()
        --分数-对家
        self.SCORE_Oth:setString("")
        --self.SCORE_Oth:hide()
        --准备-对家
        self.Ready_Oth:hide()
        --时钟-对家
        self.Clock_Oth:hide()
        --self.Lander_me:hide()
        self.Lander_Oth:hide()
        self.Clock_Num_Oth:setString("")

        --通知到场景
        AppBaseInstanse.ErRenLandApp.EventCenter:dispatchEvent({
        name = self.Event.USER_LEAVE,
        OperID=ViewID
        })

    end
    --dump(evt.para);
end
--更新用户分数
function Player:UserScoreUpdate(evt)

    local userItem = evt.para.clientUserItem
    local ViewID=self.m_GameKernel:SwitchViewChairID(userItem.wChairID)


    --处理自己
    if ViewID==ErRenLandDefine.MYSELF_VIEW_ID then
        --分数-自己
        --userItem.lScore=-1323
        local scorestr
        if userItem.lScore>=0 then
            scorestr=tostring(userItem.lScore)
        end
        if userItem.lScore<0 then
            scorestr=":"..tostring(-userItem.lScore)
        end
        self.SCORE_me:setString(scorestr)
       --self.SCORE_me:setString(tostring(userItem.lScore))
    --对家
    else
        local scorestr
       -- if userItem.lScore>=0 then
            scorestr=tostring(userItem.lScore)
       -- end
        --if userItem.lScore<0 then
        --    scorestr=":"..tostring(-userItem.lScore)
        --end
       self.SCORE_Oth:setString(scorestr)
    end
    --dump(evt.para);
end
--更新用户状态
function Player:UserStatusUpdate(evt)

    --dump(evt.para);
    local userItem = evt.para.clientUserItem
    local ViewID=self.m_GameKernel:SwitchViewChairID(userItem.wChairID)
    --处理自己
    if ViewID==ErRenLandDefine.MYSELF_VIEW_ID then
        if userItem.cbUserStatus==US_READY then
            self.Ready_me:show()
        else
            self.Ready_me:hide()
        end
    --对家
    else

        if userItem.cbUserStatus==US_READY then
            self.Ready_Oth:show()
        else
            self.Ready_Oth:hide()
        end
    end
    
end
--更新用户属性
function Player:UserAttribUpdate(evt)

   -- dump(evt.para);
end
--设置时钟
function Player:KillUserClock()
    self.times=2
    self.CurClockViewID=-1
    self.UserClock=-1
    self.CurOperID=-1
    self.Clock_me:hide()
    self.Clock_Oth:hide() 
end
--设置时钟
function Player:SetUserClock(ViewID,clock,operID)

    self:KillUserClock()

    self.CurClockViewID=ViewID
    self.UserClock=clock
    self.CurOperID=operID

    --处理自己
    if ViewID==ErRenLandDefine.MYSELF_VIEW_ID then
        self.Clock_me:show()
        self.Clock_Num_me:setString(tostring(clock))
        if operID==ErRenLandDefine.IDI_OUT_CARD then
        --todo
           self.Clock_me:setPosition(display.cx-100,310)
        end

        if operID==ErRenLandDefine.IDI_CALL_SCORE then
           self.Clock_me:setPosition(display.cx,310)
        end

        if operID==ErRenLandDefine.IDI_START_GAME then
           self.Clock_me:setPosition(display.cx-430,455)
        end
           


    --对家
    else
        self.Clock_Oth:show()     
        self.Clock_Num_Oth:setString(tostring(clock))
    end
end

--设置时钟
function Player:OnUserClock()

    if self.CurClockViewID~=-1 then
        if self.UserClock >=1 then
            self.UserClock=self.UserClock-1
            --处理自己
            if self.CurClockViewID==ErRenLandDefine.MYSELF_VIEW_ID then
                self.Clock_Num_me:setString(tostring(self.UserClock))
            --对家
            else   
                self.Clock_Num_Oth:setString(tostring(self.UserClock))
            end
        end

        local isautoend=false
        if self.CurClockViewID==ErRenLandDefine.MYSELF_VIEW_ID and self.m_tuoguan==true and self.UserClock>0 then
            self.times=self.times-1
            if self.times==0 then
                isautoend=true
            end
        end

        if self.UserClock ==0 or isautoend==true then
           if self.CurClockViewID==ErRenLandDefine.MYSELF_VIEW_ID then
            self:ClockEnd(self.CurOperID)
           end 
           self:KillUserClock()
        end
        --print("更新时间"..self.UserClock)
    end

end

function Player:ClockEnd(operID)

--    print("执行操作"..operID)
    --通知到场景
    AppBaseInstanse.ErRenLandApp.EventCenter:dispatchEvent({
    name = self.Event.CLOCK_END,
    OperID=self.CurOperID
    })
end

function Player:ClearUserOper()
    self.Oprview_Me:hide()
    self.Oprview_Oth:hide()
end

function Player:ClearUserOper()
    self.Oprview_Me:hide()
    self.Oprview_Oth:hide()
end
function Player:SetUserOper(viewid,type)

    local image
    if type==1 then --不出
        image="errenlandmatch/buchu.png"
    end
    if type==2 then --叫地主
        image="errenlandmatch/Call.png"
    end
    if type==3 then --不叫
        image="errenlandmatch/NoCall.png"
    end
    if type==4 then --抢地主
        image="errenlandmatch/Qiang.png"
    end
    if type==5 then --不抢
        image="errenlandmatch/NoQiang.png"
    end

    self.Oprview_Me:hide()
    self.Oprview_Oth:hide()
    if viewid==ErRenLandDefine.MYSELF_VIEW_ID then
       self.Oprview_Me:setTexture(image)
       self.Oprview_Me:show()
    else
       self.Oprview_Oth:setTexture(image)
       self.Oprview_Oth:show()    
    end

end


return Player

