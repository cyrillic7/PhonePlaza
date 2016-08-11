-- ShowHandScene 

local ClientKernel = require("common.ClientKernel")--外部公共库kernel
local GameKernel   = import("..Kernel.GameKernel")--内部公共库kernel
local Player     = import("..View.Player")--玩家管理
local HandCardControl  = import("..View.CardControl")--用户牌管理

local CardLogic    = import("..Kernel.GameLogic")--牌堆管理
local settingUI = import("..View.SettingView")--主逻辑

local GameAnimation     = import("..View.GameAnimation")--结算

local buttonCfg = {10,50,100,1000,5000,10000,100000,500000}
local iheight = display.cy

local Addpos = {cc.p(245,iheight-295),cc.p(390,iheight+240)}


--local JettonPos = {cc.p(235+75,iheight),cc.p(410+75,iheight),cc.p(585+75,iheight),cc.p(760+75,iheight)}

--声明游戏场景类
local ShowHandScene  = class("ShowHandScene", function() return display.newScene("ShowHandScene")end)
local CMD_C_AddGold = {}
function ShowHandScene:ctor(args)
    display.addSpriteFrames("showhandanex/UIShowHandanex.plist","showhandanex/UIShowHandanex.png")
	self.App=AppBaseInstanse.ShowHandApp
	self:setNodeEventEnabled(true)
    --创建gamekernel
    if args.gameClient then
        self.gameClient = args.gameClient
        self.ClientKernel = ClientKernel.new(self.gameClient,self.App.EventCenter) 
        --声明conmand对象
        self.m_GameKernel=GameKernel.new(self.ClientKernel);
    end

    self.pokerCount = 0
    self.m_wCurrentUser=0              --当前用户
    self.m_lTurnMaxGold=0              --最大下注
    self.m_lTurnBasicGol=0             --跟住数目
    self.m_lBasicGold=0                --单元数目
    self.m_lShowHandScore=0            --限制最高分
    self.m_bShowHand=false             --是否梭哈
    self.m_wCurrentCardCount=0         --当前手牌张数
    self.m_silderscore=0
    self.m_Addscorenum={}
    self.m_lUserScore={}
    self.allJettonList = {}
    self.busergiveup=false
    self.HandCardCount={0,0}
    self.sliderminscore=0.0000

    self.handCardPos=
        {
           cc.p(display.cx-100,150),--1号位置 对家
            cc.p(display.cx-100,display.height - 160),--4号位置 对家
        }

    -- --牌堆位置
    self.HeapPos=cc.p(display.cx,display.cy)

    --用户手牌的大小
    self.handCardScal=
        {
             0.7,--1号位置 对家
            0.6,--4号位置 对家
        }

     --用户手牌的间距
    self.handCardDistance=
        {
             35,--0号位置 对家
            30,--1号位置 对家
        }

	local gameAttribute = 
    {
        wKindID=ShowHandDefine.KIND_ID,
        wPlayerCount=ShowHandDefine.GAME_PLAYER,
        dwClientVersion=ShowHandDefine.VERSION_CLIENT,
        pszGameName=ShowHandDefine.GAME_NAME,
    }

    self.m_HandCardControl = {}
    self.m_GameKernel:getClientKernel():SetGameAttribute(gameAttribute)

    self.m_CardLogic=CardLogic.new()
    self:InitUnits()          --加载资源
    self:FreeAllData()
    self:RegistEventManager() --注册事件管理
    self:ButtonMsg()          --控件消息

    --计时器
    self:schedule(handler(self,self.schedulerFunction), 1.0) 
end

--计时器回调
function ShowHandScene:schedulerFunction()
    --玩家管理计时器
    self.m_Player:OnUserClock()
    --self.SysTime:setString(self:GetSystime())
end

--加载资源
function ShowHandScene:InitUnits()

	local Gamtableb=display.newSprite("showhandanex/u_game_table.jpg")
	if display.height > Gamtableb:getContentSize().height  then
        local scale=display.height/Gamtableb:getContentSize().height
        Gamtableb:setScale(scale)
    end

    Gamtableb:center()
    Gamtableb:addTo(self)
--读取json 文件
    self.jsonnode = cc.uiloader:load("showhandanex/SHGameView.ExportJson")
    self.jsonnode:addTo(self)

--初始化手牌
    self:InitHandCardControl()

    --换桌按钮
    self.btnChangeDesk=cc.uiloader:seekNodeByName(self.jsonnode,"btnChangeDesk")  
    --设置按钮
    self.btnSetting=cc.uiloader:seekNodeByName(self.jsonnode,"btnSetting")

--开始按钮
    self.ButtonStart=cc.uiloader:seekNodeByName(self.jsonnode,"Button_Satrt")
    self.ButtonStart:zorder(260)

--声明Player对象
    self.m_Player=Player.new(self.jsonnode,self.m_GameKernel)

--退出按钮
    self.ButtonExit=cc.uiloader:seekNodeByName(self.jsonnode,"Button_Exit_Game")

--加注界面
    self.AddView=cc.uiloader:seekNodeByName(self.jsonnode,"AddView")
    self.AddView:hide()
--放弃按钮
    self.ButtonGiveUp=cc.uiloader:seekNodeByName(self.AddView,"Button_Giveup")
--梭哈按钮
    self.ButtonShowHand=cc.uiloader:seekNodeByName(self.AddView,"Button_ShowHand")
--跟住按钮
    self.ButtonFollow=cc.uiloader:seekNodeByName(self.AddView,"Button_Follow")
    self.ButtonFollow:hide()
--过牌按钮
    self.ButtonPass=cc.uiloader:seekNodeByName(self.AddView, "Button_Pass")
    self.ButtonPass:show()
