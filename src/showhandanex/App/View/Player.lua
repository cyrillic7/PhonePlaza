
--local UsersitItem=import("..View.UserSitItem")

local Player=class("Player")
	
local userPos = { 
    cc.p(130,220),--4号位置 对家
    cc.p(display.cx -270 ,display.cy + 200),--1号位置 对家 
}

--构造
function Player:ctor(Json,Kernel)
	self.Node=Json
    self.m_GameKernel=Kernel
    self.ClientKernel=Kernel:getClientKernel()

    self:RegistUserManager()
    self.sixHeros = {}

    --self.gameUserItems = {}
    self.MyPlayer=cc.uiloader:seekNodeByName(self.Node, "MyPlayer")
	--头像框-自己
    self.FaceFrame_me=cc.uiloader:seekNodeByName(self.MyPlayer,"head_bk")
    --头像-自己
    self.Face_me=cc.uiloader:seekNodeByName(self.MyPlayer,"head_me")
    --身份-自己
    --self.Lander_me=cc.uiloader:seekNodeByName(self.Node,"Image_Lander_Me")
    --昵称-自己
    self.Name_me=cc.uiloader:seekNodeByName(self.MyPlayer,"name")
    --分数-自己
    self.SCORE_me=cc.uiloader:seekNodeByName(self.MyPlayer,"gold")
    --准备-自己
    self.Ready_me=cc.uiloader:seekNodeByName(self.MyPlayer,"Image_Ready_me")
    --时钟-自己
    self.Clock_me=cc.uiloader:seekNodeByName(self.MyPlayer,"Image_Clock_me")
    --时钟数字-自己
    self.Clock_Num_me=cc.uiloader:seekNodeByName(self.Clock_me,"Time_num_me")
    --操作显示位置-自己
    self.Oprview_Me=cc.uiloader:seekNodeByName(self.Node,"Image_Me_oper")

    self.MyTotalScore=cc.uiloader:seekNodeByName(self.MyPlayer,"my_total_add")

    self.MyTotalScore_num=cc.uiloader:seekNodeByName(self.MyTotalScore, "my_total_score")

    self.MyTotalScore:hide()



    --头像框-对家
    self.OppoPlayer=cc.uiloader:seekNodeByName(self.Node, "OppoPlayer")
    self.OppoPlayer:hide()

    self.FaceFrame_Oth=cc.uiloader:seekNodeByName(self.OppoPlayer,"head_oppo_bk")
    --头像-对家
    self.Face_Oth=cc.uiloader:seekNodeByName(self.OppoPlayer,"head_oppo")
    --身份-对家
    --self.Lander_Oth=cc.uiloader:seekNodeByName(self.Node,"Image_Lander_Other")
    --昵称-对家
    self.Name_Oth=cc.uiloader:seekNodeByName(self.OppoPlayer,"name")
    --分数-对家
    self.SCORE_Oth=cc.uiloader:seekNodeByName(self.OppoPlayer,"gold")
    --准备-对家
    self.Ready_Oth=cc.uiloader:seekNodeByName(self.OppoPlayer,"Image_Ready_oppo")
    --时钟-对家
    self.Clock_Oth=cc.uiloader:seekNodeByName(self.OppoPlayer,"Image_Clock_Other")
    --时钟数字-对家
    self.Clock_Num_Oth=cc.uiloader:seekNodeByName(self.Clock_Oth,"Time_num_Other")

    self.Tuoguan_Oth=cc.uiloader:seekNodeByName(self.Node,"Image_otuoguan")

    --操作显示位置-对家
    self.Oprview_Oth=cc.uiloader:seekNodeByName(self.Node,"Image_Oth_oper")

    self.OppoTotalScore=cc.uiloader:seekNodeByName(self.OppoPlayer,"oppo_total_add")


    self.OppoTotalScore_num=cc.uiloader:seekNodeByName(self.OppoTotalScore, "oppo_total_score")

    self.OppoTotalScore:hide()


    self.TableTotalScore=cc.uiloader:seekNodeByName(self.Node, "table_total_score")

    self.TableTotalScore_text=cc.uiloader:seekNodeByName(self.TableTotalScore, "table_total_text")

    self.TableTotalScore:hide()

    self.CurClockViewID=-1
    self.UserClock=-1
    self.CurOperID=-1
    self.m_tuoguan=false
    self.times=2
    self.m_MyScore=0
    self.m_OppoScore=0
    self.m_lGold={0,0}
    self.m_lTalbeGold={0,0}
    self.m_lBasicGold=0

    local warnningpaot=
    {
      cc.p(self.Face_Oth:getPositionX()+300, self.Face_Oth:getPositionY()-60),
      cc.p(self.Face_me:getPositionX()+140, self.Face_me:getPositionY()+50)
    }

    --[[self.UserSitItem={}
    for i=1,ShowHandDefine.GAME_PLAYER do
        self.UserSitItem[i]=UsersitItem.new()
        self.UserSitItem[i]:addTo(self.Node)
        self.UserSitItem[i]:setWarnningPort(warnningpaot[i])
    end]]

    self.FaceFrame_me:setTouchEnabled(true)
    self.FaceFrame_me:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (e)
            if e.name == "began" then 
                local bHideUserInfo = (0 ~= bit._and(self.ClientKernel.serverAttribute.dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE))
                if not bHideUserInfo then
                    self:showUserInfo(e.pSender:getTag())
                end
                
            end
        end)
    self.FaceFrame_Oth:setTouchEnabled(true)
    self.FaceFrame_Oth:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (e)
            if e.name == "began" then 
                local bHideUserInfo = (0 ~= bit._and(self.ClientKernel.serverAttribute.dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE))
                if not bHideUserInfo then
                    self:showUserInfo(e.pSender:getTag())
                end
                
            end
        end)

    self.Event = { CLOCK_END = "CLOCK_END",USER_LEAVE = "USER_LEAVE",}--触摸牌消息


