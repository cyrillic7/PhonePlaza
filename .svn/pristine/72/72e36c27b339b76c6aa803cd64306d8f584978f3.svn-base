
local Player=class("Player")

local usersitPos = {
    cc.p(display.cx + 170 ,display.cy + 200),--1号位置 对家
    cc.p(display.cx + 210,display.cy + 50),--2号位置 对家
    cc.p(display.cx + 190,display.cy - 90),--3号位置 对家
    cc.p(150,230),--4号位置 自己
    cc.p(display.cx - 440,display.cy+50),--5号位置 对家
    cc.p(display.cx - 400,display.cy + 190),--6号位置 对家
}

--构造
function Player:ctor(Json,Kernel)
    self.Node=Json
    self.m_GameKernel=Kernel
    self.ClientKernel=Kernel:getClientKernel()
    self.myHero = {}
    self.sixHeros = {}
    self:RegistUserManager()
    self.soucesPos = {}
    self.gameUserItems = {}
    self.playerStatus = {}
    self.sitHeros={}
    for i=1,6 do

        self["player".. i] = oxui.getNodeByName(self.Node,"player" .. i)
        self["hero" .. i] = oxui.getNodeByName(self["player".. i],"hero")
        self["sitDowm" .. i] = oxui.getNodeByName(self["player".. i],"sitDowm")

        self["head".. i] = oxui.getNodeByName(self["hero" .. i],"head")
        self["gold".. i] = oxui.getNodeByName(self["hero" .. i],"gold")
        self["name".. i] = oxui.getNodeByName(self["hero" .. i],"name")
        self["bk".. i] = oxui.getNodeByName(self["hero" .. i],"bk")
    end

    self.MyPlayer = oxui.getNodeByName(self.Node,"MyPlayer")
    self.MyHead = oxui.getNodeByName(self.MyPlayer,"head")
    self.MyGold = oxui.getNodeByName(self.MyPlayer,"gold")
    self.MyName = oxui.getNodeByName(self.MyPlayer,"name")

    self.bander = oxui.getNodeByName(self.Node,"bander")
    self.banderHead = oxui.getNodeByName(self.bander,"head")
    self.banderGold = oxui.getNodeByName(self.bander,"gold")
    self.banderName = oxui.getNodeByName(self.bander,"name")

    for item=1, 4 do
        self["notbet" .. item ] = oxui.getNodeByName(self.Node,"notbet" .. item)
        self["myAddSouce" .. item ] = oxui.getNodeByName(self.Node,"myAddSouce" .. item)
        self["lblAddNum" .. item ] = oxui.getNodeByName(self.Node,"lblAddNum" .. item)
    end

    --玩家 列表
    self.playersLayer=oxui.getNodeByName(self.Node,"playersLayer")
    self.playerList=oxui.getNodeByName(self.playersLayer,"playerList")
    self.playerList:addEventListener(function (s,e) 
        if e == ccui.ListViewEventType.ONSELECTEDITEM_END  then 
            self:pklistViewEvent(s) 
        end
    end )
    
end

function Player:pklistViewEvent(s) 
    for key, item in pairs(self.playerList:getItems()) do
        if key == s:getCurSelectedIndex()+1 then
            local listItem = s:getItem(key-1)
            local position = listItem:getParent():convertToWorldSpace(cc.p(listItem:getPosition()))
            self:showUserInfo(item:getTag(), 270,position.y+90)
        end
    end 
end

function Player:showUserInfo(tag,posX,posY) 
   -- dump(self.sixHeros)
    dump(tag)
    if not self.userInfoWidget then
        local userInfoWidget = require("plazacenter.widgets.UserInfoWidget")
        self.userInfoWidget = userInfoWidget.new(self.playersLayer, userInfoWidget.TABLE_TYPE)
    end 
    self.userInfoWidget:updateUserInfo(self.sixHeros[tag],posX,posY)
    self.userInfoWidget:showUserInfo(true)  
end

