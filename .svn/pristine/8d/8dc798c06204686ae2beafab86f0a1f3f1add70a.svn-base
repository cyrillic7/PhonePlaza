-- oxBattle
--获取使用kernel类函数
local ClientKernel = require("common.ClientKernel")--外部公共库kernel
local GameKernel   = import("..Kernel.GameKernel")--内部公共库kernel
local oxui     = import("..Kernel.oxui")--辅助ui
local GameUser     = import("..View.Player")--玩家管理
local CardControl  = import("..View.CardControl")--用户牌管理
local PokerCard = import("..Kernel.PokerCard")
local GameLogic = import("..Kernel.GameLogic")--主逻辑

local settingUI = import("..View.SettingView")--主逻辑
local talkUI = import("..View.TalkWidget")--主逻辑


local buttonCfg = {10,50,100,1000,5000,10000,100000,500000}
local iheight = display.height - 280
local JettonPos = {cc.p(235+75,iheight),cc.p(410+75,iheight),cc.p(585+75,iheight),cc.p(760+75,iheight)}
local bankery = display.height - 70
local banderJettonPos = cc.p(330,bankery)
local usersJettonPos = cc.p(50,50)

local jinniu = {11,12,13,26,27,28,42,43,44,58,59,60,65,66} 
local yinniu = {10,11,12,25,26,27,41,42,43,57,58,59,65,66}

local sitCfg = {100000,100000,1000000}
--声明游戏场景类
local oxBattle  = class("oxBattle", function() return display.newScene("oxBattle")end)

local MAX_TIME = 10


local CMD_C_PlaceJetton = {}
--{
--    BYTE                            cbJettonArea;                       //筹码区域
--    LONGLONG                        lJettonScore;                       //加注数目
--};
--//用户坐下
local CMD_C_UserSit = {}
--{
--    DWORD                           wUserID;
--    BYTE                            cbSitID;                        //筹码区域
--};
--//抢庄结构
local CMD_S_QiangZhuan = {}
--{
--    WORD                wSwap1;
--    WORD                wSwap2;
--    LONGLONG            lMeMoney;
--};

--本类的构造函数
function oxBattle:ctor(args)
    display.addSpriteFrames("oxbattle/UIGameBattleIng.plist","oxbattle/UIGameBattleIng.png")

    self.App=AppBaseInstanse.oxBattleApp

    self:setNodeEventEnabled(true)
    self.gameState = OxBattleDefine.GAME_SCENE_FREE
    self.wBankerUser = nil
    self.handCardControl = {}
    self.allJettonList = {}
    self.isMyBanker = false
    self.timerCount = 0
    self.t_Start = nil
    self.t_Open = nil
    self.pokerCount = 0
    self.lCurrentJetton = 0
    self.showClock = false
    --创建gamekernel
    if args.gameClient then
        self.gameClient = args.gameClient
        self.ClientKernel = ClientKernel.new(self.gameClient,self.App.EventCenter)
        --声明conmand对象
        self.m_GameKernel=GameKernel.new(self.ClientKernel)

    end
    --设置游戏属性
    local gameAttribute =
        {
            wKindID=OxBattleDefine.KIND_ID,
            wPlayerCount=OxBattleDefine.GAME_PLAYER,
            dwClientVersion=OxBattleDefine.VERSION_CLIENT,
            pszGameName=OxBattleDefine.GAME_NAME,
        }
    self.m_GameKernel:getClientKernel():SetGameAttribute(gameAttribute)

    print("注册事件管理")
    self:RegistEventManager() --注册事件管理
    print("注册事件管理结束")
    self:InitUnits()          --加载资源
    self:FreeAllData()        --初始化数据
    self:ButtonMsg()          --控件消息
end

--初始化数据
function oxBattle:FreeAllData()
    --首发牌用户
    self.HandCardCount={0,0}
    for i=1, OxBattleDefine.GAME_PLAYER do
        self.handCardControl[i]:FreeControl()
    end

    --
    self.isMovePoker = false
  
    --self.allJettonList = {}
    self.lAllJettonScore = {0,0,0,0,0}
    self.lAllUserWin = {false,false,false,false}
    self.lUserJettonScore = {0,0,0,0,0}
    --self.showClock = false
    --self.lAreaLimitScore = 0
    --self.lCurrentJetton = 0
    self.fristOX = 0

    self.handCardPos=
        {
            cc.p(590,display.height - 60),--庄家对家
            cc.p(240,display.height - 410),
            cc.p(415,display.height - 410),
            cc.p(587,display.height - 410),
            cc.p(760,display.height - 410),
        }

    for i=1, 4 do
        self["lblAddNum" .. i]:setString("")
        self["myAddSouce" .. i]:setString("")
        self["notbet" .. i]:hide()
        self["myWinSouce" .. i]:setString("")
        self["myLoseSouce" .. i]:setString("")
        self["imgAdd" .. i]:hide()
    end
    self:UpdateButtonContron() 
    self:SetButtonNums()
end
--加载资源
function oxBattle:InitUnits()

    --读取json 文件
    local node = oxui.getUIByName("oxbattle/oxbattleLayer.json")
    self.trendChartLayer = oxui.getUIByName("oxbattle/trendChartLayer.json")
    self.upBanderView = oxui.getUIByName("oxbattle/upBanderView.json")

    --先加载
    self.node  = node
    node:addTo(self)
    self.trendChartLayer:addTo(self,2000)
    self.trendChartLayer:hide()
    self.trendChartLayer:setPosition(display.cx,display.cy)
    
    self.upBanderView:addTo(self,2000)
    self.upBanderView:hide()
    self.upBanderView:setPosition( display.cx,display.cy) 
    --node:setContentSize(display.width,display.height)

    --退出按钮
    self.btnLeave=oxui.getNodeByName(node,"btnLeave")
    --设置按钮
    self.btnSetting=oxui.getNodeByName(node,"btnSetting")
    --任务按钮
    self.clock=oxui.getNodeByName(node,"clock")
    --时间
    self.lbltime=oxui.getNodeByName(self.clock,"time")
    --名称
    self.lab=oxui.getNodeByName(self.clock,"lab")

    --上庄列表
    --self.upBanderView=oxui.getNodeByName(node,"upBanderView")
    self.minGoods=oxui.getNodeByName(self.upBanderView,"minGoods")
    self.btnBankerClose=oxui.getNodeByName(self.upBanderView,"btnClose")
    self.banderList=oxui.getNodeByName(self.upBanderView,"banderList")
    self.btnBanker=oxui.getNodeByName(self.upBanderView,"btnBanker")
    self.bankerImg=oxui.getNodeByName(self.btnBanker,"bankerImg")
    --胜负走势
    --self.trendChartLayer=oxui.getNodeByName(node,"trendChartLayer") 
    self.trendChartBtnClose=oxui.getNodeByName(self.trendChartLayer,"btnClose")
    self.trendChartList=oxui.getNodeByName(self.trendChartLayer,"trendChartList") 
    
    --self.trendChartLayer:reorderChild(self,10000) 
    self.playersLayer = oxui.getNodeByName(node,"playersLayer")
    --
    for item=1, 5 do
        if item <= 4 then
            
            self["myLoseSouce" .. item]=oxui.getNodeByName(node,"myLoseSouce" .. item)
            self["notbet" .. item]=oxui.getNodeByName(node,"notbet" .. item)
            self["selectTag" .. item] = oxui.getNodeByName(node,"selectTag" .. item)
            self["myWinSouce" .. item] = oxui.getNodeByName(node,"myWinSouce" .. item)
            self["imgAdd" .. item] = oxui.getNodeByName(self["selectTag" .. item],"imgAdd") 
            self["lblAddNum" .. item]=oxui.getNodeByName(self["selectTag" .. item],"lblAddNum")
            self["myAddSouce" .. item] = oxui.getNodeByName(self["imgAdd" .. item],"souce") 
        end

        self["btnAddSouce" .. item]=oxui.getNodeByName(node,"btnAddSouce" .. item)
        self["lblAddSouceNum" .. item]=oxui.getNodeByName(self["btnAddSouce" .. item],"number")
        self["imgAddSouceSelect" .. item]=oxui.getNodeByName(self["btnAddSouce" .. item],"select")
    end

    for i=1,6 do
        self["player".. i] = oxui.getNodeByName(node,"player" .. i)
        self["hero" .. i] = oxui.getNodeByName(self["player".. i],"hero")
        self["sitDowm" .. i] = oxui.getNodeByName(self["player".. i],"sitDowm")
    end

    -- 上庄列表按钮
    self.btnShowBanker=oxui.getNodeByName(node,"btnShowBanker")
    self.btnTrend=oxui.getNodeByName(node,"btnTrend")
    self.btnPlayer=oxui.getNodeByName(node,"btnPlayer")

    --声明Player对象
    self.m_GameUser=GameUser.new(node,self.m_GameKernel)
    --加载牌的资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Common/AnimationCard.ExportJson")

    -- --牌堆位置
    self.HeapPos=cc.p(display.cx,display.cy + 100)
    --用户手牌的位置

    --初始化牌堆
    self:InitHeapCard()
    --初始化手牌
    self:InitHandCardControl()
    
    require("plazacenter.widgets.GameHornMsgWidget").new(self)


