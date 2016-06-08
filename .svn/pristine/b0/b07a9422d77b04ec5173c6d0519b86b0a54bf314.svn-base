-- OxTwo
--获取使用kernel类函数
local ClientKernel = require("common.ClientKernel")--外部公共库kernel
local GameKernel   = import("..Kernel.GameKernel")--内部公共库kernel
local oxui     = import("..Kernel.oxui")--辅助ui
local GameUser     = import("..View.Player")--玩家管理
local CardControl  = import("..View.CardControl")--用户牌管理
--local HeapCard     = import("..View.HeapCard")--牌堆管理
local PokerCard = import("..Kernel.PokerCard")
local GameLogic = import("..Kernel.GameLogic")--主逻辑

local settingUI = import("..View.SettingView")--主逻辑
local talkUI = import("..View.TalkWidget")--主逻辑

--声明游戏场景类
local OxTwo  = class("OxTwo", function() return display.newScene("OxTwo")end)

local MAX_TIME = 10
local CMD_C_CallBanker = {}
local CMD_C_AddScore = {}
local CMD_C_CHANGE_CARD = {}
local CMD_C_OxCard = {}
--本类的构造函数
function OxTwo:ctor(args)
    display.addSpriteFrames("oxtwo/UIGameIng.plist","oxtwo/UIGameIng.png")
    display.addSpriteFrames("oxtwo/talkWidgetPlist.plist","oxtwo/talkWidgetPlist.png")
    display.addSpriteFrames("oxtwo/settingWidgetPlist.plist","oxtwo/settingWidgetPlist.png")
    self.App=AppBaseInstanse.OxTwoApp
    self:setNodeEventEnabled(true)
    self.gameState = OxTwoDefine.SUB_S_GAME_START
    self.wBankerUser = nil
    self.handCardControl = {}
    self.timerCount = 0
    self.t_Start = nil
    self.t_Bander = nil
    self.t_AddSource = nil
    self.t_Change = nil
    self.t_Open = nil
    self.totalScoure = 0
    print("----------------------------------") 
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
            wKindID=OxTwoDefine.KIND_ID,
            wPlayerCount=OxTwoDefine.GAME_PLAYER,
            dwClientVersion=OxTwoDefine.VERSION_CLIENT,
            pszGameName=OxTwoDefine.GAME_NAME,
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
function OxTwo:FreeAllData()
    --首发牌用户
    self.HandCardCount={0,0}
    for i=1, OxTwoDefine.GAME_PLAYER do
        self.handCardControl[i]:FreeControl()
    end

    local xspac = 200
    local yspac = 200
    local xx = display.cx + 200
    local xj = display.cx - 200
    self.handCardPos=
        {
            cc.p(display.cx-80,display.height - 160),--1号位置 对家
            cc.p(display.cx-300,140),--4号位置 对家
        }
    self.isopen = false
    self.wBankerUser = nil
    self.bUserOxCard = {}
    self.lTurnMaxScore = 0
    self.lUserMaxScore = {}
    self.pokerCards = {}
    self.pokerCount = 0
    self.wWinUser = 0 --记录上次赢得玩家
    self.lTotalScore=nil
    self.lTableScore=nil
    self.cbPlayStatus = {} --所有玩家状态
    self.wViewChairID = {} --对应视图位置
    self.bUserOxCard = {}
    self.bShowSocre = {}
    self.bWaitAdd = true
    self.bAutoOpenCard = true
    self.wWaitCallIndex = 0
    self.wDispatchCardIndex = 0
    self.bRiffleCard = false
    self.wDispatchCardIndex = 0
    self.countindex = 0
    self.isChange = true
end
--加载资源
function OxTwo:InitUnits()

    --读取json 文件
    local node = oxui.getUIByName("oxtwo/oxtwoLayer.json")
    self.node  = node
    node:addTo(self)
    node:setContentSize(display.width,display.height)
    self.btnStart=oxui.getNodeByName(node,"btnStart")
    --退出按钮
    self.btnLeave=oxui.getNodeByName(node,"btnLeave")
    --设置按钮
    self.btnSetting=oxui.getNodeByName(node,"btnSetting")
    --换桌按钮
    self.btnChangeDesk=oxui.getNodeByName(node,"btnChangeDesk")
    --self.btnChangeDesk:hide()
    --任务按钮
    self.clock=oxui.getNodeByName(node,"clock")
    --时间
    self.lbltime=oxui.getNodeByName(node,"time")
    --名称
    self.lab=oxui.getNodeByName(node,"lab")
    --名称
    self.BankerView=oxui.getNodeByName(node,"BankerView")
    self.btnBanker=oxui.getNodeByName(self.BankerView,"btnBanker")
    self.btnBankerCancel=oxui.getNodeByName(self.BankerView,"btnBankerCancel")
    --加分
    self.addSourceView=oxui.getNodeByName(node,"addSourceView")
    --分数1
    self.btnAdd1=oxui.getNodeByName(self.addSourceView,"btnAdd1")

    self.lblnum1 = oxui.getNodeByName(self.btnAdd1,"num")
    --分数1
    self.btnAdd2=oxui.getNodeByName(self.addSourceView,"btnAdd2")
    self.lblnum2 = oxui.getNodeByName(self.btnAdd2,"num")
    --分数1
    self.btnAdd3=oxui.getNodeByName(self.addSourceView,"btnAdd3")
    self.lblnum3 = oxui.getNodeByName(self.btnAdd3,"num")
    --分数1
    self.btnAdd4=oxui.getNodeByName(self.addSourceView,"btnAdd4")
    self.lblnum4 = oxui.getNodeByName(self.btnAdd4,"num")

    --开牌视图
    self.openView=oxui.getNodeByName(node,"openView")
    self.btnOpen=oxui.getNodeByName(self.openView,"btnOpen")
    self.btnTip=oxui.getNodeByName(self.openView,"btnTip")
    self.btnChat = oxui.getNodeByName(node,"btnChat")
    
    self.Totalay=oxui.getNodeByName(node,"Totalay")
    self.TotaScoure=oxui.getNodeByName(self.Totalay,"TotaScoure")
    --声明Player对象
    self.m_GameUser=GameUser.new(node,self.m_GameKernel)
    --加载牌的资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Common/AnimationCard.ExportJson")

    -- --牌堆位置
    self.HeapPos=cc.p(display.cx,display.cy)
    --用户手牌的位置

    --初始化牌堆
    self:InitHeapCard()
    --初始化手牌
    self:InitHandCardControl()  
  
    require("plazacenter.widgets.GameHornMsgWidget").new(self)