end
--重置数据
function Player:FreePlayer()
    self.CurClockViewID=-1
    self.UserClock=-1 
    self.CurOperID=-1
    self.m_lGold={0,0}
    self.m_lTalbeGold={0,0}
    self.m_lBasicGold=0
    self.m_MyScore=0
    self.m_OppoScore=0
    self.sixHeros = {}

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

function Player:showUserInfo(tag)
    
    if not self.userInfoWidget then
        local userInfoWidget = require("plazacenter.widgets.UserInfoWidget")
        self.userInfoWidget = userInfoWidget.new(self.Node, userInfoWidget.TABLE_TYPE) 
    end
    local pos = userPos[tag]
    for key, user in pairs(self.sixHeros) do
        local ViewID = self.m_GameKernel:SwitchViewChairID(user.wChairID) + 1
        if ViewID  ~= tag then
            self.userInfoWidget:updateUserInfo(self.sixHeros[user.wChairID],pos.x,pos.y)
            self.userInfoWidget:showUserInfo(true)
            self.userInfoWidget:zorder(200)
        end
    end
    

end

--设置基数
function Player:SetBasicGold(basicgold)
    self.m_lBasicGold=basicgold
end

--设置桌面筹码
function Player:SetTableGold(viewid,gold)
    if gold > 0 then
        self.TableTotalScore:show()
    else
        self.TableTotalScore:hide()
    end
    if self.m_lTalbeGold[viewid] ~= gold then
        self.m_lTalbeGold[viewid]=gold
    end
end

--获取桌面筹码
function Player:GetTableGold(viewid)
    print("tablegold viewid===="..viewid)
    return self.m_lTalbeGold[viewid]
end

--设置下注
function Player:SetGold(viewid,gold)
    if self.m_lGold[viewid] ~=  gold then
        self.m_lGold[viewid]=gold
    end

    if viewid == ShowHandDefine.MYSELF_VIEW_ID then
        self.MyTotalScore_num:setString(tostring(gold))
    else
        self.OppoTotalScore_num:setString(tostring(gold))
    end

    --print("viewid === "..viewid)
    --print("self.m_lGold[viewid] == "..self.m_lGold[viewid])