end
--初始化牌堆
function oxBattle:InitHeapCard()
    --发牌张数
    self.DispatchCount={0,0}

    for i=1,OxBattleDefine.GAME_PLAYER do
        table.insert(self.handCardControl,CardControl.new())
    end


    self.handCardPos=
        {
            cc.p(590,display.height - 60),--庄家对家
            cc.p(240,display.height - 410),
            cc.p(415,display.height - 410),
            cc.p(587,display.height - 410),
            cc.p(760,display.height - 410),
        }
    --用户手牌的间距
    self.handCardDistance=
        {
            30,--0号位置 对家
            22,--0号位置 对家
            22,--0号位置 对家
            22,--1号位置 对家
            22,--0号位置 对家

        }
    --用户手牌的大小
    self.handCardScal=
        {
            0.55,--1号位置 对家
            0.5,--2号位置 对家
            0.5,--3号位置 对家
            0.5,--4号位置 对家
            0.5,--5号位置 对家
        }

end
--初始化手牌
function oxBattle:InitHandCardControl()
    for i=1, OxBattleDefine.GAME_PLAYER do
        self.handCardControl[i]:SetStartPos(self.handCardPos[i])
        self.handCardControl[i]:SetDistance(self.handCardDistance[i])
        self.handCardControl[i]:addTo(self.node,499)
        self.handCardControl[i]:SetShow(true)
        self.handCardControl[i]:SetCardTouchEnabled(false)
        --end
    end
end

--开始发牌
function oxBattle:StartDisPachCard()

    local index = 0
    for w = 1, 5 do
        local poker
        for i=1, 5 do
            if self.cbHandCardData[w][i] ~= 0 then
                poker = self:dispatchUserCard(w,self.cbHandCardData[w][i])
            end
            local DelyTime
            if self.isMovePoker then
                DelyTime =0.05*index
            else
                DelyTime = 0
            end

            local posStart = self.HeapPos
            local posEnd = self.handCardPos[w]
            posEnd.x= posEnd.x + self.handCardDistance[w]
            --决定牌大小
            local Scale=self.handCardScal[w]
            local args=
                {
                    startPos=posStart , --起始位置
                    endPos =posEnd,     --结束位置
                    delay=DelyTime,
                    isMoveTo=self.isMovePoker,
                    scal=Scale,
                    moveEndHandler= handler(self,self.DisPatchOneCardEnd),--结束回调处理
                }
            poker:doCardAnimation(args)
            index = index + 1
        end
    end
end

function oxBattle:DisPatchOneCardEnd()
    oxui.playSound("SEND_CARD",false,OxBattleDefine.wav)
    self.pokerCount = self.pokerCount - 1
    print("self.pokerCount = " .. self.pokerCount)
    if self.pokerCount == 0 then
        self:OnSendCardFinish()
    end
end