end
--初始化牌堆
function OxTwo:InitHeapCard()
    --发牌张数
    self.DispatchCount={0,0}

    for i=1,OxTwoDefine.GAME_PLAYER do
        table.insert(self.handCardControl,CardControl.new())
    end

    local xspac = 200
    local yspac = 200
    local xx = display.cx + 200
    local xj = display.cx - 200

    self.handCardPos=
        {
            cc.p(display.cx-80,display.height - 160),--1号位置 对家
            cc.p(display.cx-300,140),--4号位置 对家
        }
    --用户手牌的间距
    self.handCardDistance=
        {
            22,--0号位置 对家
            100,--1号位置 对家

        }
    --用户手牌的大小
    self.handCardScal=
        {
            0.6,--1号位置 对家
            0.8,--4号位置 对家
        }
         
end
--初始化手牌
function OxTwo:InitHandCardControl()
    for i=1, OxTwoDefine.GAME_PLAYER do
        self.handCardControl[i]:SetStartPos(self.handCardPos[i])
        self.handCardControl[i]:SetDistance(self.handCardDistance[i])
        self.handCardControl[i]:addTo(self.node)
        if i == OxTwoDefine.MYSELF_VIEW_ID then
            self.handCardControl[i]:SetShow(true)
            self.handCardControl[i]:SetCardTouchEnabled(true)
        else
            self.handCardControl[i]:SetShow(false)
            self.handCardControl[i]:SetCardTouchEnabled(false)
        end
    end
end

--开始发牌
function OxTwo:StartDisPachCard()
    --发牌张数
    self:stopAllTimer()
    self.dispatchCardCount=0
    self.HandCardCount={0,0}
    self:moveDisPachCard()
end

function OxTwo:DisPatchOneCardEnd(evt)
    oxui.playSound("SEND_CARD",false,OxTwoDefine.wav)
    self.pokerCount = self.pokerCount - 1
    if self.pokerCount == 0 then
        self:OnSendCardFinish()
    end
end

--控件消息
function OxTwo:ButtonMsg()
    -------------------------------------------------
    --开始按钮事件
    -------------------------------------------------
    self.btnStart:onButtonClicked(function ()
        self.m_GameKernel:StartGame()
        --if self:IsNotLookonMode() then
        self:stopAllTimer()
        --end
        self.btnStart:hide()
    end)
    --开始按钮按下
    self.btnStart:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnStart)
    end)

    --开始按钮抬起
    self.btnStart:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnStart)
    end)
    -------------------------------------------------
    --离开按钮事件
    -------------------------------------------------
    self.btnLeave:onButtonClicked(function ()
        --self:stopTimer()
        self:Exit()
    end)
    --离开按钮按下
    self.btnLeave:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnLeave)
    end)

    --离开按钮抬起
    self.btnLeave:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnLeave)
    end)
    -------------------------------------------------
    --换桌按钮事件
    -------------------------------------------------

    self.btnChangeDesk:onButtonClicked(function ()
        self.ClientKernel:quickChangeTable()
        end)
    --托管按钮按下
    self.btnChangeDesk:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnChangeDesk)
    end)

    --托管按钮抬起
    self.btnChangeDesk:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnChangeDesk)
    end)

    -------------------------------------------------
    --提示按钮事件
    -------------------------------------------------

    self.btnChat:onButtonClicked(function ()
        dump("提示")
        if not  self.isChat then
            self.isChat = true
            self.chatView = talkUI.new(self.ClientKernel)
            self.chatView:setPosition(cc.p(display.width - 408,56))
            self:addChild(self.chatView)
        else
            self.isChat= false
            self.chatView:removeFromParent()
            self.chatView= nil
        end

    end)
    --提示按钮按下
    self.btnChat:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnChat)

    end)

    --离开按钮抬起
    self.btnChat:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnChat)
    end)

    --------------------------------------------------
    --设置按钮事件
    -------------------------------------------------
    self.btnSetting:onButtonClicked(function ()
        dump("设置按钮事件")
        local settingView = settingUI.new()
        settingView:setPosition(cc.p(display.cx,display.cy))
        self:addChild(settingView)
    end)
    --设置按钮按下
    self.btnSetting:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnSetting)
    end)

    --设置按钮抬起
    self.btnSetting:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnSetting)
    end)

    --------------------------------------------------
    --
    self.btnBanker:onButtonClicked(function ()
        print("叫庄确定")
        self:stopAllTimer()
        CMD_C_CallBanker.bBanker =  1--self:GetMeChairID()
        dump(CMD_C_CallBanker)
        self:send(OxTwoDefine.SUB_C_CALL_BANKER,CMD_C_CallBanker ,"CMD_C_CallBanker")
        self.BankerView:hide()
        self.clock:hide()
    end)

    self.btnBankerCancel:onButtonClicked(function ()
        print("叫庄取消")
        self:sendBankerCancel()
    end)

    self.btnAdd1:onButtonClicked(function ()
        self:sendAddSource(1)
        self.addSourceView:hide()
    end)

    self.btnAdd2:onButtonClicked(function ()
        self:sendAddSource(2)
        self.addSourceView:hide()
    end)

    self.btnAdd3:onButtonClicked(function ()
        self:sendAddSource(3)
        self.addSourceView:hide()
    end)

    self.btnAdd4:onButtonClicked(function ()
        self:sendAddSource(4)
        self.addSourceView:hide()
    end)
    --设置按钮抬起
    self.btnOpen:onButtonClicked(function ()
        --if self.open == false then
        self:sendOpenMsg()
        self.openView:hide()
        --end
    end)

    self.btnTip:onButtonClicked(function ()
        local cardData = self.cbHandCardData[self:GetMeChairID()+1]
        local bCardValue = GameLogic:GetCardType2(cardData,OxTwoDefine.MAXCOUNT,cardData)
        if bCardValue > 0 then
            self.handCardControl[OxTwoDefine.MYSELF_VIEW_ID]:SetShootOXOpoker()
        else
            self.openView:hide()
            self:SetAnimCard(OxTwoDefine.MYSELF_VIEW_ID,0)
            local bOX = 0
            CMD_C_OxCard = {bOX = bOX}
            self:send(OxTwoDefine.SUB_C_OPEN_CARD,CMD_C_OxCard ,"CMD_C_OxCard")
        end
    end)

    self.btnOpen:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnOpen)
    end)

    --设置按钮抬起
    self.btnOpen:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnOpen)
    end)

    self.btnTip:onButtonPressed(function ()
        self:playScaleAnimation(true,self.btnTip)
    end)

    --设置按钮抬起
    self.btnTip:onButtonRelease(function ()
        self:playScaleAnimation(false,self.btnTip)
    end)