end

--获取下注
function Player:GetGold(viewid)
    print("viewid ========= "..viewid)
    return self.m_lGold[viewid]
end

function Player:SetTableTotalScore()
    local totalscore = 0
    for i=1,ShowHandDefine.GAME_PLAYER do
        totalscore = totalscore + self.m_lTalbeGold[i]
    end

    self.TableTotalScore_text:setString("总注:"..totalscore)
end

function Player:SetAddViewShow(viewid,bshow)
    if bshow == true then
        if viewid == ShowHandDefine.MYSELF_VIEW_ID then
            self.MyTotalScore:show()
        else
            self.OppoTotalScore:show()
        end
    else
        if viewid == ShowHandDefine.MYSELF_VIEW_ID then
            self.MyTotalScore:hide()
        else
            self.OppoTotalScore:hide()
        end
    end
end

--梭哈
function Player:GetShowHandScore(viewid,shsocre)
    local showhandsocre = 0
    print("self.m_MyScore ==== "..self.m_MyScore)
    print("shsocre ==== "..shsocre)
    showhandsocre = math.min(self.m_MyScore,shsocre)
    local lscore = 0
    lsocre = showhandsocre - self:GetTableGold(viewid)

    --self:SetGold(viewid, lsocre)

    --lscore = self:GetFollowScore(viewid,shsocre)
    return lsocre
end

--跟注
function Player:GetFollowScore(viewid,shsocre)
    local lgold = self:GetGold(viewid)
    print("lgold====="..lgold)
    local lShowHandScore=0
    lShowHandScore=math.min(self.m_MyScore,shsocre)

    if lgold+self:GetTableGold(viewid) < lShowHandScore then
        lgold=math.max(lgold,self.m_lBasicGold)
    end

    if lShowHandScore == lgold+self:GetTableGold(viewid) then
        print("GetFollowScore --- 梭哈")
        --lgold=lgold+self:GetTableGold(viewid)
    end

    --self:SetGold(viewid, lgold)

    return lgold
end

--设置托管
function Player:SetUserTuoguan(viewID,cbtuoguan)
    --自己
    if viewID==ShowHandDefine.MYSELF_VIEW_ID then
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
    --self.Lander_me:hide()
    --self.Lander_Oth:hide()
    --self.Face_me:show()
    --self.Face_Oth:show()

end
--------------------[[用户管理接口]]--------------------
--用户进来
function Player:UserEnter(evt)
   
    local ViewID=self.m_GameKernel:SwitchViewChairID(evt.para.wChairID)
    --print("用户进来 我的椅子号------》" ,evt.para.wChairID)
   -- print("用户进来 我的视图号------》", ViewID)
--    self.gameUserItems[tostring(ViewID)] = evt.para
    self.sixHeros[evt.para.wChairID] = evt.para

    --自己
    if ViewID==ShowHandDefine.MYSELF_VIEW_ID then
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
        self.m_MyScore=evt.para.lScore
        self.SCORE_me:setString(tostring(evt.para.lScore))
        self.SCORE_me:show()

        if evt.para.cbUserStatus==US_READY then
            self.Ready_me:show()
        else
            self.Ready_me:hide()
        end
    --对家
    else
        self.OppoPlayer:show()
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
        self.m_OppoScore=evt.para.lScore
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
    self.sixHeros[evt.para.wChairID] = nil
    --自己
    if ViewID==ShowHandDefine.MYSELF_VIEW_ID then
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
        --self.Lander_me:hide()
    

    --对家
    else
        self.OppoPlayer:hide()
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
        --self.Lander_Oth:hide()
        self.Clock_Num_Oth:setString("")

        --通知到场景
        AppBaseInstanse.ShowHandApp.EventCenter:dispatchEvent({
        name = self.Event.USER_LEAVE,
        OperID=ViewID
        })

    end
    --dump(evt.para);