--控件消息
function oxBattle:ButtonMsg()

    -------------------------------------------------
    --离开按钮事件
    -------------------------------------------------

    self.btnLeave:addTouchEventListener(function (s,e)
        --self:stopTimer()
        if e == ccui.TouchEventType.ended then
            self:Exit()
        end
    end)


    --    --离开按钮按下
    --    self.btnLeave:onButtonPressed(function ()
    --        self:playScaleAnimation(true,self.btnLeave)
    --    end)
    --
    --    --离开按钮抬起
    --    self.btnLeave:onButtonRelease(function ()
    --        self:playScaleAnimation(false,self.btnLeave)
    --    end)

    --------------------------------------------------
    --设置按钮事件
    -------------------------------------------------
    self.btnSetting:addTouchEventListener(function (s,e)
        dump("设置按钮事件")
        if e == ccui.TouchEventType.ended then
            local settingView = settingUI.new()
            settingView:setPosition(cc.p(display.cx,display.cy))
            self:addChild(settingView,2000)
        end
    end)
    --    --设置按钮按下
    --    self.btnSetting:onButtonPressed(function ()
    --        self:playScaleAnimation(true,self.btnSetting)
    --    end)
    --
    --    --设置按钮抬起
    --    self.btnSetting:onButtonRelease(function ()
    --        self:playScaleAnimation(false,self.btnSetting)
    --    end)

    --------------------------------------------------
    --显示庄列表按钮事件
    --------------------------------------------------nt
    self.btnShowBanker:addTouchEventListener(function (s,e)
        print("显示庄列表touch")
        --self.upBanderView:show()
        if e == ccui.TouchEventType.ended then
            oxui.setAnimLayer(self.upBanderView)
        end
    end)

    --    self.btnShowBanker:onButtonPressed(function ()
    --        self:playScaleAnimation(true,self.btnShowBanker)
    --    end)
    --
    --    --设置按钮抬起
    --    self.btnShowBanker:onButtonRelease(function ()
    --        self:playScaleAnimation(false,self.btnShowBanker)
    --    end)

    --------------------------------------------------
    --显示庄列表按钮事件
    --------------------------------------------------nt
    self.btnBankerClose:addTouchEventListener(function (s,e)
        if e == ccui.TouchEventType.ended then
            self.upBanderView:hide()
        end

    end)

    self.btnBanker:addTouchEventListener(function (s,e)
        if e == ccui.TouchEventType.ended then
            if self.isMyBanker == false then
                dump("申请上庄")
                self:send(OxBattleDefine.SUB_C_APPLY_BANKER)
                self.isMyBanker = true
            else
                dump("申请下庄")
                self:send(OxBattleDefine.SUB_C_CANCEL_BANKER)
                self.isMyBanker = false
            end
            self:updateBtnBanker()
        end
    end)
    --
    --    self.btnBankerClose:onButtonPressed(function ()
    --        self:playScaleAnimation(true,self.btnBankerClose)
    --    end)
    --
    --    --设置按钮抬起
    --    self.btnShowBanker:onButtonRelease(function ()
    --        self:playScaleAnimation(false,self.btnBankerClose)
    --    end)

    --------------------------------------------------
    --走势图列表
    --------------------------------------------------
    self.btnTrend:addTouchEventListener(function (s,e)
        print("走势图列表touch")
        --self.trendChartLayer:show()
        if e == ccui.TouchEventType.ended then 
            if self.trendChartLayer:isVisible() then 
                self.trendChartLayer:hide()
            else
                oxui.setAnimLayer(self.trendChartLayer)
                local s = cc.DelayTime:create(0.2)
                
                local f = cc.CallFunc:create(function()
                    self.trendChartList:jumpToRight()
                end)
                 
                self:runAction(cc.Sequence:create(s,f))
            end
        end
    end)

    --    self.btnTrend:onButtonPressed(function ()
    --        self:playScaleAnimation(true,self.btnTrend)
    --    end)
    --
    --    --设置按钮抬起
    --    self.btnTrend:onButtonRelease(function ()
    --        self:playScaleAnimation(false,self.btnTrend)
    --    end)


    self.trendChartBtnClose:addTouchEventListener(function (s,e)
        if e == ccui.TouchEventType.ended then
            self.trendChartLayer:hide()
            print("关闭")
        end
    end)
    --
    --    self.trendChartBtnClose:onButtonPressed(function ()
    --        self:playScaleAnimation(true,self.trendChartBtnClose)
    --    end)
    --
    --    --设置按钮抬起
    --    self.trendChartBtnClose:onButtonRelease(function ()
    --        self:playScaleAnimation(false,self.trendChartBtnClose)
    --    end)
    --------------------------------------------------
    --玩家类表
    --------------------------------------------------
    self.btnPlayer:addTouchEventListener(function (s,e)
        if e == ccui.TouchEventType.ended then
            self.playersLayer:show()
            self.playersLayer:stopAllActions()
            self.playersLayer:setPosition(-270,0)
            local m = cc.MoveTo:create(0.5,cc.p(0,0))
            self.playersLayer:runAction(m)
        end
    end)

    --    self.btnPlayer:onButtonPressed(function ()
    --        self:playScaleAnimation(true,self.btnPlayer)
    --    end)
    --
    --    --设置按钮抬起
    --    self.btnPlayer:onButtonRelease(function ()
    --        self:playScaleAnimation(false,self.btnPlayer)
    --    end)

    for item=1, 5 do
        self["btnAddSouce" .. item]:addTouchEventListener(function (s,e)
            print("select")

            if e == ccui.TouchEventType.ended then
                dump(s:getName())
                self.lCurrentJetton = tonumber(s:getName()) 
                self:UpdateButtonContron()
            end
        end)
    end

    for item=1, 6 do
        self["sitDowm" .. item]:addTouchEventListener(function (s,e)
            if e == ccui.TouchEventType.ended then
            local cfg = sitCfg[self.lJettonState+1]
                if cfg and cfg < self:getMylScore() then
                    CMD_C_UserSit.wUserID =self:GetMeChairID()
                    CMD_C_UserSit.cbSitID =s:getTag()-1
                    dump(CMD_C_UserSit)
                    self:send(OxBattleDefine.SUB_C_USER_SIT,CMD_C_UserSit ,"CMD_C_UserSit")
                else
                    oxui.getTipLayer(self)
                end
              
            end
        end)
    end

    for item=1, 6 do
        self["player" .. item]:setTouchEnabled(true)
        self["player" .. item]:addTouchEventListener(function (s,e)
            if e == ccui.TouchEventType.ended then
                if self.m_GameUser:IstableUser(s:getTag()) then
                    self.m_GameUser:showsitUserInfo(s:getTag())
                end
              
            end
        end)
    end

    for item=1, 4 do
        self["selectTag" .. item]:addTouchEventListener(function (s,e)
            if e == ccui.TouchEventType.ended then
                if self.lCurrentJetton ~= 0 then
                    CMD_C_PlaceJetton.cbJettonArea = s:getTag()
                    CMD_C_PlaceJetton.lJettonScore = self.lCurrentJetton
                    dump(CMD_C_PlaceJetton)
                    self:send(OxBattleDefine.SUB_C_PLACE_JETTON,CMD_C_PlaceJetton ,"CMD_C_PlaceJetton")
                end
            end
        end)
    end


    self.playersLayer:addTouchEventListener(function(s,e)
        if e == ccui.TouchEventType.ended then
            local m = cc.MoveTo:create(0.5,cc.p(-270,0))
            local f = cc.CallFunc:create(function()
                self.playersLayer:hide()
            end)
            self.playersLayer:runAction(cc.Sequence:create(m,f))
        end
    end)
end

---------------[[以下是接收游戏服务端消息处理]]--------------
--场景
function oxBattle:OnGameScenceMsg(evt)
    print("场景====++++++++++++++++++++++++++++++++++")
    dump(evt.para);
    local unResolvedData = evt.para.unResolvedData
    local param = evt.para
    --    print("param.cbGameStatus" ..self.ClientKernel.cbGameStatus)
    --    print("elf:getMyStatus() = " .. self:getMyStatus())

    local gameStatus = self.ClientKernel.cbGameStatus
    dump(gameStatus)


    if gameStatus==OxBattleDefine.GAME_SCENE_FREE then
        local pStatusFree = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusFree")

        self.m_IsTrainRoom=pStatusFree.cbIsTrainRoom
        self.wBankerUser = pStatusFree.wBankerUser

        self:setBankerListById(pStatusFree.wBankerUser)
        dump(pStatusFree)

        self.gameState = OxBattleDefine.GS_TK_FREE
        self:setTimer(pStatusFree.cbTimeLeave)
        --玩家信息
        self.lMeMaxScore=pStatusFree.lUserMaxScore

        --设置我的位置
        --        local pMeUserData=GetMeUserItem().GetUserInfo()
        --        m_GameClientView.SetMeChairID(SwitchViewChairID(GetMeChairID()));

        --庄家信息
        self:SetBankerInfo(pStatusFree.wBankerUser,pStatusFree.lBankerScore)
        self:SetBankerScore(pStatusFree.cbBankerTime,pStatusFree.lBankerWinScore)

        self.bEnableSysBanker=pStatusFree.bEnableSysBanker

        --控制信息
        self.lApplyBankerCondition=pStatusFree.lApplyBankerCondition
        self.lAreaLimitScore=pStatusFree.lAreaLimitScore

        self.lwRevenueRatio=pStatusFree.wRevenueRatio
        self.lServiceScore=pStatusFree.lServiceScore

        self.wBankerUser=pStatusFree.wBankerUser
        --播放声音
        oxui.playSound("BACK_GROUND",false,OxBattleDefine.m4a)

        self.lApplyBankerCondition = pStatusFree.lApplyBankerCondition
        
        self:updateUpBankerBase()
        self.lJettonState = pStatusFree.lJettonState
        self:SetButtonNums()
        
        self:UpdateButtonContron()
        --叫庄状态
    elseif gameStatus==OxBattleDefine.GAME_SCENE_PLACE_JETTON or gameStatus==OxBattleDefine.GAME_SCENE_GAME_END then

        local statusPlay = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusPlay")
        dump(statusPlay)
        local index = 0
        for nAreaIndex=2, 5 do
            index = nAreaIndex-1
            self:PlaceUserJetton(index,statusPlay.lAllJettonScore[nAreaIndex])
            self:SetMePlaceJetton(index,statusPlay.lUserJettonScore[nAreaIndex])
        end
        self.lUserMaxScore = statusPlay.lUserMaxScore
        self.lAreaLimitScore=statusPlay.lAreaLimitScore
        self.lMeMaxScore=statusPlay.lUserMaxScore 
       
        self.wBankerUser=statusPlay.wBankerUser 
        self:setBankerListById(statusPlay.wBankerUser) 
        self.lApplyBankerCondition = statusPlay.lApplyBankerCondition
        self:updateUpBankerBase() 
        
        if gameStatus==OxBattleDefine.GAME_SCENE_PLACE_JETTON then
            self.gameState=OxBattleDefine.GS_TK_SCORE
            self:setTimer(statusPlay.cbTimeLeave) 
        else
            self.gameState=OxBattleDefine.GS_TK_FREE
            self:dealCardRes(statusPlay.cbTableCardArray)
            local d1 = cc.DelayTime:create(2)
            local f1 = cc.CallFunc:create(function()  
                self:moveJettons()
            end)
            local d = cc.DelayTime:create(4)
            local f = cc.CallFunc:create(function() 
                self:setTimer(statusPlay.cbTimeLeave)  
                self:FreeAllData()  
                self.showClock = true
             end)
            
            self:runAction(cc.Sequence:create({d1,f1,d,f}))
        end
        
        self:SetBankerInfo(statusPlay.wBankerUser,statusPlay.lBankerScore)
        --最大上分数
    
        self.bEnableSysBanker = statusPlay.bEnableSysBanker
        self.cbBankerTime = statusPlay.cbBankerTime
        self.lJettonState = statusPlay.lJettonState
        self:SetButtonNums()

        self.lAllJettonScore = statusPlay.lAllJettonScore
        self:UpdateButtonContron()
    end