end

function OxTwo:sendBankerCancel()
    CMD_C_CallBanker.bBanker = 0
    self:send(OxTwoDefine.SUB_C_CALL_BANKER,CMD_C_CallBanker ,"CMD_C_CallBanker")
    self.BankerView:hide()
end

function OxTwo:sendOpenMsg()
    local cardData = self.cbHandCardData[self:GetMeChairID()+1]
    local bOX = 0
    if GameLogic:GetOxCard(cardData,OxTwoDefine.MAXCOUNT) then
        bOX = 1
    end

    CMD_C_OxCard = {bOX = bOX}
    self:send(OxTwoDefine.SUB_C_OPEN_CARD,CMD_C_OxCard ,"CMD_C_OxCard")
end

function OxTwo:sendAddSource(index)
    CMD_C_AddScore.lScore = self.lUserMaxScore[index]
    self:send(OxTwoDefine.SUB_C_ADD_SCORE,CMD_C_AddScore ,"CMD_C_AddScore")
end



---------------[[以下是接收游戏服务端消息处理]]--------------
--场景
function OxTwo:OnGameScenceMsg(evt)
    print("场景====++++++++++++++++++++++++++++++++++")
    --dump(evt.para);
    local unResolvedData = evt.para.unResolvedData
    local param = evt.para
    --    print("param.cbGameStatus" ..self.ClientKernel.cbGameStatus)
    --    print("elf:getMyStatus() = " .. self:getMyStatus())
    if self.ClientKernel.cbGameStatus==OxTwoDefine.GS_TK_FREE then
        print("空闲状态")
        local statusInfo = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusFree")

        if self:getMyStatus() == US_SIT and self:getMyStatus() ~= US_PLAYING then
            local lCellScore = statusInfo.lCellScore
            self:stopAllTimer()
            if not self.t_Start then
                self.gameState = OxTwoDefine.GS_TK_FREE
                self.timerCount = 10
                self.t_Start = oxui.schedule(function()self:updateState() end,OxTwoDefine.TIME_INTERVAL,OxTwoDefine.TIME_USER_START_GAME)
            end

            self.btnStart:show()
        end
        --叫庄状态
    elseif param.cbGameStatus==OxTwoDefine.GS_TK_CALL then

        local statusInfo = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusCall")
        self.cbPlayStatus = statusInfo.cbPlayStatus
        self.btnStart:hide() 
        for i=0,OxTwoDefine.MAXCOUNT do
            self:setUserPlayingStatus(self.wViewChairID[i],self.cbPlayStatus[i])
        end
        print("  游戏开始中-------000-----叫庄状态 ")
        --self.btnStart:hide()
    elseif param.cbGameStatus==OxTwoDefine.GS_TK_SCORE then

        local statusInfo = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusScore")
        self.lTurnMaxScore = statusInfo.lTurnMaxScore
        self.m_wBankerUser = statusInfo.wBankerUser
        print("下注-------000-----状态")
        self.btnStart:hide() 
        self.gameState = OxTwoDefine.SUB_S_ADD_SCORE
        if not self.t_Change then
            self:stopAllTimer()
            self.timerCount = OxTwoDefine.TIME_USER_ADD_SCORE
            self.t_Change = oxui.schedule(function()
                self:updateState()
            end ,
            OxTwoDefine.TIME_INTERVAL,
            OxTwoDefine.TIME_USER_ADD_SCORE)
        end
    elseif param.cbGameStatus==OxTwoDefine.GS_TK_PLAYING then
        local statusInfo = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusPlay")
        print("游戏-------000-----进行")
        self.lTurnMaxScore=statusInfo.lTurnMaxScore
        self.wBankerUser=statusInfo.wBankerUser
        self.btnStart:hide() 
        self.gameState = OxTwoDefine.SUB_S_OPEN_CARD
        if not self.t_Open then
            self:stopAllTimer()
            self.timerCount = OxTwoDefine.TIME_USER_OPEN_CARD
            self.t_Open = oxui.schedule(function()
                self:updateState()
            end ,
            OxTwoDefine.TIME_INTERVAL,
            OxTwoDefine.TIME_USER_OPEN_CARD)
        end
    end