end
--更新用户分数
function Player:UserScoreUpdate(evt)
    print("更新用户分数")
    local userItem = evt.para.clientUserItem
    local ViewID=self.m_GameKernel:SwitchViewChairID(userItem.wChairID)
    --处理自己
    if ViewID==ShowHandDefine.MYSELF_VIEW_ID then
        self.m_MyScore=userItem.lScore
       self.SCORE_me:setString(tostring(userItem.lScore))
    --对家
    else
        self.m_OppoScore=userItem.lScore
       self.SCORE_Oth:setString(tostring(userItem.lScore))
    end
    --dump(evt.para);
end
--更新用户状态
function Player:UserStatusUpdate(evt)
    print("更新用户状态")
    --dump(evt.para);
    local userItem = evt.para.clientUserItem
    local ViewID=self.m_GameKernel:SwitchViewChairID(userItem.wChairID)
    self.sixHeros[userItem.wChairID].cbUserStatus = userItem.cbUserStatus
    --处理自己
    if ViewID==ShowHandDefine.MYSELF_VIEW_ID then
        if userItem.cbUserStatus==US_READY then
            self.Ready_me:show()
        else
            self.Ready_me:hide()
        end
    --对家
    else
        print("更新用户状态ssssssssssssssssss"..userItem.cbUserStatus)
        if userItem.cbUserStatus==US_READY then
            self.Ready_Oth:show()
        else
            self.Ready_Oth:hide()
        end
    end
    
end
--更新用户属性
function Player:UserAttribUpdate(evt)
    print("更新用户属性")
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
    if ViewID==ShowHandDefine.MYSELF_VIEW_ID then
        self.Clock_me:show()
        self.Clock_Num_me:setString(tostring(clock))
        if operID==ShowHandDefine.IDI_GIVE_UP then
        --todo
          --self.Clock_me:setPosition(display.cx-100,display.cy-30)
        end

        if operID==ShowHandDefine.IDI_START_GAME then
           --self.Clock_me:setPosition(display.cx,display.cy-40)
        end

        if operID==ShowHandDefine.IDI_GIVE_UPIDI_GIVE_UP then
           --self.Clock_me:setPosition(display.cx-430,display.cy-40-155)
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
            if self.CurClockViewID==ShowHandDefine.MYSELF_VIEW_ID then
                self.Clock_Num_me:setString(tostring(self.UserClock))
            --对家
            else   
                self.Clock_Num_Oth:setString(tostring(self.UserClock))
            end
        end

        local isautoend=false
        if self.CurClockViewID==ShowHandDefine.MYSELF_VIEW_ID and self.m_tuoguan==true and self.UserClock>0 then
            self.times=self.times-1
            if self.times==0 then
                isautoend=true
            end
        end

        if self.UserClock ==0 or isautoend==true then
           if self.CurClockViewID==ShowHandDefine.MYSELF_VIEW_ID then
            self:ClockEnd(self.CurOperID)
           end 
           self:KillUserClock()
        end
        --print("更新时间"..self.UserClock)
    end

end

function Player:ClockEnd(operID)

    print("执行操作"..operID)
    --通知到场景
    AppBaseInstanse.ShowHandApp.EventCenter:dispatchEvent({
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
        image="showhandanex/buchu.png"
    end
    if type==2 then --叫地主
        image="showhandanex/Call.png"
    end
    if type==3 then --不叫
        image="showhandanex/NoCall.png"
    end
    if type==4 then --抢地主
        image="showhandanex/Qiang.png"
    end
    if type==5 then --不抢
        image="showhandanex/NoQiang.png"
    end

    self.Oprview_Me:hide()
    self.Oprview_Oth:hide()
    if viewid==ShowHandDefine.MYSELF_VIEW_ID then
       self.Oprview_Me:setTexture(image)
       self.Oprview_Me:show()
    else
       self.Oprview_Oth:setTexture(image)
       self.Oprview_Oth:show()    
    end

end


return Player