--加注按钮
    self.ButtonAdd=cc.uiloader:seekNodeByName(self.AddView,"Button_Add")
    --确定
    self.ButtonSure=cc.uiloader:seekNodeByName(self.AddView, "Button_Sure")
    self.ButtonSure:hide()

    --加注
    self.ScoreView=cc.uiloader:seekNodeByName(self.jsonnode, "ScoreView_Add")
    self.ScoreView:hide()
    --加注1
    self.ButtonAdd_One=cc.uiloader:seekNodeByName(self.ScoreView, "Add1")
    self.ButtonAdd_One_text=cc.uiloader:seekNodeByName(self.ButtonAdd_One, "Add1_text")
    --加注2
    self.ButtonAdd_Two=cc.uiloader:seekNodeByName(self.ScoreView, "Add2")
    self.ButtonAdd_Two_text=cc.uiloader:seekNodeByName(self.ButtonAdd_Two, "Add2_text")
    --加注3
    self.ButtonAdd_Three=cc.uiloader:seekNodeByName(self.ScoreView, "Add3")
    self.ButtonAdd_Three_text=cc.uiloader:seekNodeByName(self.ButtonAdd_Three, "Add3_text")

    self.AddSlider=cc.uiloader:seekNodeByName(self.ScoreView, "slider")
    self.AddSlider_fg=cc.uiloader:seekNodeByName(self.AddSlider, "slider_fg")
    self.AddSlider_button=cc.uiloader:seekNodeByName(self.AddSlider, "button_slider")
    self.AddSlider_fg.maxHeight = self.AddSlider:getContentSize().width
    self.AddSlider_fg.minHeight = 0
    self.AddSlider_fg.width = self.AddSlider:getContentSize().height
    self:setSliderValue(0)
    self:BtTouchSliderMsg(self.AddSlider_button)


    self.AddNum=cc.uiloader:seekNodeByName(self.ScoreView, "Add_num")


    self.Iamgelimit=cc.uiloader:seekNodeByName(self.jsonnode, "Image_limit")

    self.Addless=cc.uiloader:seekNodeByName(self.Iamgelimit, "Add_less")
    self.Addmax=cc.uiloader:seekNodeByName(self.Iamgelimit, "Add_max")

    --规则按钮
    self.ButtonRule=cc.uiloader:seekNodeByName(self.jsonnode,"Button_Rule")
    self.Ruleex=cc.uiloader:seekNodeByName(self.jsonnode, "Panel_rule")
    self.RuleView=cc.uiloader:seekNodeByName(self.Ruleex, "rule_bk")
    self.Ruleex:hide()

    --操作界面
    self.MyOperationView=cc.uiloader:seekNodeByName(self.jsonnode, "my_operation")
    --操作字体
    self.MyOper_gz=cc.uiloader:seekNodeByName(self.MyOperationView, "Image_gz")
    self.MyOper_jz=cc.uiloader:seekNodeByName(self.MyOperationView, "Image_jz")
    self.MyOper_sh=cc.uiloader:seekNodeByName(self.MyOperationView, "Image_sh")
    self.MyOper_fq=cc.uiloader:seekNodeByName(self.MyOperationView, "Image_fq")
    self.MyOper_gp=cc.uiloader:seekNodeByName(self.MyOperationView, "Image_gp")

    self.MyOperationView:hide()

    self.MyOperationView:zorder(110)

    self.MyOperPosX=self.MyOperationView:getPositionX()

    --操作界面
    self.OppoOperationView=cc.uiloader:seekNodeByName(self.jsonnode, "oppo_operation")
    --操作字体
    self.OppoOper_gz=cc.uiloader:seekNodeByName(self.OppoOperationView, "Image_gz")
    self.OppoOper_jz=cc.uiloader:seekNodeByName(self.OppoOperationView, "Image_jz")
    self.OppoOper_sh=cc.uiloader:seekNodeByName(self.OppoOperationView, "Image_sh")
    self.OppoOper_fq=cc.uiloader:seekNodeByName(self.OppoOperationView, "Image_fq")
    self.OppoOper_gp=cc.uiloader:seekNodeByName(self.OppoOperationView, "Image_gp")

    self.OppoOperationView:hide()

    self.OppoOperationView:zorder(110)

    self.OppoOperPosX=self.OppoOperationView:getPositionX()


    self.m_gameAni=GameAnimation.new()
    self.m_gameAni:addTo(self)
    self.m_gameAni:zorder(300)

    self.CardeventHandles = self.ClientKernel:addEventListenersByTable( eventListeners )

    local eventListeners = eventListeners or {}
    --eventListeners[self.m_HandCardControl.Event.HINT_CARD] = handler(self, self.OnHintHandCard)
    eventListeners[self.m_Player.Event.CLOCK_END] = handler(self, self.OnUserClockEnd)

    self.CardeventHandles = self.ClientKernel:addEventListenersByTable( eventListeners )
     --加载牌的资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Common/AnimationCard.ExportJson")

    require("plazacenter.widgets.GameHornMsgWidget").new(self)
end

function ShowHandScene:InitHandCardControl()
    --手牌
    for i=1,ShowHandDefine.GAME_PLAYER do
        self.m_HandCardControl[i]=HandCardControl.new()
        self.m_HandCardControl[i]:SetStartPos(self.HeapPos)
        self.m_HandCardControl[i]:SetDistance(self.handCardDistance[i])
        --self.m_HandCardControl[i]:SetDistance(22)
        self.m_HandCardControl[i]:SetScal(self.handCardScal[i])
        self.m_HandCardControl[i]:addTo(self.jsonnode)
        self.m_HandCardControl[i]:zorder(100)
        self.m_HandCardControl[i]:SetShow(false)
        self.m_HandCardControl[i]:SetCardTouchEnabled(false)
    end

end

--初始化数据
function ShowHandScene:FreeAllData()

    self.isMovePoker = false
    self.cbFundusCard=0
    self.m_wCurrentUser=0
    self.m_lTurnMaxGold=0
    self.m_lTurnBasicGold=0
    self.m_lBasicGold=0
    self.m_lShowHandScore=0            --限制最高分
    self.m_bShowHand=false
    self.m_wCurrentCardCount=0
    self.m_silderscore=0
    self.m_Addscorenum={}
    self.m_lUserScore={}
    self.allJettonList = {}
    self.busergiveup=false
    self.sliderminscore=0.0000
    self.AddSlider_fg.minHeight=0

    self.handCardPos=
        {
           cc.p(display.cx-100,150),--1号位置 对家
            cc.p(display.cx-100,display.height - 160),--4号位置 对家
        }

    self.m_handCardData={}
    self.wViewChairID={}
    for i=1,ShowHandDefine.GAME_PLAYER do
       self.m_HandCardControl[i]:FreeControl()
    end

end

--返回大厅
function ShowHandScene:OnReturnRoom()
    self:CloseGame()
end

--继续游戏
function ShowHandScene:OnContinueGame()
    
end
--继续游戏
function ShowHandScene:OnGameEndViewClose(evt)
    print("显示结束ssssssssssss--------------------")
    
end

--场景进入
function ShowHandScene:onEnter()
	print("场景进入")
    --SoundManager:playMusicBackground("errenland/audio/BACK_MUSIC.mp3", true)
end

--场景销毁
function ShowHandScene:onExit()
	print("场景退出")
    --SoundManager:pauseMusicBackground()
end

--场景销毁
function ShowHandScene:onCleanup()
    print("场景销毁") 

    self.ClientKernel:removeListenersByTable(self.GameeventHandles)
    self.ClientKernel:removeListenersByTable(self.CardeventHandles)

    display.removeSpriteFramesWithFile("showhandanex/UIShowHandanex.plist","showhandanex/UIShowHandanex.png")
    display.removeSpriteFrameByImageName("showhandanex/u_game_table.jpg")

	self.m_GameKernel:OnFreeInterface()
    self.ClientKernel:cleanup() 
end

--事件管理
function ShowHandScene:RegistEventManager()  
    
    --游戏类操作消息
    local eventListeners = eventListeners or {}
    eventListeners[ShowHandDefine.GAME_SCENCE] = handler(self, self.OnGameScenceMsg)

    eventListeners[ShowHandDefine.GAME_START] = handler(self, self.OnSubGameStart)
    eventListeners[ShowHandDefine.GAME_ADD_SCORE] = handler(self, self.OnSubAddScore)
    eventListeners[ShowHandDefine.GAME_GIVE_UP] = handler(self, self.OnSubGiveUp)
    eventListeners[ShowHandDefine.GAME_SEND_CARD] = handler(self, self.OnSubSendCard)
    eventListeners[ShowHandDefine.GAME_OVER] = handler(self, self.OnSubGameEnd)
   
        -- body
    self.GameeventHandles = self.ClientKernel:addEventListenersByTable( eventListeners )

    self.Ruleex:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)  
        if event.name == "began" then  
            self.Ruleex:hide()  
            return true   
          
        elseif event.name == "moved" then  
            self.Ruleex:hide()  
        elseif event.name == "ended" then  
            self.Ruleex:hide()  
            -- 点击回调函数  
            return true  
        end  
        return false  
  
    end)