end

--退出
function OxTwo:Exit()
    if self:getMyStatus() == US_PLAYING then
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
        --msgbox:zoder(self,10000)

    else
        oxui.removeAll()
        self.m_GameUser:LeaveType()
    end
end

function OxTwo:OnSubPlayerOpen(evt)
    print("所有玩家都开完牌") 
end
--游戏结束
function OxTwo:OnSubGameOver(evt)
    local pGameEnd = evt.para
    self.wWinUser = pGameEnd.wWinUser or 0
    self.cbHandCardData = {}
    self:stopAllTimer()
    local viewId = self.m_GameKernel:SwitchViewChairID(self:GetMeChairID()) 
    
    function callFuck()
        local v = self:getChildByName("AnimationWin")
        if v then
            v:removeFromParent()
        end
        local v = self:getChildByName("AnimationLose")
        if v then
            v:removeFromParent()
        end

        self.gameState = OxTwoDefine.GS_TK_FREE
        if not self.t_Start then
            self.timerCount = OxTwoDefine.TIME_USER_START_GAME
            self.t_Start = oxui.schedule(function(t) self:updateState(OxTwoDefine.TIME_USER_START_GAME - t) end ,OxTwoDefine.TIME_INTERVAL,OxTwoDefine.TIME_USER_START_GAME)
        end
        self:clearAll()
        self.btnStart:show()
    end
     
    self.totalScoure = self.totalScoure + pGameEnd.lGameScore[self:GetMeChairID()+1]
    self.TotaScoure:setString(oxui.BMString(self.totalScoure))
    
    if pGameEnd.lGameScore[self:GetMeChairID()+1] > 0 then  
    
        oxui.playSound("GAME_WIN",false,OxTwoDefine.m4a)
        local armature = oxui.playAnimation(self,1000,"AnimationGameEnd",0,false)
        armature:setName("AnimationWin")
        armature:setPosition(display.cx,display.cy)
        local ani = armature:getAnimation()

        ani:setMovementEventCallFunc(function() callFuck() end)
    else
        oxui.playSound("GAME_LOST",false,OxTwoDefine.m4a)
        local armature = oxui.playAnimation(self,1000,"AnimationGameEnd",1,false)
        armature:setName("AnimationLose")
        armature:setPosition(display.cx,display.cy)
        local ani = armature:getAnimation()
        
        ani:setMovementEventCallFunc(function() callFuck() end) 
    
    end
    for  i=1,OxTwoDefine.GAME_PLAYER do
        local souce = pGameEnd.lGameScore[i] 
        if souce >= 0 then 
            self.m_GameUser:ShowScore(self.wViewChairID[i-1],souce,true)
        else
            self.m_GameUser:ShowScore(self.wViewChairID[i-1],souce,false)
        end
    end

--    oxui.schedule(function ()
--            self.gameState = OxTwoDefine.GS_TK_FREE
--            if not self.t_Start then
--                self.timerCount = OxTwoDefine.TIME_USER_START_GAME
--                self.t_Start = oxui.schedule(function(t) self:updateState(OxTwoDefine.TIME_USER_START_GAME - t) end ,OxTwoDefine.TIME_INTERVAL,OxTwoDefine.TIME_USER_START_GAME)
--            end
--            self.btnStart:show()
--            self:clearAll()
--    end,2,1)
end

function OxTwo:clearAll()
    self.BankerView:hide()
    self.addSourceView:hide()
    self.openView:hide()
    self.m_GameUser:FreeAllBanders()
    self:FreeAllData()
    self.m_GameUser:FreeAllAddSouce()
end

function OxTwo:stopAllTimer()
    self.clock:hide()
    if self.t_Start then
        oxui.stop(self.t_Start)
        self.t_Start = nil
    end

    if self.t_Bander then
        oxui.stop(self.t_Bander)
        self.t_Bander = nil
    end

    if self.t_AddSource then
        oxui.stop(self.t_AddSource)
        self.t_AddSource = nil
    end

    if self.t_Change then
        oxui.stop(self.t_Change)
        self.t_Change = nil
    end

    if self.t_Open then
        oxui.stop(self.t_Open)
        self.t_Open = nil
    end
end


--游戏开始
function OxTwo:OnSubGameStatrt(evt)
    print("游戏开始")
    local user = evt.para
    self.lTurnMaxScore=user.lTurnMaxScore
    self.wBankerUser=user.wBankerUser
    local m_lScoreTax=user.lScoreTax

    local ViewID=self.m_GameKernel:SwitchViewChairID(self.wBankerUser)
    if self:IsNotLookonMode() and user.wBankerUser ~= self:GetMeChairID() then
        self.bWaitAdd=true
        self.lUserMaxScore = {}
        local souce = self.lTurnMaxScore
        for i=1,4 do
            self.lUserMaxScore[i]= math.floor(souce)
            souce = souce / 2
        end
        self.addSourceView:show()
        self:updateAddSourceView(self.lUserMaxScore,true)
        self.gameState = OxTwoDefine.SUB_S_ADD_SCORE_MY
        print("进入加注")
    else
        self.gameState = OxTwoDefine.SUB_S_ADD_SCORE
        print("开始游戏不满足")
    end
    oxui.playSound("GAME_START",false,OxTwoDefine.m4a)
    --if self.clock:isVisible() then
    self:stopAllTimer()
   -- end

    if not self.t_AddSource then 
        print("加分")
        self.timerCount = OxTwoDefine.TIME_USER_ADD_SCORE
        self.t_AddSource = oxui.schedule(function () self:updateState()end ,OxTwoDefine.TIME_INTERVAL,OxTwoDefine.TIME_USER_ADD_SCORE)
    end
    self.m_GameUser:setBander(ViewID)