end

--退出
function oxBattle:Exit() 
    local maxnum = 0
    for var=1, 4 do
    	maxnum = maxnum + self.lUserJettonScore[var]
    end 
    if maxnum > 0 then
        local dataMsgBox =
            {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OKCANCEL,
                msgInfo="您当前正在游戏中，退出将会受到惩罚，是否确定退出？",
                callBack=function(ret)
                    if ret == MSGBOX_RETURN_OK then
                        oxui.removeAll()
                        self.m_GameUser:LeaveType()
                    end
                end
            }
        local msgbox=require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    else
        oxui.removeAll()
        self.m_GameUser:LeaveType()
    end
end

function oxBattle:OnPlayerOpen()
    print("开牌")
    local t = 1
    local index = 0
    local beishu = GameLogic:GetCardType(self.cbHandCardData[1],OxBattleDefine.MAXCOUNT)
    for i=1,5 do
        if self.cbHandCardData[i] then
            self.handCardControl[i]:SetCardData(self.cbHandCardData[i],OxBattleDefine.MAXCOUNT)

            local time = cc.DelayTime:create(t)
            t = t  + 1
            index = index + 1
            local fuc = cc.CallFunc:create(function()
                self.handCardControl[i]:SetShow(true)
                local cardData = self.cbHandCardData[i]
                local num ,outCardData= GameLogic:GetCardType(cardData,OxBattleDefine.MAXCOUNT)
                if #outCardData == OxBattleDefine.MAXCOUNT then
                    self:onOxEnable(false,i,outCardData)
                else
                    self:onOxEnable(false,i,cardData)
                end
                self:SetAnimCard(i,num,outCardData)
                if i >= 2 then 
                    if self.lUserJettonScore[i-1] ~= 0 then
                        if self.lAllUserWin[i-1] == false then 
                            if num >= 1 then
                                self["myWinSouce" .. i-1]:setString(":" .. self.lUserJettonScore[i-1]* num)
                            else
                               self["myWinSouce"..i-1]:setString(":" .. self.lUserJettonScore[i-1])
                            end
                            self["myWinSouce"..i-1]:show()
                            self["myLoseSouce"..i-1]:hide()
                        else
                            if beishu >= 1  then 
                                self["myLoseSouce"..i-1]:setString(":" .. self.lUserJettonScore[i-1]* beishu)
                            else 
                                self["myLoseSouce"..i-1]:setString(":" .. self.lUserJettonScore[i-1] )  
                            end
                            self["myLoseSouce"..i-1]:show()
                        end
                    else
                        self["notbet"..i-1]:show()
                    end
                end
            end
            ) 
            if self.isMovePoker then
                self:runAction(cc.Sequence:create(time,fuc))
            else
                self:runAction(fuc)
            end
        end
    end
end
--游戏结束
function oxBattle:OnSubGameOver(evt)
    local pGameEnd = evt.para
    dump(evt.para)
    print("游戏结束")

    self.gameState = OxBattleDefine.GS_TK_FREE 

    self:UpdateButtonContron()

    if pGameEnd.cbTimeLeave >= 10 then
        self.isMovePoker = true
    else
        self.isMovePoker = false
    end
    self.showClock = false
    self:SetBankerScore(pGameEnd.cbBankerTime,pGameEnd.lBankerWinScore)

    self:dealCardRes(pGameEnd.cbTableCardArray)
    
    self.trendChartList:removeItem(0)
   
    self:updateAnimBtnJetton()
    
    local d1 = cc.DelayTime:create(8)
    local f2 = cc.CallFunc:create(function()
        self:moveJettons()
        
    end) 
    local d = cc.DelayTime:create(10)
    local f = cc.CallFunc:create(function()
        if pGameEnd.lUserScore ~= 0 then
            self.m_GameUser:ShowScore(2,pGameEnd.lUserScore)
        end
        self.m_GameUser:setBankerScore(self.wBankerUser,pGameEnd.lBankerScore) 
        self.m_GameUser:setUserScore(self:GetMeChairID(),pGameEnd.lUserScore) 
          
        self.m_GameUser:ShowScore(1,pGameEnd.lBankerScore) 
        
        self:updateUpBankerBase()
        
        self:FreeAllData() 
        self.showClock = true
    end)
    self:runAction(cc.Spawn:create(cc.Sequence:create(d1,f2),cc.Sequence:create(d,f)))
    self:setTimer(pGameEnd.cbTimeLeave)
end


function oxBattle:OnSubPlaceJettondFall(evt)
    local pPlaceJettonFail = evt.para
    dump(evt.para)
    local cbViewIndex=pPlaceJettonFail.lJettonArea

    self:UpdateButtonContron()
    print("下注失败")
end

function oxBattle:OnSubChancelBanker(evt)
    local pBanker = evt.para
    dump(evt.para)
    print("取消申请上庄")
    self:UpdateButtonContron()
    self.banderList:removeChildByName(pBanker.szCancelUser,true)
end

function oxBattle:OnSubSendAccount(evt)
    local pGameEnd = evt.para
    dump(evt.para)
    print("发送账号")
end

function oxBattle:OnSubAdminCheak(evt)
    local pGameEnd = evt.para
    dump(evt.para)
    print("账号查询")
end

function oxBattle:OnSubQiangZhuang(evt)
    local pGameEnd = evt.para
    dump(evt.para)
    print("强庄")
end