end

--发牌完成
function ShowHandScene:OnDisPatchCardFinish()
    print("发牌完成")
    for index=1,ShowHandDefine.GAME_PLAYER do
        for i=2,ShowHandDefine.DISPATCH_COUNT do
            self.m_HandCardControl[index]:SetShowEx(i,true)
            if index == ShowHandDefine.MYSELF_VIEW_ID then
                self.m_HandCardControl[index]:SetCardTouchEnabled(true)
            end
        end
    end
    --print("mechairid ==== "..self.m_GameKernel:GetMeChairID())
    --print("self.m_wCurrentUser ==== "..self.m_wCurrentUser)
    if self.m_wCurrentUser ==  self.m_GameKernel:GetMeChairID() then
        print("首下注---自己")
        if self.HandCardCount[ShowHandDefine.MYSELF_VIEW_ID] >= 3 then
            self.ButtonShowHand:setButtonEnabled(true)
        else
            self.ButtonShowHand:setButtonEnabled(false)
        end
        self.AddView:show()
        --print("self.m_Player:GetGold(ShowHandDefine.MYSELF_VIEW_ID+1) == "..self.m_Player:GetGold(ShowHandDefine.MYSELF_VIEW_ID+1))
            if self.m_Player:GetGold(ShowHandDefine.MYSELF_VIEW_ID+1) > 0 then
                self.ButtonPass:hide()
                self.ButtonFollow:show()
            else
                self.ButtonPass:show()
                self.ButtonFollow:hide()
            end
        self.m_Player:SetUserClock(ShowHandDefine.MYSELF_VIEW_ID, 20, ShowHandDefine.IDI_GIVE_UP)
    else
        self.m_Player:SetUserClock(ShowHandDefine.MYSELF_VIEW_ID+1, 20, ShowHandDefine.IDI_GIVE_UP)
    end

    if self.HandCardCount[ShowHandDefine.MYSELF_VIEW_ID] == 3 then
        local posxm = self.MyOperationView:getPositionX()
        local posxo = self.OppoOperationView:getPositionX()
        self.MyOperationView:setPositionX(posxm+15)
        self.OppoOperationView:setPositionX(posxo+15)
    elseif self.HandCardCount[ShowHandDefine.MYSELF_VIEW_ID] == 4 then
        local posxm = self.MyOperationView:getPositionX()
        local posxo = self.OppoOperationView:getPositionX()
        self.MyOperationView:setPositionX(posxm+15)
        self.OppoOperationView:setPositionX(posxo+15)
    end
end

--游戏开始
function ShowHandScene:OnSubGameStart(evt)
    --dump(evt)

    self.HandCardCount={0,0}
    self.m_handCardData={}

    local GameStartDB=evt.para 

    self.m_wCurrentUser=GameStartDB.wCurrentUser
    self.m_lTurnMaxGold=GameStartDB.lTurnMaxGold
    self.m_lTurnBasicGold=GameStartDB.lTurnBasicGold
    self.m_lBasicGold=GameStartDB.lBasicGold
    self.m_lShowHandScore=GameStartDB.lShowHandScore

    self.m_Player:SetBasicGold(self.m_lTurnBasicGold)

    self.Addless:setString("底注:"..self.m_lBasicGold)
    self.Addmax:setString("上限:"..self.m_lShowHandScore)

    self.cbFundusCard=GameStartDB.bFundusCard
    --local carddata = GameStartDB.bCardData
    self:SetJetton(self.m_lBasicGold)
    for i=0,ShowHandDefine.GAME_PLAYER-1 do
        --local viewid = self.m_GameKernel:SwitchViewChairID(i)+1
        if i==self.m_GameKernel:GetMeChairID() then
            self.m_Player:SetGold(ShowHandDefine.MYSELF_VIEW_ID, 0)
            self.m_Player:SetTableGold(ShowHandDefine.MYSELF_VIEW_ID, self.m_lBasicGold)
            self.m_Player:SetAddViewShow(ShowHandDefine.MYSELF_VIEW_ID,false)
        else
            self.m_Player:SetGold(ShowHandDefine.MYSELF_VIEW_ID+1, 0)
            self.m_Player:SetTableGold(ShowHandDefine.MYSELF_VIEW_ID+1, self.m_lBasicGold)
            self.m_Player:SetAddViewShow(ShowHandDefine.MYSELF_VIEW_ID+1,false)
        end
    end

    for i=1,ShowHandDefine.GAME_PLAYER do
        self:SetUserAddScoreUser(i,self.m_Player:GetTableGold(i),Addpos[i].x,Addpos[i].y)
    end

    self.m_Player:SetTableTotalScore()

    for index=1,2 do
        for i=1,2 do
            --local wViewChairID = self.m_GameKernel:SwitchViewChairID(i-1)
            if self.m_GameKernel:GetMeChairID() == i-1 then
                self.m_handCardData[i]={self.cbFundusCard,GameStartDB.bCardData[i]}
                self.HandCardCount[i]=self.HandCardCount[i]+1
            else
                self.HandCardCount[i]=self.HandCardCount[i]+1
                self.m_handCardData[i]={1,GameStartDB.bCardData[i]}
            end
        end
    end

    self:StartDisPachCards(1,1,2)

    self.btnChangeDesk:hide()

    SoundManager:playMusicEffect("showhandanex/audio/GAME_START.mp3", false, false)

end

function ShowHandScene:dispatchUserCard(wChairID,cbCardData)
    local ViewChair = self.m_GameKernel:SwitchViewChairID(wChairID) + 1
    --print("ViewChair==================="..ViewChair)
    local poker = self.m_HandCardControl[ViewChair]:AddOneCard(cbCardData)
    --self.handCardControl[wChairID]:SetCardTouchEnabled(false)
    self.pokerCount = self.pokerCount + 1
    return poker
end