function Player:showsitUserInfo(tag) 
    --dump(tag,"1111111111111111111111111111111111111111111111111111111")
    if self.sitHeros[tag] then
    if not self.userInfoWidget then
        local userInfoWidget = require("plazacenter.widgets.UserInfoWidget")
        self.userInfoWidget = userInfoWidget.new(self.Node, userInfoWidget.TABLE_TYPE)
    end 
    local pos = usersitPos[tag]
    self.userInfoWidget:setLocalZOrder(2001)
    self.userInfoWidget:updateUserInfo(self.sitHeros[tag],pos.x,pos.y)
    self.userInfoWidget:showUserInfo(true)  
    end

end

function Player:IstableUser(tag)
    if self.sitHeros[tag] then
        return true
    else
        return false
    end
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
    eventListeners["GF_USER_CHAT"] = handler(self, self.ChatCallBack)
    eventListeners["GF_USER_EXPRESSION"] = handler(self, self.ChatCallBack)

    self.eventHandles = self.ClientKernel:addEventListenersByTable( eventListeners )
end

--------------------[[用户管理接口]]--------------------
--用户进来
function Player:UserEnter(evt)
    --local ViewID =self.m_GameKernel:SwitchViewChairID(evt.para.wChairID)

    print("用户进来 我的椅子号------》" ,evt.para.wChairID)
    --print("用户进来 我的视图号------》", ViewID)
    --dump(evt.para)
    self.sixHeros[evt.para.wChairID] = evt.para
    --自己
    if evt.para.wChairID == self.ClientKernel.userAttribute.wChairID then
        --头像框-自己
        self.myHero = evt.para
        print("evt.para.cbUserStatus =" .. evt.para.cbUserStatus)
        print("self.myHero=" .. self.myHero.wChairID)
        self.MyPlayer:show()
        --头像-自己
        self.MyHead:loadTexture("pic/face/"..evt.para.wFaceID..".png",1)
        self.MyHead:show()
        self.MyHead:setScale(0.45)

        --昵称-自己
        self.MyName:setString(G_TruncationString(evt.para.szNickName,15))
        self.MyName:show()
        --分数-自己
        self.MyGold:setString(evt.para.lScore)
        self.MyGold:show()

        --对家
    else
    --        print("ViewID" .. ViewID)
    --        --头像框-对家
    --        self["player" .. ViewID]:show()
    --        --头像-对家
    --        self["head" .. ViewID]:setSpriteFrame("pic/face/"..evt.para.wFaceID..".png")
    --        self["head" .. ViewID]:show()
    --        self["head" .. ViewID]:setScale(0.45)
    --
    --        --昵称-对家
    --        self["name" .. ViewID]:setString(evt.para.szNickName)
    --        --分数-对家
    --        self["gold" .. ViewID]:setString( oxui.string(evt.para.lScore))
    --
    --        if evt.para.cbUserStatus == US_READY then
    --            self["read" .. ViewID]:show()
    --        else
    --            self["read" .. ViewID]:hide()
    --        end
    end

    self:setPlayerListItem(evt.para)
end

function Player:setPlayerListItem(parm)
    local hero = parm
    if not self.playerItem then
        self.playerItem = oxui.getUIByName("oxbattle/playerItem.json")
        self.playerItem:retain()
    end
    local item = self.playerItem:clone()
    local name = item:getChildByName("name")
    local gold = item:getChildByName("gold")
    local head = item:getChildByName("head")
    --dump(parm)
    local strimg = "pic/face/".. hero.wFaceID ..".png" 
    if hero then
        head:loadTexture(strimg,1)
        head:show()
        head:setScale(0.45)

        --昵称
        name:setString(hero.szNickName)
        name:show()
        --分数
        gold:setString(hero.lScore)
        gold:show()
        item:setTag(hero.wChairID) 
    end
    
    self.playerList:pushBackCustomItem(item)
   --end 
   
end



--用户离开
function Player:UserLeave(evt)
    --local ViewID = self.m_GameKernel:SwitchViewChairID(evt.para.wChairID)
    --print("用户离开..ViewID= " ..ViewID)
    print("用户离开..wChairID= " .. evt.para.wChairID)

    self.playerList:removeChildByTag(evt.para.wChairID,true)

    --自己
    if evt.para.wChairID==self.myHero.wChairID then
        self:LeaveType()
    end
    self.sixHeros[evt.para.wChairID] = nil