end

--加注结果
function OxTwo:OnSubAddScore(evt)
    print("加注结果11111")
    local p = evt.para -- lAddScoreCount --加注数目
    local ViewID=self.m_GameKernel:SwitchViewChairID(p.wAddScoreUser)
    print("ViewID 。。 " .. ViewID)
    if ViewID == OxTwoDefine.MYSELF_VIEW_ID and self:IsNotLookonMode() then
        self:updateAddSourceView(nil,false)
        self.addSourceView:hide()
        print("加注时器")
    end

    local wAddScoreUser=p.wAddScoreUser
    local wViewChairID=self.wViewChairID[wAddScoreUser]
    self:setUserTableScore(ViewID,p.lAddScoreCount)
    if self.cbPlayStatus[p.wAddScoreUser]==OxTwoDefine.USEX_PLAYING then
        self:OnUserAddScore(wViewChairID,p.lAddScoreCount,false)
    end
    print("加注数目"  .. p.lAddScoreCount )
    oxui.playSound("ADD_SCORE" ,false, OxTwoDefine.wav)
end

function OxTwo:OnUserAddScore(id)
--移动筹码
--m_GoldMove.SetAddScore(wChairID,lTableScore,m_JetonStartPos[wChairID]);
end
--加注显示
function OxTwo:updateAddScore(scrs)

end
--用户强退
function OxTwo:OnSubPlayerExit(evt)
    print("用户强退1111")
    --dump(evt.para);
end
--发牌消息
function OxTwo:OnSubSendCard(evt)
    print("发牌消息111")
    local pSendCard = evt.para
    self.MeCard = pSendCard.cbCardData
    self:dealCardRes(self.MeCard)
end



--用户叫庄
function OxTwo:OnSubCallBanker(evt)
    local p = evt.para
    --local ViewID=self.m_GameKernel:SwitchViewChairID(p.wCallBanker)
    --dump(p)
    --print("叫庄")
    if p.bFirstTimes ==1 then
        local armature = oxui.playAnimation(self,nil,"AnimationBeginGame",0,false)
        armature:setName("AnimationBeginGame")
        armature:setPosition(display.cx,display.cy)
        oxui.playSound("GAME_START",false,OxTwoDefine.m4a)
        local ani = armature:getAnimation()
        ani:setMovementEventCallFunc(function(arm, eventType, movmentID)
            local v = self:getChildByName("AnimationBeginGame")
            if v then
                v:removeFromParent()
                for i=1, OxTwoDefine.GAME_PLAYER do
                    if not self.m_GameUser.sixHeros[i-1] then
                        self.wViewChairID[i-1] = self.m_GameKernel:SwitchViewChairID(i-1)
                        self.cbPlayStatus[i-1] = OxTwoDefine.USEX_NULL
                    else
                        self.wViewChairID[i-1] = self.m_GameKernel:SwitchViewChairID(i-1)
                        self.cbPlayStatus[i-1]= OxTwoDefine.USEX_PLAYING
                        if self.wViewChairID[i-1] then
                            self.m_GameUser:setSZName(self.wViewChairID[i-1],self.m_GameUser.sixHeros[i-1].szNickName)
                        end
                    end
                end
            end
        end)
    end

    print("p.wCallBanker = ".. p.wCallBanker)
    print("self:GetMeChairID() ".. self:GetMeChairID())
    self:stopAllTimer()
    if p.wCallBanker == self:GetMeChairID() and self:IsNotLookonMode()  then
        self.BankerView:show()
    end
    local wViewID = self.wViewChairID[p.wCallBanker]
    if p.wCallBanker== self:GetMeChairID() then
        if not self.t_Bander then
            self:stopAllTimer()
            self.gameState = OxTwoDefine.SUB_S_CALL_BANKER
            self.timerCount = OxTwoDefine.TIME_USER_CALL_BANKER
            self.t_Bander = oxui.schedule(function()
                self:updateState()
            end ,
            OxTwoDefine.TIME_INTERVAL,
            OxTwoDefine.TIME_USER_CALL_BANKER)
        end
    else
        if not self.t_Bander then
            self:stopAllTimer()
            self.gameState = OxTwoDefine.SUB_S_CALL_OTH
            self.timerCount = OxTwoDefine.TIME_USER_CALL_BANKER
            self.t_Bander = oxui.schedule(function()
                self:updateState()
            end ,
            OxTwoDefine.TIME_INTERVAL,
            OxTwoDefine.TIME_USER_CALL_BANKER)
        end
    end

end
--发送基数