function ShowHandScene:StartDisPachCards(startid,startcard,cardcount)
    print("开始发牌")
    local index = 0
    for w = startid, startid + ShowHandDefine.GAME_PLAYER-1 do
        local j=w%ShowHandDefine.GAME_PLAYER +1
        --print("cardcount===================="..cardcount)
        local poker
        for i=startcard, cardcount do
            --print("i================ "..i)
            if self.m_handCardData[j][i] ~= 0 then
                --print("self.m_handCardData[j][i]"..self.m_handCardData[j][i],"w=="..w)
                poker = self:dispatchUserCard(j,self.m_handCardData[j][i])
            end
            local DelyTime
            --if self.isMovePoker then
                DelyTime =0.05*index
            --else
            --    DelyTime = 0
            --end
            local viewchair = self.m_GameKernel:SwitchViewChairID(j) + 1
            local posStart = self.HeapPos
            local posEnd = self.handCardPos[viewchair]
            posEnd.x= posEnd.x + self.handCardDistance[viewchair]
            --dump(posEnd,"ccyend=========================")
            --决定牌大小
            local Scale=self.handCardScal[viewchair]
            local args=
                {
                    startPos=posStart , --起始位置
                    endPos =posEnd,     --结束位置
                    delay=DelyTime,
              --      isMoveTo=self.isMovePoker,
                    scal=Scale,
                    moveEndHandler= handler(self,self.DisPatchOneCardEnd),--结束回调处理
                }
            poker:doCardAnimation(args)
            index = index + 1
        end
    end

    SoundManager:playMusicEffect("showhandanex/audio/SEND_CARD.mp3", false, false)
end

function ShowHandScene:DisPatchOneCardEnd()
    --oxui.playSound("SEND_CARD",false,OxBattleDefine.wav)
    self.pokerCount = self.pokerCount - 1
    --print("self.pokerCount = " .. self.pokerCount)
    if self.pokerCount == 0 then
        self:OnDisPatchCardFinish()
    end
end

function ShowHandScene:SetJetton(basicgold)
    local goldstr = nil
    self.m_Addscorenum={}
    local gold = basicgold
    --print("gold========="..gold)
    if gold >= 100 and gold <= 1000 then
        self.ButtonAdd_One_text:setString("100")
        self.ButtonAdd_Two_text:setString("500")
        self.ButtonAdd_Three_text:setString("1000")
        self.m_Addscorenum[1]=100
        self.m_Addscorenum[2]=500
        self.m_Addscorenum[3]=1000
    elseif gold > 1000 and gold <= 10000 then
        self.ButtonAdd_One_text:setString("1000")
        self.ButtonAdd_Two_text:setString("5000")
        goldstr = string.format("%d万", 1)
        self.ButtonAdd_Three_text:setString(goldstr)
        self.m_Addscorenum[1]=1000
        self.m_Addscorenum[2]=5000
        self.m_Addscorenum[3]=10000
    else
        goldstr = string.format("%d万", 10)
        self.ButtonAdd_One_text:setString(goldstr)
        goldstr = string.format("%d万", 50)
        self.ButtonAdd_Two_text:setString(goldstr)
        goldstr = string.format("%d万", 100)
        self.ButtonAdd_Three_text:setString(goldstr)
        self.m_Addscorenum[1]=100000
        self.m_Addscorenum[2]=500000
        self.m_Addscorenum[3]=1000000
    end
end

--用户加注
function ShowHandScene:OnSubAddScore(evt)
    print("用户加注")
    --dump(evt)

    self.m_Player:KillUserClock()

    local GameAddDB=evt.para

    self.m_wCurrentUser=GameAddDB.wCurrentUser
    self.m_lTurnBasicGold=GameAddDB.lCurrentLessGold
    self.m_bShowHand=GameAddDB.bShowHand

    self.m_Player:SetBasicGold(self.m_lTurnBasicGold)

    local lastchair = GameAddDB.wLastChairID
    local addscore = GameAddDB.lLastAddGold
    local viewid = self.m_GameKernel:SwitchViewChairID(lastchair) + 1
    local bsh = false

    if addscore == self.m_Player:GetShowHandScore(ShowHandDefine.MYSELF_VIEW_ID,self.m_lShowHandScore) then
        print("加注梭哈---------OnSubAddScore")
        self.m_gameAni:DoAllinAni()
        bsh=true

        SoundManager:playMusicEffect("showhandanex/audio/SHOW_HAND.mp3", false, false)
    end

    if self.m_GameKernel:GetMeChairID() == lastchair then
        self:SetMyOperationShow(addscore,bsh,true)
    else
        self:SetOppoOperationShow(addscore,bsh,true)
    end

    if addscore>0 then
        --print("用户加注座位 ==  "..lastchair)
        --print("我的位置 == "..self.m_GameKernel:GetMeChairID())
        if lastchair == self.m_GameKernel:GetMeChairID() then
            self.m_Player:SetGold(ShowHandDefine.MYSELF_VIEW_ID,addscore)
            self.m_Player:SetAddViewShow(ShowHandDefine.MYSELF_VIEW_ID,true)
        else
            self.m_Player:SetGold(ShowHandDefine.MYSELF_VIEW_ID+1, addscore)
            self.m_Player:SetAddViewShow(ShowHandDefine.MYSELF_VIEW_ID+1,true)
        end
    else
        self.m_Player:SetAddViewShow(ShowHandDefine.MYSELF_VIEW_ID,false)
        self.m_Player:SetAddViewShow(ShowHandDefine.MYSELF_VIEW_ID+1,false)
    end

    if self.m_wCurrentUser == self.m_GameKernel:GetMeChairID() then
        --print("OnSubAddScore======me")
        if self.HandCardCount[ShowHandDefine.MYSELF_VIEW_ID] >= 3 then
            self.ButtonShowHand:setButtonEnabled(true)
        else
            self.ButtonShowHand:setButtonEnabled(false)
        end
        if addscore > 0 then
            self.ButtonPass:hide()
            self.ButtonFollow:show()
        else
            self.ButtonPass:show()
            self.ButtonFollow:hide()
        end
        self.AddView:show()
        self.m_Player:SetUserClock(ShowHandDefine.MYSELF_VIEW_ID, 20, ShowHandDefine.IDI_GIVE_UP)
    else
        self.m_Player:SetUserClock(ShowHandDefine.MYSELF_VIEW_ID+1, 20, ShowHandDefine.IDI_GIVE_UP)
    end

    if self.m_GameKernel:GetMeChairID() == lastchair then
        --print("Addpos[1].x"..Addpos[1].x,"Addpos[1].y"..Addpos[1].y)
        self:SetUserAddScoreUser(1,GameAddDB.lLastAddGold,Addpos[1].x,Addpos[1].y)
    else
        --print("Addpos[2].x"..Addpos[2].x,"Addpos[2].y"..Addpos[2].y)
        self:SetUserAddScoreUser(1,GameAddDB.lLastAddGold,Addpos[2].x,Addpos[2].y)
    end

    if bsh == false and  addscore > 0 then
        SoundManager:playMusicEffect("showhandanex/audio/ADD_SCORE.mp3", false, false)
    elseif addscore == 0 then
        SoundManager:playMusicEffect("showhandanex/audio/NO_ADD.mp3", false, false)
    end
end

--用户放弃
function ShowHandScene:OnSubGiveUp(evt)
    print("用户放弃")
    --dump(evt)
    
    self.m_Player:KillUserClock()
    local GameGiveUpDB=evt.para

    --print("GameGiveUpDB.wUserChairID ===== "..GameGiveUpDB.wUserChairID)
    --print("self.m_GameKernel:GetMeChairID() ===== "..self.m_GameKernel:GetMeChairID())
    local  chairid = GameGiveUpDB.wUserChairID
    if chairid == self.m_GameKernel:GetMeChairID() then
        self.m_HandCardControl[ShowHandDefine.MYSELF_VIEW_ID]:SetShow(false)
        self:SetMyOperationShow(-1,false,true)
    else
        self:SetOppoOperationShow(-1,false,true)
        self.m_HandCardControl[ShowHandDefine.MYSELF_VIEW_ID+1]:SetShow(false)
    end

    self.busergiveup=true

    SoundManager:playMusicEffect("showhandanex/audio/GIVE_UP.mp3", false, false)