end

function Player:LeaveType()
    if self.ClientKernel.exitGameApp then
        self.ClientKernel:exitGameApp()
    else
        self.m_GameKernel:LeaveGame()
        cc.Director:getInstance():popToRootScene()
    end
end
--更新用户分数
function Player:UserScoreUpdate(evt)
    local userItem = evt.para.clientUserItem

    --local ViewID=self.m_GameKernel:SwitchViewChairID(userItem.wChairID)
    print("更新用户分数ViewID" .. "print(更新用户分数" .. userItem.lScore .. "fen")
    --    if ViewID == OxBattleDefine.MYSELF_VIEW_ID then
    --        self["gold" .. ViewID]:setString(userItem.lScore)
    --    else
    --        self["gold" .. ViewID]:setString( oxui.string(userItem.lScore))
    --    end
end
--更新用户状态
function Player:UserStatusUpdate(evt)
    print("更新用户状态")
    --    dump(evt)
    local userItem = evt.para.clientUserItem
    --local ViewID=self.m_GameKernel:SwitchViewChairID(userItem.wChairID)

    --    print("更新用户状态.. ViewID"  .. ViewID)
    --    print("更新用户状态.. userItem" ..userItem.cbUserStatus )
    --
    self.sixHeros[userItem.wChairID] = userItem
    --    if userItem.cbUserStatus==US_READY then
    --        self["read" .. ViewID]:show()
    --    else
    --        self["read" .. ViewID]:hide()
    --    end
    --
    --
    --    if ViewID == OxBattleDefine.MYSELF_VIEW_ID then
    --        self.myHero.cbUserStatus = userItem.cbUserStatus
    --        print("更新用户状态..playeruserItem" .. userItem.cbUserStatus )
    --        if US_SIT == userItem.cbUserStatus then
    --            self.btnStart:show()
    --        end
    --    end
end
--更新用户属性
function Player:UserAttribUpdate(evt)
    print("更新用户属性")
    --    local ViewID =self.m_GameKernel:SwitchViewChairID(evt.para.wChairID)
    --    self.gameUserItems[tostring(ViewID)] = evt.para
    dump(self.gameUserItems)
end

--设置玩家状态
function Player:setUserPlayingStatus(wChairID , statu)
    local ViewID=self.m_GameKernel:SwitchViewChairID(wChairID)
    self.gameUserItems[tostring(ViewID)].cbUserStatus = statu
    self:refreshGameView()
end

--更新试图
function Player:refreshGameView()
    print("更新试图")

end

--更新庄家
function Player:SetBankerInfo(wChairID)
    local banker = self.sixHeros[wChairID]
    if banker then
        self.banderHead:loadTexture("pic/face/"..banker.wFaceID..".png",1)
        self.banderHead:show()
        self.banderHead:setScale(0.45)

        --昵称-自己
        
        self.banderName:setString(G_TruncationString(banker.szNickName,12))
        self.banderName:show()
        --分数-自己
        self.banderGold:setString(banker.lScore)
        self.banderGold:show()
        self.bander:show()
    else
        print("庄家不存在！")
    end
end

function Player:resetGameView()
    print("重新设置")
    for i=1, OxBattleDefine.GAME_PLAYER do
        --self["player" .. i] = oxui.getNodeByName(self.Node,"player" .. i)
        self:resetGamePlayerView(i)
    end
end

function Player:resetGamePlayerView(vid)
--self["imgAddSouce" .. vid]:hide()
end

function Player:FreeAllPlayer()
    for i=1, OxBattleDefine.GAME_PLAYER do
        self:resetGamePlayerView(i)
    end
end

function Player:setSZName(wChairID,name)
    --    local vid =self.m_GameKernel:SwitchViewChairID(wChairID)
    --    if vid then
    if self["name" .. wChairID] then
        self["name" .. wChairID]:setString(name)
    end

    --    end
    print("设置名字",wChairID)


end