function oxBattle:OnSubUserSit(evt)
    local pSit = evt.para
    dump(evt.para)
    self.m_GameUser:setSitUser(pSit.cbSitID+1,pSit.wUserID)
    print("坐下")
end

function oxBattle:OnSubUserLeave(evt)
    local pLeave = evt.para
    dump(evt.para)
    self.m_GameUser:setSitLeaveUser(pLeave.cbSitID+1,pLeave.wUserID)
    print("离开")
end

function oxBattle:OnSubAmdinCommand(evt)
    local pGameEnd = evt.para
    dump(evt.para)
    print("管理命令")
end

function oxBattle:stopAllTimer()
    self.clock:hide()
    --print("self.gamestage".. self.gameState)
    if self.t_Start then
        oxui.stop(self.t_Start)
        self.t_Start = nil
    end
end


--游戏开始
function oxBattle:OnSubGameStart(evt)
    print("游戏开始")
    local pGameStart = evt.para
    dump(pGameStart)
    --
    --       "bContiueCard"    = 0
    --        "cbTimeLeave"     = 15
    --       "lBankerScore"    = 345074
    --"lUserMaxScore"   = 5018114
    --"nChipRobotCount" = 4
    --"wBankerUser"     = 54
    self:SetBankerInfo(pGameStart.wBankerUser,pGameStart.lBankerScore)

    self.lMeMaxScore=pGameStart.lUserMaxScore


    self.gameState = OxBattleDefine.GS_TK_SCORE
    self:setTimer(pGameStart.cbTimeLeave)
        
        
    local armature = oxui.playAnimation(self.node,200,"AnimationGameIng",OxBattleDefine.animStartAddSource,false)
    armature:setName("AnimationGameIng")    
    armature:setPosition(cc.p(display.cx,200))
    local ani = armature:getAnimation()

    ani:setMovementEventCallFunc(function(arm, eventType, movmentID)
        local v = self.node:getChildByName("AnimationGameIng")
        if v then
            v:removeFromParent() 
        end 
    end)
    oxui.playSound("GAME_START",false,OxBattleDefine.m4a)     
        
    self:UpdateButtonContron() 

end

function oxBattle:OnSubFree(evt)
    print("空闲状态")
    local pGameFree = evt.para
    dump(pGameFree)
    self.gameState = OxBattleDefine.GS_TK_PLAY 

    self:setTimer(pGameFree.cbTimeLeave) 
    
end

--用户下注
function oxBattle:OnSubPlaceJetton(evt)
    print("用户下注")
    local pPlaceJetton = evt.para
    dump(evt.para)

    if self:GetMeChairID()~=pPlaceJetton.wChairID then
        print("机器人")
        --是否机器人
        if pPlaceJetton.bIsAndroid == 0 then
            if self.bHiddenAndroid==false then
                --保存
                local wStFluc = 1 -- 随机辅助
                local androidBet = {}
                androidBet.cbJettonArea = pPlaceJetton.cbJettonArea
                androidBet.lJettonScore = pPlaceJetton.lJettonScore
                androidBet.wChairID = pPlaceJetton.wChairID
                androidBet.nLeftTime = ((math.random(1,10)+androidBet.wChairID+wStFluc*3)%10+1)*100;
                wStFluc = wStFluc%3 + 1
                table.insert(self.ListAndroid,androidBet)
            end
        else
            --加注界面
            print("其他玩家")
            self:PlaceUserJetton(pPlaceJetton.cbJettonArea,pPlaceJetton.lJettonScore)

            if (pPlaceJetton.wChairID~=self:GetMeChairID() or self:IsNotLookonMode()) then
                if pPlaceJetton.lJettonScore==5000000 then
                    oxui.playSound("ADD_GOLD",false,OxBattleDefine.m4a)
                else
                    oxui.playSound("ADD_GOLD",false,OxBattleDefine.m4a)
                end
            end
        end
    else
        print("我下注")
        --设置变量
        --self.lUserJettonScore[pPlaceJetton.cbJettonArea] = self.lUserJettonScore[pPlaceJetton.cbJettonArea] + pPlaceJetton.lJettonScore
        self:PlaceUserJetton(pPlaceJetton.cbJettonArea,pPlaceJetton.lJettonScore)
        self:SetMePlaceJetton(pPlaceJetton.cbJettonArea, pPlaceJetton.lJettonScore)
    end

    self:UpdateButtonContron()
end

--用户叫庄
function oxBattle:OnSubApplyBanker(evt)
    local p = evt.para
    dump(p)
    local wApplyUser =p.wApplyUser
    print("玩家叫庄")

    if wApplyUser == self:GetMeChairID() then

    end
    self:setBankerListById(wApplyUser)
    self.banderList:jumpToBottom() 
end
--发送基数
function oxBattle:OnSubChangeBanker(evt)
    print("切换庄家")
    local pChangeBanker = evt.para
    self.wCurrentBanker = pChangeBanker.wBankerUser
    self.banderList:removeItem(0)
    local item = self.banderList:getItem(0)
    if item then
        local banker = item:getChildByName("imgBander") 
        banker:show()  
    end
    self:SetBankerInfo(pChangeBanker.wBankerUser,pChangeBanker.lBankerScore)
    self:UpdateButtonContron()
    dump(evt.para);
end
--摊牌
function oxBattle:OnSubChangeUserScore(evt)
    print("更新积分")

end

function oxBattle:OnSubSendRecord(evt)
    print("游戏记录")
    local p = evt.para.unResolvedData

    local tagServerGameRecord = self.ClientKernel:ParseStruct(p.dataPtr,p.size,"tagServerGameRecord")
    --dump(tagServerGameRecord)
    for index=1, 15 do
        local item1 = tagServerGameRecord["bWinDaoMen"][index]
        local item2 = tagServerGameRecord["bWinDuiMen"][index]
        local item3 = tagServerGameRecord["bWinHuang"][index]
        local item4 = tagServerGameRecord["bWinShunMen"][index]
        local timeOne = {item1,item2,item3,item4}

        self:trendChartOne(timeOne)
    end
end

function oxBattle:trendChartOne(timeOne)
 
    local trendChartItem = oxui.getUIByName("oxbattle/trendChartItem.json")
  
    local item = trendChartItem
    for i=1, 4 do
        local img = item:getChildByName("img" .. i)
        if timeOne[i] == 0 or timeOne[i] == true then
            img:loadTexture("u_loss.png",1)
        else
            img:loadTexture("u_win.png",1)
        end
    end
    self.trendChartList:pushBackCustomItem(item) 
    
end

function oxBattle:SetAnimCard(wViewChairID,number,outCardData)

    print("wViewChairID= %d, number= %d",wViewChairID,number)

    if number == false then
        number = 0
    end
    local dawang = 0
    local xiaowang = 0
    local num = 0
    for key, i in pairs(jinniu) do
        for key, j in pairs(outCardData) do
            if i == j then
                dawang = dawang + 1
        	end
        end 
    end
    
    for key, i in pairs(yinniu) do
        for key, j in pairs(outCardData) do
            if i == j then
                xiaowang = xiaowang + 1
            end
        end 
    end
    
    if not self.handCardControl[wViewChairID]:getChildByName("AnimationOxType") then
        if number == 10 and dawang >=4 then
        	num = 11
        elseif number == 10 and xiaowang >= 4 then
            num = 12
        else
            num = number
        end
        local armature = oxui.playAnimation(self.handCardControl[wViewChairID],200,"AnimationOxType",num,false)
        armature:setName("AnimationOxType")
        armature:setScale(0.6)
        
        if wViewChairID == 1 then
            armature:setColor(cc.c3b(72,255,253))
            armature:getBone("Layer2"):setColor(cc.c3b(223,214,1))
            self.fristOX = number
        else
            local com = GameLogic:CompareCard(self.cbHandCardData[1],self.cbHandCardData[wViewChairID],5,self.fristOX,number)
            self.lAllUserWin[wViewChairID-1] = com

            if not com then
                armature:setColor(cc.c3b(223,214,1,255))
            end
        end

        local posx = self.handCardPos[wViewChairID].x

        local posy = self.handCardPos[wViewChairID].y - 20
        armature:setPosition(posx,posy)
    end
    if number then
        oxui.playSound("ox" .. number,false,OxBattleDefine.m4a)
    end