end

--发牌消息
function ShowHandScene:OnSubSendCard(evt)
    print("发牌消息")
    --dump(evt)

    self.m_Player:KillUserClock()

    local GameSendCardDB=evt.para
    self.m_lTurnMaxGold=GameSendCardDB.lMaxGold
    self.m_wCurrentUser=GameSendCardDB.wCurrentUser

    self:SetMyOperationShow(0,false,false)
    self:SetOppoOperationShow(0,false,false)

    self.m_lTurnBasicGold=0

    local lusertotalgold=0
    for i=0,ShowHandDefine.GAME_PLAYER-1 do
        --if i==self.m_GameKernel:GetMeChairID() then
            lusertotalgold=self.m_Player:GetGold(i+1)
            lusertotalgold=lusertotalgold+self.m_Player:GetTableGold(i+1)
            self.m_Player:SetGold(i+1, 0)
            self.m_Player:SetAddViewShow(i+1,false)
            self.m_Player:SetTableGold(i+1, lusertotalgold)
        --end
    end

    self.m_Player:SetTableTotalScore()

--dump(self.HandCardCount,"self.HandCardCount====================================")
    for user=1,ShowHandDefine.GAME_PLAYER do
        local wMeChairID=self.m_GameKernel:GetMeChairID()
        local wOtChairID=(wMeChairID+1)%ShowHandDefine.GAME_PLAYER
        --print("wMeChairID ==== "..wMeChairID)
        --print("wOtChairID ==== "..wOtChairID)
        for i=1,GameSendCardDB.cbSendCardCount do
            local k=i
            if user==2 then
                k=i+2
            end
            if GameSendCardDB.bUserCard[i]~=0 and wMeChairID == user-1 then
                self.HandCardCount[wMeChairID+1]=self.HandCardCount[wMeChairID+1]+1
                self.m_handCardData[wMeChairID+1][self.HandCardCount[wMeChairID+1]]=GameSendCardDB.bUserCard[k]
            elseif GameSendCardDB.bUserCard[i]~=0 and wMeChairID ~= user-1 then
                self.HandCardCount[wOtChairID+1]=self.HandCardCount[wOtChairID+1]+1
                self.m_handCardData[wOtChairID+1][self.HandCardCount[wOtChairID+1]]=GameSendCardDB.bUserCard[k]
            end
        end
    end
--dump(self.m_handCardData)  
    if GameSendCardDB.cbSendCardCount == 2 then
        self:StartDisPachCards(GameSendCardDB.wStartChairId,self.HandCardCount[1]-1,GameSendCardDB.cbSendCardCount+self.HandCardCount[1]-2)
    else
        self:StartDisPachCards(GameSendCardDB.wStartChairId,self.HandCardCount[1],GameSendCardDB.cbSendCardCount+self.HandCardCount[1]-1)
    end
    
    
end

--游戏结束
function ShowHandScene:OnSubGameEnd(evt)
    print("游戏结束")
    --dump(evt)

    self.m_Player:KillUserClock()

    for i=1,ShowHandDefine.GAME_PLAYER do
        self.m_HandCardControl[i]:SetCardTouchEnabled(false)
    end

    local GameEndDB=evt.para

    self.m_Player:SetAddViewShow(ShowHandDefine.MYSELF_VIEW_ID,false)
    self.m_Player:SetAddViewShow(ShowHandDefine.MYSELF_VIEW_ID+1,false)

    local wMeChairid = self.m_GameKernel:GetMeChairID()
    for i=0,ShowHandDefine.GAME_PLAYER-1 do
        if GameEndDB.bUserCard[i+1]~=0 and self.busergiveup==false then
            --local wViewChairID = self.m_GameKernel:SwitchViewChairID(i-1)
            if wMeChairid == i then
                --self.m_handCardData[i][1]=GameEndDB.bUserCard[i]
                self.m_HandCardControl[ShowHandDefine.MYSELF_VIEW_ID]:SetShowEx(1, true)
            else
                --print("cccccccccccccccccself.m_handCardData[i+1][1]=="..self.m_handCardData[i+1][1])
                --print("xxxxxxxxxxxxxxxxxGameEndDB.bUserCard[i+1]=="..GameEndDB.bUserCard[i+1])
                self.m_HandCardControl[ShowHandDefine.MYSELF_VIEW_ID+1]:OnChangeCard(self.m_handCardData[i+1][1],GameEndDB.bUserCard[i+1])
                self.m_handCardData[i+1][1]=GameEndDB.bUserCard[i+1]
                self.m_HandCardControl[ShowHandDefine.MYSELF_VIEW_ID+1]:SetShowEx(1, true)

            end
        end
    end

    local Gameendscore = GameEndDB.lGameGold
    for i=0,ShowHandDefine.GAME_PLAYER-1 do
            if Gameendscore[i+1] > 0 then
                if i==self.m_GameKernel:GetMeChairID() then
                    self:moveJettons(ShowHandDefine.MYSELF_VIEW_ID)

                    SoundManager:playMusicEffect("showhandanex/audio/GAME_WIN.mp3", false, false)
                else
                    self:moveJettons(ShowHandDefine.MYSELF_VIEW_ID+1)

                    SoundManager:playMusicEffect("showhandanex/audio/GAME_LOST.mp3", false, false)
                end
        end
    end

    self:SetMyOperationShow(0,false,false)
    self:SetOppoOperationShow(0,false,false)

    self.MyOperationView:setPositionX(self.MyOperPosX)
    self.OppoOperationView:setPositionX(self.OppoOperPosX)


    self.Addless:setString("底注:"..self.m_lBasicGold)
    self.Addmax:setString("上限:"..self.m_lShowHandScore)

    self:UpdateAddView(false)
    self.ButtonStart:show()
    self.m_Player:SetUserClock(ShowHandDefine.MYSELF_VIEW_ID, 15, ShowHandDefine.IDI_START_GAME)

    self.btnChangeDesk:show()