function Player:setCellScore(wChairID,score)
    if not wChairID then
        return
    end

    if wChairID == OxBattleDefine.MYSELF_VIEW_ID then
        self["gold" .. wChairID]:setString(score)
    else
        self["gold" .. wChairID]:setString( oxui.string(score))
    end
end

function Player:SetaddScouce(vid,num)
    if vid and num then
        self["imgAddSouce".. vid]:show()
        self["lblAddSouce".. vid]:setString(num)
    end


end

function Player:ShowScore(wChairID,score,iszheng)
    if not wChairID then
        return
    end

    self:moveSource(wChairID,score,iszheng)
end


function Player:getMywChairID()
    return self.myHero.wChairID
end

function Player:GetTableUserItem(vid)
    if self["player" .. vid] and self["player" .. vid]:isVisible() then
        return true
    else
        return false
    end
end

function Player:getUserStatus()
    return self.myHero.cbUserStatus
end

function Player:IsCurrentUser(wCurrentUser)
    if not oxui.IsNotLookonMode()and  wCurrentUser == self.myHero.wChairID  then
        return true
    end
    return false
end

local cardUpDis = 40
function Player:moveSource(vid,score)
    local iszheng = false
    if score > 0 then
    	iszheng = true
    end
    self:setSouceTexture(vid,iszheng)
    if self["TXT".. vid] and self["TXT".. vid] then
        self["TXT" .. vid]:setString(":" .. score)
        self["TXT".. vid]:show()
        local mb = cc.MoveBy:create(1.5, cc.p(0, cardUpDis))
        local fade = cc.FadeTo:create(1,0)
        local del = cc.DelayTime:create(2.5)
        local call = cc.CallFunc:create(function()
            self["TXT".. vid]:removeFromParent()
        end )
        self["TXT".. vid]:runAction(cc.Sequence:create(mb,fade,del,call))
    end
    
end

function Player:setSouceTexture(vid,iszheng)
    local str
    if iszheng then
        str = "u_game_numb_win"
    else
        str = "u_game_numb_lose"
    end
    self["TXT" .. vid] = ccui.TextAtlas:create()
    self["TXT" .. vid]:setProperty("0", "oxbattle/Font/" .. str ..  ".png", 23, 31, "0")
    
   
    local tag ,X,Y
    if vid == 1 then
        tag = self.bander
        X = tag:getPositionX()
        Y = tag:getPositionY() 
    else
        tag = self.MyPlayer
        X = tag:getPositionX()- 200
        Y = tag:getPositionY() 
        
    end 
    self["TXT" .. vid]:addTo(tag,300)
    self["TXT" .. vid]:setPositionX(214)
    
     --)cc.p( , 0))
end

function Player:getSixHero()
--return clone(SixHeros)
end

function Player:setSitUser(tag,userId)
    local user
    for key, iuser in pairs(self.sixHeros) do
        if iuser.dwUserID == userId then
            user = iuser
        end
    end
    self.sitHeros[tag] = user
    dump(tag)
    if user then
        self["hero".. tag]:show()
        self["sitDowm".. tag]:hide()
        self["head".. tag]:loadTexture("pic/face/"..user.wFaceID..".png",1)
        self["head".. tag]:show()
        self["head".. tag]:setScale(0.45)
        --分数
        local str = G_TruncationString(user.szNickName,9) 
        self["gold".. tag]:setString(str)
        self["gold".. tag]:show()
    end
end

function Player:setSitLeaveUser(tag,wChairID)
    self.sitHeros[tag] = nil
    self["hero".. tag]:hide()
    self["sitDowm".. tag]:show()
end

function Player:setBankerScore(wChairID,score)
    local banker = self.sixHeros[wChairID]
    self.banderGold:setString(banker.lScore + score)
    self.banderGold:show()
end

function Player:setUserScore(wChairID,score)
    local user = self.sixHeros[wChairID]
    self.MyGold:setString(user.lScore  + score)
    self.MyGold:show()
end

function Player:getScoreBywChairID(wChairID)
    return self.sixHeros[wChairID].lScore   
end

return Player