--摊牌
function OxTwo:OnSubOpenCard(evt)
--    print("所有人换牌完成 摊牌")
--    local wChairID= self:GetMeChairID()
--
--    if not self:IsNotLookonMode() then
--        self.handCardControl[OxTwoDefine.MYSELF_VIEW_ID]:SetPositively(true)
--    end
--    local wViewChairID = self.wViewChairID[wChairID]
--    if not self.t_Open then
--        self:stopAllTimer()
--
--        self.gameState = OxTwoDefine.SUB_S_CHANGE_OPEN
--        self.timerCount = OxTwoDefine.TIME_USER_OPEN_CARD
--        self.t_Open = oxui.schedule(function()
--            self:updateState()
--        end ,
--        OxTwoDefine.TIME_INTERVAL,
--        OxTwoDefine.TIME_USER_OPEN_CARD)
--    end
--
--    --m_GameClientView.OnShowChangeRect(false);
--    if not self:IsNotLookonMode() then
--        print("摊派过滤了")
--        return
--    end
--
--    --特殊牌型cbHandCardData
--    --dump(self.cbHandCardData)
--    if self.cbHandCardData[wChairID+1] and self.cbHandCardData[wChairID+1][1] >0 then
--        --dump(self.cbHandCardData[wChairID+1] )
--        local bCardType = GameLogic:GetCardType2(self.cbHandCardData[wChairID+1],OxTwoDefine.MAXCOUNT)
--        print("bCardType=" .. bCardType)
--        if bCardType >= OxTwoDefine.OX_THREE_SAME then
--
--            CMD_C_OxCard = {bOX = 1}
--            self:send(OxTwoDefine.SUB_C_OPEN_CARD,CMD_C_OxCard ,"CMD_C_OxCard")
--            self.handCardControl[wViewChairID]:SetPositively(false);
--
--            --保存牛信息
--            self.bUserOxCard[wChairID]=true
--        end
--    end
--    if(self.cbPlayStatus[wChairID]==OxTwoDefine.USEX_PLAYING) then
--        self.openView:show()
--    end

end

function OxTwo:OnSubEndOpen(evt)
    print("开牌")
    local p = evt.para
    dump(evt)
    local wChairID = self:GetMeChairID()
    local myViewID = self.wViewChairID[p.wPlayerID]
    local wID=p.wPlayerID + 1
    print(" wChairID = " .. wChairID .. " myViewID = " .. myViewID .. " wID = " .. wID )
    if not self:IsNotLookonMode() then
        return
    end
    if self:GetMeChairID() == p.wPlayerID then
        print("myself")
        self.handCardControl[myViewID]:SetCardTouchEnabled(false)
        oxui.playSound("OPEN_CARD",false,OxTwoDefine.wav) 
        local cardData = self.cbHandCardData[wID]
        dump(cardData)
        local bCardValue = GameLogic:GetCardType2(cardData,OxTwoDefine.MAXCOUNT,cardData)
        if bCardValue > 0 then
            self:SetAnimCard(myViewID,bCardValue)
            self:onOxEnable(true,wID)
        else
            self:SetAnimCard(myViewID,0)
        end
        self.isopen = true
    else
        print("sideself")
        dump(myViewID)
        
        self.handCardControl[myViewID]:SetShow(true)
        local cardData = self.cbHandCardData[wID]
        dump(cardData)
        local bCardValue = GameLogic:GetCardType2(cardData,OxTwoDefine.MAXCOUNT,cardData)

        if bCardValue > 0 then
            self:SetAnimCard(myViewID,bCardValue)
        else
            self:SetAnimCard(myViewID,0)
        end
        self:onOxEnable(false,wID)
    end
end

function OxTwo:SetAnimCard(wViewChairID,number)
    print("wViewChairID= %d, number= %d",wViewChairID,number)

    if not self.handCardControl[wViewChairID]:getChildByName("AnimationOxType") then
        local armature = oxui.playAnimation(self.handCardControl[wViewChairID],200,"AnimationOxType",number,false)
        armature:setName("AnimationOxType")
        armature:setScale(0.6)
        if  number and number > 0 then
            armature:setColor(cc.c3b(223,214,1,255))
        end

        local posx
        if wViewChairID == OxTwoDefine.MYSELF_VIEW_ID then
            posx = self.handCardPos[wViewChairID].x - 180
        else
            posx = self.handCardPos[wViewChairID].x -60
        end

        local posy = self.handCardPos[wViewChairID].y - 20
        armature:setPosition(posx,posy)
    end


    if number then
        oxui.playSound("ox" .. number,false,OxTwoDefine.m4a)
    end

    if number == 0 and wViewChairID == OxTwoDefine.MYSELF_VIEW_ID then
        self.handCardControl[OxTwoDefine.MYSELF_VIEW_ID]:setUnSelected()
    end


end
--场景进入
function OxTwo:onEnter()
    SoundManager:playMusicBackground(oxui.ogg .. "ox_backbround.m4a", true) 
    
    local game = (0 ~= bit._and(self.ClientKernel.serverAttribute.dwServerRule, SR_FORFEND_GAME_CHAT))
    local room = (0 ~= bit._and(self.ClientKernel.serverAttribute.dwServerRule, SR_FORFEND_ROOM_CHAT))
    if game or room then
        self.btnChat:hide()
    else
        self.btnChat:show()
    end
end
--场景销毁
function OxTwo:onExit()
    print("退出了")
    SoundManager:stopMusicBackground()
    self.ClientKernel:removeListenersByTable(self.GameeventHandles) 