end
---------------[[以下是接收游戏服务端场景消息处理]]--------------
--场景
function ShowHandScene:OnGameScenceMsg(evt)
    local  statusInfo = {}
    local unResolvedData = evt.para.unResolvedData

    --等待开始
    if self.ClientKernel.cbGameStatus==ShowHandDefine.GAME_STATUS_FREE then
        print("空闲状态")
        local pStatusFree = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusFree")

        self:FreeAllData()

        self.m_lBasicGold = pStatusFree.dwBasicGold

        self.ButtonStart:show()

        for i=1,ShowHandDefine.GAME_PLAYER do
            self.m_Player:SetTableGold(i, 0)
        end

        self.Addless:setString("底注:"..self.m_lBasicGold)
        self.Addmax:setString("上限:"..self.m_lShowHandScore)

        self.m_Player:SetUserClock(ShowHandDefine.MYSELF_VIEW_ID, 15, ShowHandDefine.IDI_START_GAME)
    end

    if self.ClientKernel.cbGameStatus==ShowHandDefine.GAME_STATUS_PLAY then
        print("游戏状态")

        local statusPlay = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusPlay")
        dump(statusPlay)
        self.btnChangeDesk:hide()
        self.m_lTurnMaxGold = statusPlay.lTurnMaxGold
        self.m_lTurnBasicGold = statusPlay.lTurnBasicGold
        self.m_lBasicGold = statusPlay.lBasicGold
        self.m_wCurrentUser = statusPlay.wCurrentUser
        self.m_lShowHandScore = statusPlay.lShowHandScore
        self.m_bShowHand = statusPlay.bShowHand

        local lTableGold = statusPlay.lTableGold

        self.HandCardcount = statusPlay.bTableCardCount

        self.ButtonStart:hide()

        local wMechairid = self.m_GameKernel:GetMeChairID()

        local cardcount = 1
        local goldindex=1
        for i=0,ShowHandDefine.GAME_PLAYER-1 do
            if i==1 then
                goldindex=3
            end
            if wMechairid == i then
                --print("goldindex == "..goldindex,"lTableGold[goldindex+1] == "..lTableGold[goldindex])
                self.m_Player:SetGold(ShowHandDefine.MYSELF_VIEW_ID,lTableGold[goldindex])
                if lTableGold[goldindex] > 0 then
                    self.m_Player:SetAddViewShow(ShowHandDefine.MYSELF_VIEW_ID,true)
                end
                self.m_Player:SetTableGold(ShowHandDefine.MYSELF_VIEW_ID,lTableGold[goldindex+1])

            else
                --print("goldindex == "..goldindex,"lTableGold[goldindex+2] == "..lTableGold[goldindex])
                self.m_Player:SetGold(ShowHandDefine.MYSELF_VIEW_ID+1,lTableGold[goldindex])
                if lTableGold[goldindex] > 0 then
                    self.m_Player:SetAddViewShow(ShowHandDefine.MYSELF_VIEW_ID+1,true)
                end
                self.m_Player:SetTableGold(ShowHandDefine.MYSELF_VIEW_ID+1,lTableGold[goldindex+1])
            end
        end

        local cardindex = 1
        local mycdata = {}
        local oppocard = {}
        for i=1,ShowHandDefine.GAME_PLAYER do
            for j=1, 5 do
                --print("statusPlay.bTableCardArray[cardindex] == "..statusPlay.bTableCardArray[cardindex])
                if wMechairid == i-1 then
                    if statusPlay.bTableCardArray[cardindex] ~= 0 then
                        --print("i == "..i,"j == "..j,"cardindex == "..cardindex)
                        mycdata[j] = statusPlay.bTableCardArray[cardindex]
                    end
                else
                    --print("i == "..i,"j == "..j,"cardindex == "..cardindex,"aaa")
                    if statusPlay.bTableCardArray[cardindex] == 0 and (cardindex==1 or cardindex==6) then
                        oppocard[j] = 1
                    elseif statusPlay.bTableCardArray[j] ~= 0 then
                        oppocard[j] = statusPlay.bTableCardArray[cardindex]
                    end
                end
                cardindex=cardindex+1
            end
        end

        for i=1,ShowHandDefine.GAME_PLAYER do
            if wMechairid == i-1 then
                self.m_handCardData[i] = mycdata
            else
                self.m_handCardData[i] = oppocard
            end
        end
        --dump(self.m_handCardData[1],"self.m_handCardData[1]=====================")
        --dump(self.m_handCardData[2],"self.m_handCardData[2]====================")

        --print("statusPlay.bTableCardCount[1]"..statusPlay.bTableCardCount[1])
        self:StartDisPachCards(1,1,self.HandCardcount[1])

        self.m_Player:SetTableTotalScore()
        self.Addless:setString("底注:"..self.m_lBasicGold)
        self.Addmax:setString("上限:"..statusPlay.lShowHandScore)
        --print("self.m_wCurrentCardCount == "..self.m_wCurrentCardCount,"wMechairid == "..wMechairid)
        if self.m_wCurrentCardCount == wMechairid then
            self.AddView:show()

            self.m_Player:SetUserClock(ShowHandDefine.MYSELF_VIEW_ID, 10, ShowHandDefine.IDI_GIVE_UP)
        end
    end
    
end

--控件消息
function ShowHandScene:ButtonMsg()

    --dump(self.ButtonExit)
   self.ButtonStart:onButtonClicked(function () self:BtStartGame() end)--开始按钮事件
   self.ButtonExit:onButtonClicked(function () self:CloseGame() end)--离开按钮事件
   self.ButtonRule:onButtonClicked(function () self:BtGameRule() end)--游戏规则
   self.ButtonGiveUp:onButtonClicked(function () self:BtGameGiveUp() end)--游戏放弃
   self.ButtonShowHand:onButtonClicked(function () self:BtGameShowHand() end)
   self.ButtonFollow:onButtonClicked(function () self:BtGameFollow() end)
   self.ButtonPass:onButtonClicked(function () self:BtGamePass() end)
   self.ButtonAdd:onButtonClicked(function () self:BtGameAdd() end)
   self.ButtonSure:onButtonClicked(function () self:BtGameSure() end)
   self.ButtonAdd_One:onButtonClicked(function () self:BtGameAddOne() end)
   self.ButtonAdd_Two:onButtonClicked(function () self:BtGameAddTow() end)
   self.ButtonAdd_Three:onButtonClicked(function () self:BtGameAddThree() end)
   self.btnChangeDesk:onButtonClicked(function () self:BtGameChangeDesk() end)
   self.btnSetting:onButtonClicked(function () self:BtGameSetting() end)

   self.ButtonStart:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonStart)end)--开始按钮按下
   self.ButtonExit:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonExit)end)--离开按钮按下
   self.ButtonRule:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonRule)end)
   self.ButtonGiveUp:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonGiveUp)end)
   self.ButtonShowHand:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonShowHand)end)
   self.ButtonFollow:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonFollow)end)
   self.ButtonPass:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonPass)end)
   self.ButtonAdd:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonAdd)end)
   self.ButtonSure:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonSure)end)
   self.ButtonAdd_One:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonAdd_One)end)
   self.ButtonAdd_Two:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonAdd_Two)end)
   self.ButtonAdd_Three:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonAdd_Three)end)
   self.btnSetting:onButtonPressed(function ()self:playScaleAnimation(true,self.btnSetting)end)


   self.ButtonStart:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonStart)end)--开始按钮抬起
   self.ButtonExit:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonExit)end)--离开按钮抬起
   self.ButtonRule:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonRule)end)
   self.ButtonGiveUp:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonGiveUp)end)
   self.ButtonShowHand:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonShowHand)end)
   self.ButtonFollow:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonFollow)end)
   self.ButtonPass:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonPass)end)
   self.ButtonAdd:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonAdd)end)
   self.ButtonSure:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonSure)end)
   self.ButtonAdd_One:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonAdd_One)end)
   self.ButtonAdd_Two:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonAdd_Two)end)
   self.ButtonAdd_Three:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonAdd_Three)end)
   self.btnSetting:onButtonRelease(function ()self:playScaleAnimation(false,self.btnSetting)end)