end
--场景进入
function oxBattle:onEnter()
    SoundManager:playMusicBackground(oxui.ogg .. "BACK_GROUND.m4a", true)
end
--场景销毁
function oxBattle:onExit()
    print("退出了")
    SoundManager:stopMusicBackground() 
    oxui.removeArmatureFileInfo("AnimationOxType")
    ccs.ArmatureDataManager:destroyInstance()
    display.removeSpriteFramesWithFile("oxbattle/UIGameBattleIng.plist","oxbattle/UIGameBattleIng.png")
    display.removeSpriteFrameByImageName("oxbattle/u_battle_bg.jpg")

end
function oxBattle:onCleanup()
    print("场景销毁")
    self.m_GameUser:OnFreeInterface()
    self.m_GameKernel:OnFreeInterface()
    self.ClientKernel:cleanup()
end
--事件管理
function oxBattle:RegistEventManager()

    --游戏类操作消息
    local eventListeners = eventListeners or {}
    eventListeners[OxBattleDefine.GAME_SCENCE] = handler(self, self.OnGameScenceMsg)-- 场景的消息
    eventListeners[OxBattleDefine.GAME_START] = handler(self, self.OnSubGameStart)  -- 游戏开始
    eventListeners[OxBattleDefine.GAME_FREE] = handler(self, self.OnSubFree)-- 游戏空闲
    eventListeners[OxBattleDefine.GAME_PLACE_JETTON] = handler(self, self.OnSubPlaceJetton)-- 用户下注
    eventListeners[OxBattleDefine.GAME_END] = handler(self, self.OnSubGameOver) -- 游戏结束
    eventListeners[OxBattleDefine.GAME_APPLY_BANKER] = handler(self, self.OnSubApplyBanker)--申请庄家
    eventListeners[OxBattleDefine.GAME_CHANGE_BANKER] = handler(self, self.OnSubChangeBanker)--切换庄家
    eventListeners[OxBattleDefine.GAME_CHANGE_USER_SCORE] = handler(self, self.OnSubChangeUserScore)--更新积分
    eventListeners[OxBattleDefine.GAME_SEND_RECORD] = handler(self, self.OnSubSendRecord)--游戏记录
    eventListeners[OxBattleDefine.GAME_PLACE_JETTON_FAIL] = handler(self, self.OnSubPlaceJettondFall) --下注失败
    eventListeners[OxBattleDefine.GAME_CANCEL_BANKER] = handler(self, self.OnSubChancelBanker) --取消申请
    eventListeners[OxBattleDefine.GAME_SEND_ACCOUNT] = handler(self, self.OnSubSendAccount) --发送账号
    eventListeners[OxBattleDefine.GAME_ADMIN_CHEAK] = handler(self, self.OnSubAdminCheak) --查询账号
    eventListeners[OxBattleDefine.GAME_QIANG_ZHUAN] = handler(self, self.OnSubQiangZhuang) --抢庄
    eventListeners[OxBattleDefine.GAME_USER_SIT] = handler(self, self.OnSubUserSit) --坐下
    eventListeners[OxBattleDefine.GAME_USER_LEAVE] = handler(self, self.OnSubUserLeave) --离开
    eventListeners[OxBattleDefine.GAME_AMDIN_COMMAND] = handler(self, self.OnSubAmdinCommand) --管理员命令
    self.GameeventHandles = self.ClientKernel:addEventListenersByTable( eventListeners )
end

--定义按钮缩放动画函数
function oxBattle:playScaleAnimation(less, pSender)
    local  scale = less and 0.9 or 1
    pSender:runAction(cc.ScaleTo:create(0.2,scale))
end

function oxBattle:updateState()
    self.timerCount = self.timerCount - 1
   
    if  self.timerCount <= 0 then
        self:stopAllTimer()

        if self.gameState == OxBattleDefine.GS_TK_FREE then
            --self:setMyStatusPlay()
        end
        return
    end

    if self.gameState == OxBattleDefine.GS_TK_FREE then
        self.lab:setString("休息一下:" ..  self.timerCount)
        if self.showClock == true then
            self.clock:show()
        end
    elseif self.gameState == OxBattleDefine.GS_TK_SCORE then
        self.lab:setString("请下注:" ..  self.timerCount)
        self.clock:show()
    elseif self.gameState == OxBattleDefine.GS_TK_PLAY then
        self.lab:setString("即将开始:" ..  self.timerCount)
        oxui.playSound("TIME_WARIMG",false,OxBattleDefine.m4a)
        self.clock:show()
    end
end

function oxBattle:fntCardData(para)
    local data = para
    self.cbHandCardData = {}
    local ix = 1
    local  iy = 1
    for key, var in ipairs(data) do
        if not self.cbHandCardData[ix] then
            self.cbHandCardData[ix] = {}
        end

        self.cbHandCardData[ix][iy] = var

        if key % OxBattleDefine.MAXCOUNT == 0 then
            ix = ix + 1
            iy = 1
        else
            iy = iy + 1
        end
    end
    dump(self.cbHandCardData)
end

function oxBattle:dealCardRes(data)
    local index = 1
    self:fntCardData(data)
    self:StartDisPachCard()
end

function oxBattle:dispatchUserCard(wChairID,cbCardData)
    local poker = self.handCardControl[wChairID]:AddOneCard(cbCardData,true)
    --self.handCardControl[wChairID]:SetCardTouchEnabled(false)
    self.pokerCount = self.pokerCount + 1
    return poker
end



--发牌完成
function oxBattle:OnSendCardFinish()
    print("发牌完成，开牌")
    self:OnPlayerOpen()
    --self:moveJettons()
end

function oxBattle:IsNotLookonMode()
    local state
    if self:getMyStatus() == US_PLAYING then
        state = true
    else
        state = false
    end
    return state
end

function oxBattle:getMyStatus()
    return self.m_GameUser.myHero.cbUserStatus
end

function oxBattle:setMyStatusPlay()
    self.m_GameUser.myHero.cbUserStatus = US_PLAYING
end

function oxBattle:getMylScore()
    return self.m_GameUser.myHero.lScore
end

function oxBattle:GetMeChairID()
    return self.m_GameUser.myHero.wChairID
end

function oxBattle:GetBankerlScore()
    return self.m_GameUser:getScoreBywChairID()
end

function oxBattle:IsCurrentUser(wCurrentUser)
    if self:IsNotLookonMode() and  wCurrentUser == self:GetMeChairID() then
        return true
    end
    return false
end

function oxBattle:send(type,data,name)
    self.ClientKernel:requestCommand(MDM_GF_GAME,type,data ,name)
end