end
function OxTwo:onCleanup()
    print("场景销毁") 
    oxui.removeArmatureFileInfo("AnimationBeginGame")
    oxui.removeArmatureFileInfo("AnimationGameEnd")
    oxui.removeArmatureFileInfo("AnimationOxType")
    ccs.ArmatureDataManager:destroyInstance() 
    display.removeSpriteFramesWithFile("oxtwo/UIGameIng.plist","oxtwo/UIGameIng.png")
    display.removeSpriteFramesWithFile("oxtwo/talkWidgetPlist.plist","oxtwo/talkWidgetPlist.png")
    display.removeSpriteFramesWithFile("oxtwo/settingWidgetPlist.plist","oxtwo/settingWidgetPlist.png")
    display.removeSpriteFrameByImageName("oxtwo/u_game_table.jpg")
    display.removeSpriteFrameByImageName("oxtwo/bg_two_logo.png") 
    self.m_GameUser:OnFreeInterface()
    self.m_GameKernel:OnFreeInterface()
    self.ClientKernel:cleanup()
end
--事件管理
function OxTwo:RegistEventManager()

    --游戏类操作消息
    local eventListeners = eventListeners or {}
    eventListeners[OxTwoDefine.GAME_SCENCE] = handler(self, self.OnGameScenceMsg)-- 场景的消息
    eventListeners[OxTwoDefine.GAME_START] = handler(self, self.OnSubGameStatrt)  -- 游戏开始
    eventListeners[OxTwoDefine.GAME_ADD_SCORE] = handler(self, self.OnSubAddScore)-- 加注结果
    eventListeners[OxTwoDefine.GAME_PLAYER_EXIT] = handler(self, self.OnSubPlayerExit)-- 玩家退出
    eventListeners[OxTwoDefine.GAME_SEND_CARD] = handler(self, self.OnSubSendCard) -- 发牌消息
    eventListeners[OxTwoDefine.GAME_CALL_BANKER] = handler(self, self.OnSubCallBanker)--用户叫庄
    eventListeners[OxTwoDefine.GAME_BASE] = handler(self, self.OnSubGameBase)--发送基数
    eventListeners[OxTwoDefine.GAME_ALL_CARD] = handler(self, self.OnSubSendCard)--所有牌
    --eventListeners[OxTwoDefine.GAME_CHANGE_OPEN] = handler(self, self.OnSubOpenCard)--开牌
    eventListeners[OxTwoDefine.GAME_OPEN_CARD] = handler(self, self.OnSubEndOpen)
    eventListeners[OxTwoDefine.GAME_PLAYER_OPEN] = handler(self, self.OnSubPlayerOpen)

    --eventListeners["STOP_DEAL_GAME_MESSAGE"] = handler(self, self.OnStopDealGameMessage)
    eventListeners[OxTwoDefine.GAME_OVER] = handler(self, self.OnSubGameOver) --结束
    self.GameeventHandles = self.ClientKernel:addEventListenersByTable( eventListeners )
end

function OxTwo:OnStopDealGameMessage(evt)
--    print("-----------------------------------------------stop")
--    dump(evt)
--    self.ClientKernel:removeListenersByTable(self.GameeventHandles) 
--    self.m_GameUser:OnFreeInterface()
--    self.m_GameKernel:OnFreeInterface()
--    self.ClientKernel:cleanup()
end
--function OxTwo:ChatCallBack(evt)
--    dump(evt)
--end

--定义按钮缩放动画函数
function OxTwo:playScaleAnimation(less, pSender)
    local  scale = less and 0.9 or 1
    pSender:runAction(cc.ScaleTo:create(0.2,scale))
end

function OxTwo:updateState()
    self.timerCount = self.timerCount - 1
    --self.lbltime:setString(self.timerCount)
    self.clock:show()
    if  self.timerCount <= 0 then
        if self.gameState == OxTwoDefine.GS_TK_FREE and self:getMyStatus() ~= US_READY then
            self.m_GameUser:LeaveType()
        end
        
        if self.gameState == OxTwoDefine.SUB_S_CALL_BANKER then
            self:sendBankerCancel()
        end
        
        if self.gameState == OxTwoDefine.SUB_S_ADD_SCORE_MY then
            self.addSourceView:hide()
            self:sendAddSource(4)
        end

        if self.gameState == OxTwoDefine.SUB_S_CHANGE_OPEN then
            self:sendOpenMsg()
            self.openView:hide()
        end
        self:stopAllTimer()
        return
    end

    if self.gameState == OxTwoDefine.GS_TK_FREE then
        self.lab:setString("等待玩家准备:" ..  self.timerCount)
    elseif self.gameState == OxTwoDefine.SUB_S_CALL_BANKER then
        self.lab:setString("叫庄:" ..  self.timerCount)
    elseif self.gameState == OxTwoDefine.SUB_S_ADD_SCORE then
        self.lab:setString("等待他人加注:" ..  self.timerCount)
    elseif self.gameState == OxTwoDefine.SUB_S_ADD_SCORE_MY then
        self.lab:setString("等待加注:" ..  self.timerCount)
    elseif self.gameState == OxTwoDefine.SUB_S_CHANGE_OPEN then
        self.lab:setString("等待他人开牌:" ..  self.timerCount)
    elseif self.gameState == OxTwoDefine.SUB_S_CALL_OTH then
        self.lab:setString("等待他人叫庄:" ..  self.timerCount)
    end
end

function OxTwo:resetGameView()
    --更新玩家试图
    self.m_GameUser:resetGameView()
    self.wBankerUser = nil
    self.lTurnMaxScore = 0 -- 下注分数
    self.timer = nil
end

function OxTwo:setUserPlayingStatus(wChairID,statu)
    if wChairID < OxTwoDefine.GAME_PLAYER then
        self.cbPlayStatus[wChairID]=statu
    else
        print("设置状态出错了")
    end

    self:refreshGameView()
end
 