end

--开始按钮
function ShowHandScene:BtStartGame()
    self:FreeAllData()
    self.m_GameKernel:StartGame()
    self.ButtonStart:hide()
    self.m_Player:KillUserClock()

    for i=1,ShowHandDefine.GAME_PLAYER do
        self.m_Player:SetTableGold(i, 0)
    end

    self.m_Player:SetTableTotalScore()


end

function ShowHandScene:BtGameGiveUp()
    print("放弃")

    self.m_Player:KillUserClock()
    self:UpdateAddView(false)
    self.ButtonAdd:show()
    self.ButtonSure:hide()

    self:send(ShowHandDefine.SUB_C_GIVE_UP)
end

function ShowHandScene:BtGameShowHand()
    print("梭哈")

    self.m_Player:KillUserClock()
    self:UpdateAddView(false)
    self.ButtonAdd:show()
    self.ButtonSure:hide()

    local showhandsocre = self.m_Player:GetShowHandScore(ShowHandDefine.MYSELF_VIEW_ID,self.m_lShowHandScore)
    --print("showhandscore === "..showhandsocre)

    self.m_Player:SetGold(ShowHandDefine.MYSELF_VIEW_ID, showhandsocre)

    CMD_C_AddGold.lGold=showhandsocre
    self:send(ShowHandDefine.SUB_C_ADD_GOLD,CMD_C_AddGold,"CMD_C_AddGold")
end

function ShowHandScene:BtGameFollow()
    print("跟注")

    self.m_Player:KillUserClock()
    self:UpdateAddView(false)
    self.ButtonAdd:show()
    self.ButtonSure:hide()

    self.sliderminscore=0

    local followsocre = self.m_Player:GetFollowScore(ShowHandDefine.MYSELF_VIEW_ID+1,self.m_lShowHandScore)

    --print("followsocre === "..followsocre)
    self.m_Player:SetGold(ShowHandDefine.MYSELF_VIEW_ID, followsocre)

    CMD_C_AddGold.lGold=followsocre
    self:send(ShowHandDefine.SUB_C_ADD_GOLD,CMD_C_AddGold,"CMD_C_AddGold")

end

function ShowHandScene:BtGamePass()
    print("过牌")

    self.m_Player:KillUserClock()
    self:UpdateAddView(false)
    self.ButtonAdd:show()
    self.ButtonSure:hide()

    local followsocre = self.m_Player:GetFollowScore(ShowHandDefine.MYSELF_VIEW_ID,self.m_lShowHandScore)

    --print("followsocre === "..followsocre)
    self.m_Player:SetGold(ShowHandDefine.MYSELF_VIEW_ID, followsocre)

    CMD_C_AddGold.lGold=followsocre
    self:send(ShowHandDefine.SUB_C_ADD_GOLD,CMD_C_AddGold,"CMD_C_AddGold")

end

function ShowHandScene:BtGameAdd()
    print("加注")

    self.ScoreView:show()
    self.ButtonAdd:hide()
    self.ButtonSure:show()

    local maxscore = self.m_lShowHandScore
    if self.HandCardCount[ShowHandDefine.MYSELF_VIEW_ID] == 2 then
        maxscore = self.m_lTurnMaxGold
    end
    local shgold = self.m_Player:GetShowHandScore(ShowHandDefine.MYSELF_VIEW_ID, maxscore)
    local addscore = self.m_Player:GetGold(ShowHandDefine.MYSELF_VIEW_ID+1)
    local value = self.m_lBasicGold/maxscore
    self.m_silderscore = self.m_lBasicGold

    self.AddNum:setString(tostring(self.m_lBasicGold))
    if addscore > 0 then
        value = addscore/shgold
        self.AddNum:setString(tostring(addscore))
        self.m_silderscore = addscore
    end
    
    --print("self.m_lBasicGold == "..self.m_lBasicGold,"maxscore == "..maxscore)
    --print("value == "..value)
    --print("addscore ==== "..addscore)

    self:setSliderValue(value)

    self.AddSlider_fg.minHeight = self.AddSlider_fg:getContentSize().width
    --print("self.AddSlider_fg.minHeight == "..self.AddSlider_fg.minHeight)

end

function ShowHandScene:BtGameAddOne( ... )
    print("加注1")
    local num = 0
    local maxscore = self.m_lShowHandScore
    if self.HandCardCount[ShowHandDefine.MYSELF_VIEW_ID] == 2 then
        maxscore = self.m_lTurnMaxGold
    end
    local shscore = self.m_Player:GetShowHandScore(ShowHandDefine.MYSELF_VIEW_ID,maxscore)
            
    --local shsocre = self.m_Player:GetShowHandScore(ShowHandDefine.MYSELF_VIEW_ID, self.m_lShowHandScore)
    num = self.m_Addscorenum[1]+self.m_silderscore
    num = math.min(num,shscore)
    self.AddNum:setString(tostring(num))

    local value = num/shscore

    self:setSliderValue(value)

    self.m_silderscore=num
end

function ShowHandScene:BtGameAddTow( ... )
    print("加注2")
    
    local num = 0
    local maxscore = self.m_lShowHandScore
    if self.HandCardCount[ShowHandDefine.MYSELF_VIEW_ID] == 2 then
        maxscore = self.m_lTurnMaxGold
    end
    local shscore = self.m_Player:GetShowHandScore(ShowHandDefine.MYSELF_VIEW_ID,maxscore)
    num = self.m_Addscorenum[2]+self.m_silderscore
    num = math.min(num,shscore)
    self.AddNum:setString(tostring(num))

    local value = num/shscore

    self:setSliderValue(value)

    self.m_silderscore=num
end

function ShowHandScene:BtGameAddThree( ... )
    print("加注3")

    local num = 0
    local maxscore = self.m_lShowHandScore
    if self.HandCardCount[ShowHandDefine.MYSELF_VIEW_ID] == 2 then
        maxscore = self.m_lTurnMaxGold
    end
    local shscore = self.m_Player:GetShowHandScore(ShowHandDefine.MYSELF_VIEW_ID,maxscore)
    num = self.m_Addscorenum[3]+self.m_silderscore
    num = math.min(num,shscore)
    self.AddNum:setString(tostring(num))

    local value = num/shscore

    self:setSliderValue(value)

    self.m_silderscore=num
end


function ShowHandScene:BtGameSure()
    print("确定")

    self.m_Player:KillUserClock()
    self:UpdateAddView(false)
    self.ButtonAdd:show()
    self.ButtonSure:hide()

    self.sliderminscore=0

    CMD_C_AddGold.lGold=self.m_silderscore
    self:send(ShowHandDefine.SUB_C_ADD_GOLD,CMD_C_AddGold,"CMD_C_AddGold")
end

function ShowHandScene:BtGameChangeDesk()
    self.ClientKernel:quickChangeTable()
end

function ShowHandScene:BtGameSetting()
    local settingView = settingUI.new()
        settingView:setPosition(cc.p(display.cx,display.cy))
        self:addChild(settingView)
end