function oxBattle:onOxEnable(isShoot,wchairid,outCardData)
    local cbCardData = self.cbHandCardData[wchairid]
    local shoot= isShoot
    local myControl = self.handCardControl[wchairid]

    if outCardData then
        myControl:SetCardData(outCardData)
        myControl:SetShow(true)
    end
end

--更新庄家
function oxBattle:SetBankerInfo(banderId,lBankerScore)
    self.wBankerUser = banderId
    self.lBankerScore = lBankerScore
    self.m_GameUser:SetBankerInfo(banderId)
end

--更新最少上庄钱币
function oxBattle:updateUpBankerBase()
    local num = self.lApplyBankerCondition
    self.minGoods:setString(num/10000 .. "万")
    if self:getMylScore() >= num then
        self.btnBanker:setTouchEnabled(true)
        self.btnBanker:setBright(true)
    else
        self.btnBanker:setTouchEnabled(false)
        self.btnBanker:setBright(false)
    end
end

function oxBattle:SetButtonNums()
    local lJettonState = self.lJettonState or 0
    local index = 1
    for i=lJettonState + 1, 5 + lJettonState do
        local num = buttonCfg[i]
        self["lblAddSouceNum" .. index]:setString(oxui.modfString(num))
        self["btnAddSouce" .. index]:setName(num)
        self["btnAddSouce" .. index]:show()
        index = index + 1
        if self.lCurrentJetton == 0 then
            self.lCurrentJetton = num
        end
    end
end

--获得最小值
function oxBattle:getDowmMinJetton()
	 return buttonCfg[self.lJettonState + 1]
end

--设置其他玩家的筹码
function oxBattle:PlaceUserJetton(cbJettonArea,lScoreCount)
    print("cbJettonArea = ",cbJettonArea .. ",lScoreCount = " .. lScoreCount)
    self.lAllJettonScore[cbJettonArea] = self.lAllJettonScore[cbJettonArea] + lScoreCount
    self:SetUserAddScoreUser(cbJettonArea,lScoreCount)

    for i=1, 4 do
        if self.lAllJettonScore[i] then
            self["lblAddNum" .. i]:setString(oxui.modfString(self.lAllJettonScore[i]))
            self["lblAddNum" .. i]:show()
        end
    end
end

--设置自己的筹码
function oxBattle:SetMePlaceJetton(cbJettonArea,lJettonScore)
    print("设施自己的筹码")
    self.lUserJettonScore[cbJettonArea]=lJettonScore + self.lUserJettonScore[cbJettonArea]
    dump(self.lUserJettonScore)
    for i=1, 4 do
        if self.lUserJettonScore[i] > 0 then
            self["myAddSouce" .. i]:setString(self.lUserJettonScore[i])
            self["imgAdd" .. i]:show()
        end
    end
    --m_GameClientView.SetMePlaceJetton(cbJettonArea,lJettonScore)
end
--移动筹码
function oxBattle:SetUserAddScoreUser(cbJettonArea,lScoreCount,x,y)
    --创建筹码图片

    print("cbJettonArea .. == " .. cbJettonArea)
    if cbJettonArea == 1 then
    --return
    end
    while lScoreCount >= buttonCfg[1] do
        for var=8, 1, -1 do
            if lScoreCount >= buttonCfg[var] then
                --[[local img = ccui.ImageView:create()
                local name = "u_cm_" .. buttonCfg[var] .. ".png"
                img:loadTexture(name,1)
                self:addChild(img)
                img:setPosition(cc.p(x or 60,y or 90))
                img:setTag(cbJettonArea)
                img:setName(name)]]
                local img = display.newSprite("#u_cm_" .. buttonCfg[var] .. ".png")
                img:setPosition(cc.p(x or 60,y or 90))
                img:setTag(cbJettonArea)
                img:setName("#u_cm_" .. buttonCfg[var] .. ".png")
                self.node:addChild(img,5)
                local pos = clone(JettonPos[cbJettonArea])
                pos.x = pos.x + math.random(-40,40)
                pos.y = pos.y + math.random(-20,30)
                self:JettonMoveeff(img,pos)
                table.insert(self.allJettonList,img)
                lScoreCount = lScoreCount - buttonCfg[var]
                break
            end
        end
    end
end

function oxBattle:JettonMoveeff(jetton,pos,delay,callBack)
    local tt={}
    local d = cc.DelayTime:create(delay or 0)
    if callBack then
        table.insert(tt,callBack)
    end
    local move = cc.MoveTo:create(0.3,pos)
    local rota = cc.RotateBy:create(0.4,math.random(360,360*8))
    local es = cc.EaseQuarticActionOut:create(cc.Spawn:create(move,rota))
    table.insert(tt,d)
    table.insert(tt,es)
    jetton:runAction(cc.Sequence:create(tt))
end

function oxBattle:UpdateButtonContron()

    local bEnablePlaceJetton=true
    print("更新百人牛牛按钮")

    dump(self.gameState)
    if (self.gameState ~= OxBattleDefine.GS_TK_SCORE )  then
        bEnablePlaceJetton=false
    end
    dump(bEnablePlaceJetton )
    if (self.wCurrentBanker==self:GetMeChairID()) then
        bEnablePlaceJetton=false
    end
    dump(bEnablePlaceJetton )
    --    if (self:IsNotLookonMode()) then
    --        bEnablePlaceJetton=false
    --    end
    --    dump(bEnablePlaceJetton )
    if (self.bEnableSysBanker==false and self.wCurrentBanker==INVALID_CHAIR) then
        bEnablePlaceJetton=false
    end
    --    dump(bEnablePlaceJetton )
    if (self:getMyStatus() ~= US_PLAYING)  then
        bEnablePlaceJetton=false
    end
    --    dump(bEnablePlaceJetton )
    --    if(self.ClientKernel.cbGameStatus == OxBattleDefine.GAME_SCENE_GAME_END) then
    --        m_GameClientView.m_btOpenCard.EnableWindow(false)
    --        m_GameClientView.m_btAutoOpenCard.EnableWindow(false)
    --    else
    --        m_GameClientView.m_btOpenCard.EnableWindow(true)
    --        m_GameClientView.m_btAutoOpenCard.EnableWindow(true)
    --    end


    --下注按钮
    if bEnablePlaceJetton then
        --计算积分
        local lCurrentJetton = self:GetCurrentJetton()
        local lLeaveScore = self.lMeMaxScore

        dump(self.lUserJettonScore)
        for nAreaIndex=1 ,4 do
            lLeaveScore = lLeaveScore - self.lUserJettonScore[nAreaIndex]
        end
        --最大下注
        local lUserMaxJetton=self:GetUserMaxJetton()
        dump(lUserMaxJetton)
        --设置光标
        dump(lLeaveScore)
        lLeaveScore = math.min((lLeaveScore/10),lUserMaxJetton) --用户可下分 和最大分比较 由于是五倍
        dump(lLeaveScore)
        dump(lCurrentJetton)
        print("lLeaveScore=" .. lLeaveScore)
        local min = self:getDowmMinJetton()   
        
        if (lCurrentJetton > lLeaveScore) then
           if (lLeaveScore>=500000) and lLeaveScore >= min  then
                self:SetCurrentJetton(500000)
            elseif (lLeaveScore>=100000) and lLeaveScore >= min then
                self:SetCurrentJetton(100000)
            elseif (lLeaveScore>=50000) and lLeaveScore >= min then
                self:SetCurrentJetton(50000)
            elseif (lLeaveScore>=10000) and lLeaveScore >= min then
                self:SetCurrentJetton(10000)
            elseif (lLeaveScore>=5000) and lLeaveScore >= min then
                self:SetCurrentJetton(5000)
            elseif (lLeaveScore>=1000)  and lLeaveScore >= min then
                self:SetCurrentJetton(1000)
            elseif (lLeaveScore>=100) and lLeaveScore >= min then
                self:SetCurrentJetton(100)
            elseif (lLeaveScore>=50) and lLeaveScore >= min then
                self:SetCurrentJetton(50)
            elseif (lLeaveScore>=10) and lLeaveScore >= min then
                self:SetCurrentJetton(10)
            else
                self:SetCurrentJetton(0)
            end
        end
        local iTimer = 1
        for num=1, 5 do
            local isTouch = false
            local btn = self["btnAddSouce" .. num]
            local jettonNum = tonumber(btn:getName())
            if lLeaveScore>=jettonNum*iTimer and lUserMaxJetton>=jettonNum*iTimer then
                isTouch = true
            end
            btn:setTouchEnabled(isTouch)
            btn:setBright(isTouch)
        end
        self:updateAnimBtnJetton()
    else

        --设置光标
         self:SetCurrentJetton(0)

        --禁止按钮

        for btn=1, 5 do
            self["btnAddSouce" .. btn]:setTouchEnabled(false)
            self["btnAddSouce" .. btn]:setBright(false)
        end
    end
    