function OxTwo:updateAddSourceView(data,ishow)
    if data then
        for i=1, 4 do
            self["lblnum" .. i]:setString(data[i])
            self["btnAdd" .. i]:show()
            if not ishow then
                self["btnAdd" .. i]:hide()
            end
        end
    end
end

function OxTwo:setUserTableScore(wViewChairID,lAddScoreCount)
    self.m_GameUser:SetaddScouce(wViewChairID,lAddScoreCount)
end

function OxTwo:refreshGameView()
    print("更新视图")
end

function OxTwo:resetGameView()
    self.pokerCards  = {}
end


function OxTwo:fntCardData(para)
    local data = para 
    self.cbHandCardData = {}
    local ix = 1
    local  iy = 1
    for key, var in ipairs(data) do
        if not self.cbHandCardData[ix] then
            self.cbHandCardData[ix] = {}
        end

        self.cbHandCardData[ix][iy] = var

        if key % OxTwoDefine.MAXCOUNT == 0 then
            ix = ix + 1
            iy = 1
        else
            iy = iy + 1
        end
    end
    dump(self.cbHandCardData)
end
function OxTwo:dealCardRes(data)
    local index = 1
    self:fntCardData(data)
    self:StartDisPachCard()
end

function OxTwo:dispatchUserCard(wChairID,cbCardData)

    local wViewChairID=self.wViewChairID[wChairID]
    local poker
    if wChairID == self:GetMeChairID() then
        poker = self.handCardControl[wViewChairID]:AddOneCard(cbCardData,true)
        self.handCardControl[wViewChairID]:SetCardTouchEnabled(true)
    else
        poker = self.handCardControl[wViewChairID]:AddOneCard(cbCardData,false)
    end
    self.pokerCount = self.pokerCount + 1
    return poker
end

function OxTwo:moveDisPachCard()

    local winUser = self.wWinUser or 0
    local index = 0
    for j=winUser ,winUser + OxTwoDefine.GAME_PLAYER -1 do
        local w= j%OxTwoDefine.GAME_PLAYER
        if self.cbPlayStatus[w] == OxTwoDefine.USEX_PLAYING then
            local wViewChairID = self.wViewChairID[w]
            for i=1,OxTwoDefine.MAXCOUNT  do
                local poker
                dump(self.cbHandCardData[wViewChairID])
                print("wViewChairID ==== " .. wViewChairID)
                print("w".. w)
                if w == self:GetMeChairID() then
                    if self.cbHandCardData[w+1][i] ~= 0 then
                        poker = self:dispatchUserCard(w,self.cbHandCardData[w+1][i])
                    end
                else
                    if self.cbHandCardData[w+1][i] ~= 0 then
                        poker = self:dispatchUserCard(w,self.cbHandCardData[w+1][i])
                    end 
                end
                local DelyTime=0.05*index

                --oxui.schedule(function ()
                local posStart = self.HeapPos
                local posEnd = self.handCardPos[wViewChairID]
                posEnd.x= posEnd.x + self.handCardDistance[wViewChairID]
                --决定牌大小
                local Scale=self.handCardScal[wViewChairID]
                local args=
                    {
                        startPos=posStart , --起始位置
                        endPos =posEnd,     --结束位置
                        delay=DelyTime,
                        scal=Scale,
                        moveEndHandler= handler(self,self.DisPatchOneCardEnd),--结束回调处理
                    }
                poker:doCardAnimation(args)
                --end,DelyTime,1)
                index = index + 1
            end
        end
    end
end


--发牌完成
function OxTwo:OnSendCardFinish()
    local wMeChairID=self:GetMeChairID()
    if self:IsNotLookonMode()then
        self.handCardControl[OxTwoDefine.MYSELF_VIEW_ID]:SetShow(true)
    end
    self.openView:show()
    if not self.t_Change then
        self.gameState = OxTwoDefine.SUB_S_CHANGE_CARD
        self.timerCount = OxTwoDefine.TIME_USER_CHANGE_CARD
        self.t_Change = oxui.schedule(function () self:updateState()end ,
            OxTwoDefine.TIME_INTERVAL,OxTwoDefine.TIME_USER_CHANGE_CARD)
    end
end

function OxTwo:IsNotLookonMode()
    local state
    if self:getMyStatus() == US_PLAYING then
        --dump(self:getMyStatus())
        state = true
    else
        state = false
    end
    return state
end

function OxTwo:getMyStatus()
    return self.m_GameUser.myHero.cbUserStatus
end

function OxTwo:GetMeChairID()
    return self.m_GameUser.myHero.wChairID
end

function OxTwo:IsCurrentUser(wCurrentUser)
    if self:IsNotLookonMode() and  wCurrentUser == self:GetMeChairID() then
        return true
    end
    return false
end

function OxTwo:send(type,data,name)
    self.ClientKernel:requestCommand(MDM_GF_GAME,type,data ,name)
end


function OxTwo:onOxEnable(isShoot,wchairid) 
    local wViewChairID = self.wViewChairID[wchairid - 1]
    local cbCardData = self.cbHandCardData[wchairid] 
    local shoot= isShoot
    local myControl = self.handCardControl[wViewChairID]
    dump(self.handCardControl)
    dump(self.cbHandCardData) 
    dump(cbCardData)
    if shoot then
        local newData = GameLogic:sortCardRes(cbCardData,OxTwoDefine.MAXCOUNT)
        myControl:SetCardData(newData,OxTwoDefine.MAXCOUNT)
        myControl:SetShootOX()
    else
        dump("cbCardData")
        myControl:SetCardData(cbCardData,OxTwoDefine.MAXCOUNT) 
    end
    
    myControl:SetShow(true)
end


return OxTwo