function ShowHandScene:setSliderValue(percent)
    percent = percent or 0
    local newLen = percent*self.AddSlider_fg.maxHeight
    self.AddSlider_fg:setContentSize(newLen,self.AddSlider_fg.width)
    self.AddSlider_fg:setVisible(newLen>20)
    self.AddSlider_button:setPositionX(newLen)
end

function ShowHandScene:getSliderValue()
    return self.AddSlider_fg:getContentSize().width/self.AddSlider_fg.maxHeight*100
end
function ShowHandScene:BtTouchSliderMsg(sliderBtn)
    if sliderBtn then
        sliderBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            if event.name == "began" then  
                sliderBtn.ptBegan = event.y
                self.AddSlider_fg.preLen = self.AddSlider_fg:getContentSize().width
            elseif event.name == "moved" then 
                if math.abs(event.y-sliderBtn.ptBegan) >= 1 then
                    local preLen = self.AddSlider_fg.preLen
                    local newLen = preLen + (event.y-sliderBtn.ptBegan)
                    if newLen < self.AddSlider_fg.minHeight then
                        return true
                    end
                    if newLen < 0 then
                        newLen = 0
                    elseif newLen > self.AddSlider_fg.maxHeight then
                        newLen = self.AddSlider_fg.maxHeight
                    end

                    local percent = newLen/self.AddSlider_fg.maxHeight
                    self:setSliderValue(percent)
                    local maxscore = self.m_lShowHandScore
                    if self.HandCardCount[ShowHandDefine.MYSELF_VIEW_ID] == 2 then
                        maxscore = self.m_lTurnMaxGold
                    end
                    local shscore = self.m_Player:GetShowHandScore(ShowHandDefine.MYSELF_VIEW_ID,maxscore)
            
                
                    --[[if self.m_Player:GetGold(ShowHandDefine.MYSELF_VIEW_ID+1) == 0 then
                        shscore = shscore + self.m_Player:GetTableGold(ShowHandDefine.MYSELF_VIEW_ID)
                    end]]
                    
                    self.m_silderscore = math.ceil(percent*shscore)
                    self.AddNum:setString(tostring(self.m_silderscore))
                end
            end  
            return true  
      
        end)
    end
end

function ShowHandScene:SetMyOperationShow(addscore,bshowhand,bshow)
    if bshow == true then
        self.MyOperationView:show()
        if bshowhand == true then
            self.MyOper_sh:show()
        else
            if addscore < 0 then
                self.MyOper_fq:show()
            elseif addscore > 0 then
                if self.m_Player:GetGold(ShowHandDefine.MYSELF_VIEW_ID+1) == addscore then
                    self.MyOper_gz:show()
                else
                    self.MyOper_jz:show()
                end
            elseif addscore == 0 then
                if self.m_Player:GetGold(ShowHandDefine.MYSELF_VIEW_ID+1) == 0 then
                    self.MyOper_gp:show()
                end
            end
        end
    else
        self.MyOperationView:hide()
        self.MyOper_gz:hide()
        self.MyOper_jz:hide()
        self.MyOper_sh:hide()
        self.MyOper_fq:hide()
        self.MyOper_gp:hide()
    end
end

function ShowHandScene:SetOppoOperationShow(addscore,bshowhand,bshow)
    if bshow == true then
        self.OppoOperationView:show()
        if bshowhand == true then
            self.OppoOper_sh:show()
        else
            if addscore < 0 then
                self.OppoOper_fq:show()
            elseif addscore > 0 then
                if self.m_Player:GetGold(ShowHandDefine.MYSELF_VIEW_ID) == addscore then
                    self.OppoOper_gz:show()
                else
                    self.OppoOper_jz:show()
                end
            elseif addscore == 0 then
                if self.m_Player:GetGold(ShowHandDefine.MYSELF_VIEW_ID) == 0 then
                    self.OppoOper_gp:show()
                end
            end
        end
    else
        self.OppoOperationView:hide()
        self.OppoOper_gz:hide()
        self.OppoOper_jz:hide()
        self.OppoOper_sh:hide()
        self.OppoOper_fq:hide()
        self.OppoOper_gp:hide()
    end
end

function ShowHandScene:UpdateAddView(bshow)
    if bshow==true then
        self.AddView:show()
    else
        self.AddView:hide()
        self.ScoreView:hide()
    end
end

--移动筹码
function ShowHandScene:SetUserAddScoreUser(cbJettonArea,lScoreCount,x,y)
    --创建筹码图片
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
                local img = display.newSprite("#pic/showhandanex/u_cm_" .. buttonCfg[var] .. ".png")
                img:setPosition(cc.p(x or 60,y or 90))
                img:setTag(cbJettonArea)
                img:setName("#u_cm_" .. buttonCfg[var] .. ".png")
                self.jsonnode:addChild(img,5)
                local pos = clone(cc.p(display.cx,display.cy))
                pos.x = pos.x + math.random(-200,200)
                pos.y = pos.y + math.random(-60,40)
                self:JettonMoveeff(img,pos)
                table.insert(self.allJettonList,img)
                lScoreCount = lScoreCount - buttonCfg[var]
                break
            end
        end
    end
end

function ShowHandScene:JettonMoveeff(jetton,pos,delay,callBack)
    local tt={}
    local d = cc.DelayTime:create(delay or 0)
    local move = cc.MoveTo:create(0.4,pos)
    local rota = cc.RotateBy:create(0.4,math.random(360,360*8))
    local es = cc.EaseQuarticActionOut:create(cc.Spawn:create(move,rota))
    table.insert(tt,d)
    table.insert(tt,es)
    if callBack then
        table.insert(tt,callBack)
    end
    jetton:runAction(cc.Sequence:create(tt))
end

function ShowHandScene:moveJettons(winid)
    --测试数据 
    --dump(self.lAllUserWin)  
    --self:trendChartOne(self.lAllUserWin)
    
    for key, jetton in pairs(self.allJettonList) do 
        --if self.lAllUserWin[jetton:getTag()] == true then
            local f = cc.CallFunc:create(function()
                jetton:removeFromParent()
                self.allJettonList[key] = nil
            end)
            self:JettonMoveeff(jetton,Addpos[winid],0.2,f)
        --end
    end 

end

--玩家计时器超时
function ShowHandScene:OnUserClockEnd(evnt)
    print("OnUserClockEnd")
     local OperID=evnt.OperID
     if OperID == ShowHandDefine.IDI_START_GAME then
         self:CloseGame()
     end
     if OperID == ShowHandDefine.IDI_GIVE_UP then
         self:send(ShowHandDefine.SUB_C_GIVE_UP)
     end
end

function ShowHandScene:send(type,data,name)
    self.ClientKernel:requestCommand(MDM_GF_GAME,type,data ,name)
end

--关闭游戏
function ShowHandScene:CloseGame()
    self.ClientKernel:exitGameApp()

end

function ShowHandScene:BtGameRule()
    self.Ruleex:show()
end

--定义按钮缩放动画函数
function ShowHandScene:playScaleAnimation(less, pSender)
    local  scale = less and 0.9 or 1
    pSender:runAction(cc.ScaleTo:create(0.2,scale))
end

return  ShowHandScene;