end


function oxBattle:setBankerListById(wApplyUser)

    local battleBankerItem = oxui.getUIByName("oxbattle/battleBankerItem.json")

    local item = battleBankerItem:clone()
    local name = item:getChildByName("name")
    local gold = item:getChildByName("gold")
    local imgBander = item:getChildByName("imgBander")
    local hero = self:getAllHeros()[wApplyUser]

    if hero then
        name:setString(hero.szNickName)
        gold:setString(hero.lScore)
        imgBander:hide()
        item:setName(hero.szNickName)
        if self.wBankerUser == hero.wChairID then
            imgBander:show()
        end
        if hero.wChairID == self:GetMeChairID() then
            name:setColor(cc.c3b(255,0,0))
            gold:setColor(cc.c3b(255,0,0))
        else
            name:setColor(cc.c3b(161,159,159))
            gold:setColor(cc.c3b(161,159,159))
        end
    end

    self.banderList:pushBackCustomItem(item)
    --永远在上面
    --self.banderList:jumpToTop()
end

function oxBattle:getAllHeros()
    return self.m_GameUser.sixHeros
end

function oxBattle:setTimer(time)
    self:stopAllTimer()
    self.timerCount = time
    self.t_Start = oxui.schedule(function()
        self:updateState()
    end ,1,time)
end

function oxBattle:updateBtnBanker()
    if self.isMyBanker then
        self.bankerImg:loadTexture("u_text_xz.png",1)
    else
        self.bankerImg:loadTexture("u_text_sz.png",1)
    end
end

function oxBattle:moveJettons()
    --测试数据 
    --dump(self.lAllUserWin)  
    self:trendChartOne(self.lAllUserWin)
    
    for key, jetton in pairs(self.allJettonList) do 
        if self.lAllUserWin[jetton:getTag()] == true then
            local f = cc.CallFunc:create(function()
                jetton:removeFromParent()
                self.allJettonList[key] = nil
            end)
            self:JettonMoveeff(jetton,banderJettonPos,0.5,f)
        end
    end 
    
    for key, jetton in pairs(self.allJettonList) do 
        if self.lAllUserWin[jetton:getTag()] == false then
            --[[local img = ccui.ImageView:create()
            img:loadTexture(jetton:getName(),1)
            self:addChild(img)]]
            local img = display.newSprite(jetton:getName())
            self.node:addChild(img,5)
            img:setPosition(banderJettonPos)
            local imgd = cc.DelayTime:create(2)
            local pos = clone(JettonPos[jetton:getTag()])
            print("pos" .. pos.x .. "  ".. pos.y .. "    " .. jetton:getTag())
            pos.x = pos.x + math.random(-40,40)
            pos.y = pos.y + math.random(-20,30)
            local imgm = cc.MoveTo:create(0.2,pos)
            local d = cc.DelayTime:create(0.7)
            local d2 = cc.DelayTime:create(1)
            local m = cc.MoveTo:create(0.5,usersJettonPos)
            local m2= cc.MoveTo:create(0.5,usersJettonPos)
            local f = cc.CallFunc:create(function()
                jetton:removeFromParent()
                img:removeFromParent()
                self.allJettonList[key] = nil
            end)
            local imgmm = cc.DelayTime:create(2)
            jetton:runAction(cc.Sequence:create({imgmm,d2,m2,f}))
            img:runAction(cc.Sequence:create({imgd,imgm,d,m}))
        end
    end
end

--最大下注
function oxBattle:GetUserMaxJetton()
    local iTimer = 10
    --已下注额
    local lNowJetton = 0

    for nAreaIndex=1 ,4 do
        lNowJetton = lNowJetton +  self.lUserJettonScore[nAreaIndex]*iTimer
    end
    --庄家金币
    local lBankerScore = self.lBankerScore
    dump(self.lBankerScore)
    dump(lBankerScore)

    for nAreaIndex=1,4 do
        lBankerScore =lBankerScore - self.lAllJettonScore[nAreaIndex]*iTimer
        print("lBankerScore =" .. lBankerScore)
    end

    dump(self.lAllJettonScore)
    dump(self.lAreaLimitScore)
    --区域限制
    local lMeMaxScore
    dump(lNowJetton)
    if((self.lMeMaxScore-lNowJetton)/iTimer > self.lAreaLimitScore) then
        print(1)
        lMeMaxScore= self.lAreaLimitScore*iTimer
    else
        print(2)
        lMeMaxScore =self.lMeMaxScore-lNowJetton
        --lMeMaxScore = lMeMaxScore
    end 
    --庄家限制
    lMeMaxScore=math.min(lMeMaxScore,lBankerScore)
    lMeMaxScore =lMeMaxScore/iTimer
    --非零限制
    lMeMaxScore = math.max(lMeMaxScore, 0)

    return lMeMaxScore
end

function oxBattle:SetCurrentJetton(lCurrentJetton)
    self.lCurrentJetton=lCurrentJetton
end

function oxBattle:GetCurrentJetton(lCurrentJetton)
    return self.lCurrentJetton
end

function oxBattle:updateAnimBtnJetton()
    dump("updateAnimBtnJetton111")
    dump(self.lCurrentJetton)
    for num=5, 1 ,-1 do
        local btn = self["btnAddSouce" .. num]
        local select = btn:getChildByName("select")
        local anim = select:getChildByName("AnimationBtn")
       
        if tonumber(btn:getName()) == self.lCurrentJetton and self.gameState == OxBattleDefine.GS_TK_SCORE then
            if not anim then
                local anim = oxui.playAnimation(select,10,"AnimationBtn",0,true)
                anim:setName("AnimationBtn")
                anim:setPosition(cc.p(48.5,31))
            end
            select:show()
        else
            if anim then
                anim:removeFromParent()
            end
            select:hide()
        end
    end
end

function oxBattle:SetBankerScore(cbBankerTime,lBankerWinScore)
    self.cbBankerTime = cbBankerTime
    self.lBankerWinScore = lBankerWinScore
end


return oxBattle