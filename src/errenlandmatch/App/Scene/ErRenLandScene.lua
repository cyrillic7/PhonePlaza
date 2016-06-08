-- ErRenLandScene 
--获取使用kernel类函数
local ClientKernel = require("common.ClientKernel")--外部公共库kernel
local GameKernel   = import("..Kernel.GameKernel")--内部公共库kernel
local Player     = import("..View.Player")--玩家管理
local HandCardControl  = import("..View.HandCardControl")--用户牌管理
local UserCardControl  = import("..View.UserCardControl")--用户牌管理
local BackCard     = import("..View.BackCard")--牌堆管理
local CardLogic    = import("..Kernel.CardLogic")--牌堆管理

local GameEndView     = import("..View.GameEndView")--结算
local GameAnimation     = import("..View.GameAnimation")--结算

local MatchWaitStartFull     = import("..matchview.waitstartFull")--等待开始
local MatchWaitnextronud     = import("..matchview.waitnextround")--等待开始
local Matcthinfo     = import("..matchview.matchinfo")--等待开始
local Matcthresultwin     = import("..matchview.matchresultwin")--等待开始
local Matcthresultlose     = import("..matchview.matchresultlost")--等待开始


--声明游戏场景类
local ErRenLandScene  = class("ErRenLandScene", function() return display.newScene("ErRenLandScene")end)

--本类的构造函数
function ErRenLandScene:ctor(args)
    self.App=AppBaseInstanse.ErRenLandApp
    self:setNodeEventEnabled(true)
    --创建gamekernel
    if args.gameClient then
        self.gameClient = args.gameClient
        self.ClientKernel = ClientKernel.new(self.gameClient,self.App.EventCenter,true) 
        --声明conmand对象
        self.m_GameKernel=GameKernel.new(self.ClientKernel);
    end
    --设置游戏属性
    local gameAttribute = 
    {
        wKindID=ErRenLandDefine.KIND_ID,
        wPlayerCount=ErRenLandDefine.GAME_PLAYER,
        dwClientVersion=ErRenLandDefine.VERSION_CLIENT,
        pszGameName=ErRenLandDefine.GAME_NAME,
    }
    self.m_GameKernel:getClientKernel():SetGameAttribute(gameAttribute)
    --扑克逻辑对象
    self.m_CardLogic=CardLogic.new()
    self:RegistEventManager() --注册事件管理
    self:InitUnits()          --加载资源
    self:FreeAllData()        --初始化数据
    self:ButtonMsg()          --控件消息
    
    --计时器
    self:schedule(handler(self,self.schedulerFunction), 1.0) 
    

    --audio.preloadSound("errenlandmatch/audio/ready.mp3") 

    --SoundManager:playMusicBackground("errenlandmatch/audio/BACK_MUSIC.mp3", true)     
end 

--计时器回调
function ErRenLandScene:schedulerFunction()
    --玩家管理计时器
    self.m_Player:OnUserClock()
    self.SysTime:setString(self:GetSystime())
    self.m_MatchWaitnextronud:settime()
end

--重置托管
function ErRenLandScene:ReSetTuoGuan()
       self.OutTimeCount=0
       self.m_bTrustee=false
       for i=1,ErRenLandDefine.GAME_PLAYER do
           self.m_Player:SetUserTuoguan(i,false)
       end
       self.ButtonTuoguan:hide()
       self.Image_TuoguanMe:hide()
       self.m_HandCardControl:SetTuoguanStatus(false)
end

--初始化数据
function ErRenLandScene:FreeAllData()

    self.OutTimeCount=0
    --发牌时的一张明牌
    self.MagicCard=0
    --底牌数据
    self.BackCarddata={}
    --当前玩家
    self.m_wCurrentUser=65535
    --游戏状态
    self.Game_Status=0
    --当前桌面扑克张数
    self.m_cbTurnCardCount=0
    --当前桌面扑克数据
    self.m_cbTurnCardData={}
    self.HandCardCount={0,0}
    self.m_handCardData={}
    self:ReSetTuoGuan()
    self.m_BackCard:FreeControl()
    self.m_HandCardControl:FreeControl()
    self.m_OthHandCardControl:FreeControl()
    self.OtheUserCardImage:hide()
    self.OtheUserCardNum1:setString(tostring(0))
    self.OtheUserCardNum2:setString(tostring(0))
    
    for i=1,ErRenLandDefine.GAME_PLAYER do
        self.UserCardControl[i]:FreeControl()
    end
    self:ShowTopView(false,false)
end

--加载资源
function ErRenLandScene:InitUnits()
    
    local Gamtableb=display.newSprite("errenlandmatch/u_game_table.jpg")

    if display.height > Gamtableb:getContentSize().height  then
        local scale=display.height/Gamtableb:getContentSize().height
        Gamtableb:setScale(scale)
    end

    Gamtableb:center()
    Gamtableb:addTo(self)


    --读取json 文件
    self.jsonnode = cc.uiloader:load("errenlandmatch/GameView.json")
    self.jsonnode:addTo(self)


    --系统时间
    self.SysTime=cc.uiloader:seekNodeByName(self.jsonnode,"SysTime")
    self.SysTime:setString(self:GetSystime())
    --开始按钮
   -- self.ButtonStart=cc.uiloader:seekNodeByName(self.jsonnode,"Button_Satrt")
   -- self.ButtonStart:zorder(260)
    --退出按钮
    self.ButtonExit=cc.uiloader:seekNodeByName(self.jsonnode,"Button_Exit_Game")
    --出牌按钮
    self.ButtonOutCard=cc.uiloader:seekNodeByName(self.jsonnode,"Button_OutCard")
    --不出按钮
    self.ButtonPassCard=cc.uiloader:seekNodeByName(self.jsonnode,"Button_PassCard")
    --提示按钮
    self.Buttontishi=cc.uiloader:seekNodeByName(self.jsonnode,"Button_Tishi")
    --叫地主按钮
    self.ButtonCall=cc.uiloader:seekNodeByName(self.jsonnode,"Button_Jiao")
    --不叫按钮
    self.ButtonNoCall=cc.uiloader:seekNodeByName(self.jsonnode,"Button_bujiao")
    --抢地主按钮
    self.ButtonQiang=cc.uiloader:seekNodeByName(self.jsonnode,"Button_qiang")
    --不抢按钮
    self.ButtonNoQiang=cc.uiloader:seekNodeByName(self.jsonnode,"Button_buqiang")
    self.Image_TuoguanMe=cc.uiloader:seekNodeByName(self.jsonnode,"Image_TuoguanMe")
    self.Image_TuoguanMe:zorder(330)
    --托管按钮
    self.ButtonTuoguan=cc.uiloader:seekNodeByName(self.jsonnode,"Button_tuoguan")
    --取消托管
    self.ButtonQuxiaoTuoguan=cc.uiloader:seekNodeByName(self.jsonnode,"Bt_QuxiaoTuoguan")
    --设置按钮
    self.ButtonShezhi=cc.uiloader:seekNodeByName(self.jsonnode,"Button_shezhi")
    --对家牌
    self.OtheUserCardImage=cc.uiloader:seekNodeByName(self.jsonnode,"Image_card")
    self.OtheUserCardNum1=cc.uiloader:seekNodeByName(self.OtheUserCardImage,"num_1")
    self.OtheUserCardNum2=cc.uiloader:seekNodeByName(self.OtheUserCardImage,"num_2")
    --声明Player对象
    self.m_Player=Player.new(self.jsonnode,self.m_GameKernel)
    --加载牌的资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Common/AnimationCard.ExportJson")

    
    self.Rangduifang=cc.uiloader:seekNodeByName(self.jsonnode,"Panel_rangduifang")
    self.Rangduifang1=cc.uiloader:seekNodeByName(self.Rangduifang,"Label_rangduifang1")
    self.Rangduifang2=cc.uiloader:seekNodeByName(self.Rangduifang,"Label_rangduifang2")
    self.BeiRang=cc.uiloader:seekNodeByName(self.jsonnode,"Panel_beirang")
    self.BeiRang1=cc.uiloader:seekNodeByName(self.BeiRang,"Label_beirang1")
    self.BeiRang2=cc.uiloader:seekNodeByName(self.BeiRang,"Label_beirang2")
    --牌堆位置
    self.HeapPos=cc.p(320,display.cy+50)
    self.m_BackCard=BackCard.new()
    self.m_BackCard:addTo(self.jsonnode)
    --初始化手牌
    self:InitHandCardControl()
    --初始化出的牌
    self:InitUserCardControl()
    self.m_GameEndView=GameEndView.new()
    self.m_GameEndView:addTo(self)
    self.m_GameEndView:hide()
    self.m_GameEndView:zorder(200)

    self.m_gameAni=GameAnimation.new()
    self.m_gameAni:addTo(self)
    self.m_gameAni:zorder(300)



    ------------------------------
    self.m_MatchWaitStartFull=MatchWaitStartFull.new()
    self.m_MatchWaitStartFull:hide()
    self.m_MatchWaitStartFull:addTo(self)
    self.m_MatchWaitStartFull:zorder(100) 


    self.m_MatchWaitnextronud=MatchWaitnextronud.new()
    self.m_MatchWaitnextronud:hide()
    self.m_MatchWaitnextronud:addTo(self)
    self.m_MatchWaitnextronud:zorder(100) 

    self.m_Matchinfo=Matcthinfo.new(self.m_GameKernel)
    self.m_Matchinfo:hide()
    self.m_Matchinfo:addTo(self)
    self.m_Matchinfo:zorder(10)

    self.m_Matchresultwin=Matcthresultwin.new()
    self.m_Matchresultwin:hide()
    self.m_Matchresultwin:addTo(self)
    self.m_Matchresultwin:zorder(110)

    self.m_Matchresultlose=Matcthresultlose.new()
    self.m_Matchresultlose:hide()
    self.m_Matchresultlose:addTo(self)
    self.m_Matchresultlose:zorder(110)


    

    

    self.WaitMoment=display.newSprite("errenlandmatch/waitmoment.png")

    self.WaitMoment:setPosition(display.cx,display.cy-80)
    self.WaitMoment:addTo(self)
    self.WaitMoment:hide()


    ---------------------------------
    --发牌事件
    local eventListeners = eventListeners or {}
    eventListeners[self.m_HandCardControl.Event.HINT_CARD] = handler(self, self.OnHintHandCard)
    eventListeners[self.m_Player.Event.CLOCK_END] = handler(self, self.OnUserClockEnd)
    eventListeners[self.m_Player.Event.USER_LEAVE] = handler(self, self.OnUserLeave)
    
    eventListeners[self.m_BackCard.Event.OPEN_BACK_CARD_FINISH] = handler(self, self.OnOpenBackCardFinish)
    eventListeners[self.m_GameEndView.Event.RETURN_ROOM] = handler(self, self.OnReturnRoom)
    eventListeners[self.m_GameEndView.Event.CONTINUE_GAME] = handler(self, self.OnContinueGame)
    eventListeners[self.m_GameEndView.Event.END_VIEW_CLOSE] = handler(self, self.OnGameEndViewClose)

    eventListeners[self.m_Matchresultlose.Event.EXIT_MATCH_GAME] = handler(self, self.CloseGame)
    eventListeners[self.m_Matchresultlose.Event.SING_UP_NEXT] = handler(self, self.SingUpNext)
  
    eventListeners[self.m_Matchresultwin.Event.EXIT_MATCH_GAME] = handler(self, self.CloseGame)
    eventListeners[self.m_Matchresultwin.Event.SING_UP_NEXT] = handler(self, self.SingUpNext)

    self.CardeventHandles = self.ClientKernel:addEventListenersByTable( eventListeners )

end

--初始化手牌
function ErRenLandScene:InitHandCardControl()
    --手牌
    self.m_HandCardControl=HandCardControl.new()
    self.m_HandCardControl:SetStartPos(cc.p(display.cx,130))
    self.m_HandCardControl:SetDistance(40)
    self.m_HandCardControl:SetScal(0.9)
    self.m_HandCardControl:addTo(self.jsonnode)
    self.m_HandCardControl:zorder(100)
    self.m_HandCardControl:SetShow(true)
    self.m_HandCardControl:SetCardTouchEnabled(true)

    self.m_OthHandCardControl=HandCardControl.new()
    self.m_OthHandCardControl:addTo(self.jsonnode)
    self.m_OthHandCardControl:zorder(50)
end 

--初始化手牌
function ErRenLandScene:InitUserCardControl()
    self.UserCardControl={
    UserCardControl.new(),
    UserCardControl.new(),
    }
    --用户出牌的位置
    local CardPos=
    {
      cc.p(display.cx-40,450),--0号位置 对家
      cc.p(display.cx-40,320)--1号位置 对家
    }
    --用户出牌的间距
    local CardDistance=
    {
      33,--0号位置 对家
      35--1号位置 对家
    } 
    --用户出牌的大小
    local CardScal=
    {
      0.5,--0号位置 对家
      0.6--1号位置 对家
    }
    for i=1,ErRenLandDefine.GAME_PLAYER do
        self.UserCardControl[i]:SetStartPos(CardPos[i])
        self.UserCardControl[i]:SetDistance(CardDistance[i])
        self.UserCardControl[i]:SetScal(CardScal[i])
        self.UserCardControl[i]:addTo(self.jsonnode)
        self.UserCardControl[i]:zorder(60+i)
    end
end 


-----------------------发牌---------------------

--开始发牌
function ErRenLandScene:StartDisPachCard()
    --发牌张数
    self.dispatchCardCount=0
    self.HandCardCount={0,0}
    --计时器
    self.Dispatchtimer=self:schedule(handler(self,self.dispatchCard), 0.05)
    self.OtheUserCardImage:show()
    --SoundManager:playMusicEffect("Blackjack/Audios/deal.mp3", false, false)
end
--发牌计时器
function ErRenLandScene:dispatchCard()

    local sendUser=self.FirstDispatchUser+self.dispatchCardCount
    sendUser=sendUser%ErRenLandDefine.GAME_PLAYER
    self.dispatchCardCount=self.dispatchCardCount+1
    local sendUserViewID=self.m_GameKernel:SwitchViewChairID(sendUser)
    local count = self.HandCardCount[sendUserViewID+1]
    count=count+1
    self.HandCardCount[sendUserViewID+1]=count
    if sendUserViewID==ErRenLandDefine.MYSELF_VIEW_ID then
        local cardData=self.m_handCardData[count]
           self.m_HandCardControl:AddOneHandCard(cardData)
    else
           self.OtheUserCardNum1:setString(tostring(count))
    end
    if self.dispatchCardCount== ErRenLandDefine.DISPATCH_COUNT then 
        self:stopAction(self.Dispatchtimer)
        self:OnDisPatchCardFinish()
    end
end


----------------------------以下是回调处理-----------------------

--点击牌回调
function ErRenLandScene:OnHintHandCard()

    self:OnSetOutCardStatus()
    local szSoundName="errenlandmatch/audio/selectCard.mp3"
    SoundManager:playMusicEffect(szSoundName, false, false)
end

--检测是否可以出牌
function ErRenLandScene:OnSetOutCardStatus()

    local ShootCard=self:VerdictOutCard()
    self.ButtonOutCard:setButtonEnabled(ShootCard)
    if ShootCard==true then
        self.BtOutEnableTrue=cc.uiloader:seekNodeByName(self.ButtonOutCard,"Image_True")
        self.BtOutEnableTrue:show()
        self.BtOutEnableFalse=cc.uiloader:seekNodeByName(self.ButtonOutCard,"Image_False")
        self.BtOutEnableFalse:hide()
    else
        self.BtOutEnableTrue=cc.uiloader:seekNodeByName(self.ButtonOutCard,"Image_True")
        self.BtOutEnableTrue:hide()
        self.BtOutEnableFalse=cc.uiloader:seekNodeByName(self.ButtonOutCard,"Image_False")
        self.BtOutEnableFalse:show()
    end

end
--发牌完成
function ErRenLandScene:OnDisPatchCardFinish()
    --上方信息显示
    self:ShowTopView(true,true)
   -- self.m_HandCardControl:SortCard()
    self.m_Player:ClearUserOper()
    self.m_Player:KillUserClock()
    local viewID=self.m_GameKernel:SwitchViewChairID(self.m_wCurrentUser)
    self.m_Player:SetUserClock(viewID,self.m_cbTimeCallScore,ErRenLandDefine.IDI_CALL_SCORE)
    self:SetLandButtonStatus()
end

--返回大厅
function ErRenLandScene:OnReturnRoom()
    self:CloseGame()
end

--继续游戏
function ErRenLandScene:OnContinueGame()
    self.m_GameEndView:FreeContol()
    self:BtStartGame()
end
--继续游戏
function ErRenLandScene:OnGameEndViewClose(evt)
  
end



--底牌翻开了
function ErRenLandScene:OnOpenBackCardFinish(evt)
--    print("底牌翻开了")
end
--玩家离开
function ErRenLandScene:OnUserLeave(evnt)
    local ViewID=evnt.OperID
    if ViewID ~=ErRenLandDefine.MYSELF_VIEW_ID then
        self.UserCardControl[ViewID+1]:FreeControl()
        self.m_OthHandCardControl:FreeControl()
    end
end
--玩家计时器超时
function ErRenLandScene:OnUserClockEnd(evnt)
    local OperID=evnt.OperID
    if OperID==ErRenLandDefine.IDI_START_GAME then
        --self.m_GameKernel:LeaveGame()
        --cc.Director:getInstance():popScene()
        self:CloseGame()
    end
    if OperID==ErRenLandDefine.IDI_CALL_SCORE then
        if self:GetCallLandStatus()==ErRenLandDefine.CSD_NORMAL then
           self:BtNoCallLand()
        end
        if self:GetCallLandStatus()==ErRenLandDefine.CSD_SNATCHLAND then
           self:BtNoQiang()
        end
    end
    if OperID==ErRenLandDefine.IDI_OUT_CARD then
        if self.m_bTrustee==false then
            self.OutTimeCount=self.OutTimeCount+1
            if self.OutTimeCount>2 then
                self:SetMeTuoguan(true)
            end
        end 
        self:AutoOutCard(true)
    end
end

--最大扑克
function ErRenLandScene:OnMostCard()
    --删除时间
    self:stopAction(self.MostCardtimer)
    --设置变量
    self.m_wCurrentUser=self.m_wMostCardUser
    self.m_wMostCardUser=65535

    --设置界面
    self.m_Player:ClearUserOper()
    for i=1,ErRenLandDefine.GAME_PLAYER do
         self.UserCardControl[i]:FreeControl()
    end
    local Curviewid=self.m_GameKernel:SwitchViewChairID(self.m_wCurrentUser)
    --开始计时器
    self.m_Player:SetUserClock(Curviewid,self.m_cbTimeOutCard,ErRenLandDefine.IDI_OUT_CARD)

    --更新出牌按钮
    self:SetHandButtonStatus()
    self:OnSetOutCardStatus()
    if self.m_wCurrentUser==self.m_GameKernel:GetMeChairID() and self.m_cbTurnCardCount==0 then
        --获取类型
        local HandCardcount= self.HandCardCount[ErRenLandDefine.MYSELF_VIEW_ID+1]
        local cbCardType=self.m_CardLogic:GetCardType(self.m_handCardData,HandCardcount)
        if cbCardType~=ErRenLandDefine.CT_ERROR 
            and cbCardType~=ErRenLandDefine.CT_FOUR_TAKE_ONE 
            and cbCardType~=ErRenLandDefine.CT_FOUR_TAKE_TWO
            and cbCardType~=ErRenLandDefine.CT_BOMB_CARD then
            self:AutoOutCard(false)
        end
    end   
end



--------------------------以下是状态相关------------------

--设置游戏状态
function ErRenLandScene:SetGameStatus(status)
    self.Game_Status=status
end

--设置叫抢地主状态
function ErRenLandScene:SetCallLandStatus(status)
    self.CallLand_Status=status
    
end

--获取游戏状态
function ErRenLandScene:GetGameStatus()
    return self.Game_Status
end

--获取叫抢地主状态
function ErRenLandScene:GetCallLandStatus()
    return self.CallLand_Status
end

--设置操作按钮
function ErRenLandScene:SetHandButtonStatus()
    --当前用户是自己则显示出牌按钮
    if self.m_wCurrentUser==self.m_GameKernel:GetMeChairID() then
        self.ButtonOutCard:show()
        self.ButtonOutCard:setButtonEnabled(false)
        self.BtOutEnableTrue=cc.uiloader:seekNodeByName(self.ButtonOutCard,"Image_True")
        self.BtOutEnableTrue:hide()
        self.BtOutEnableFalse=cc.uiloader:seekNodeByName(self.ButtonOutCard,"Image_False")
        self.BtOutEnableFalse:show()

        --不出按钮抬起
        self.ButtonPassCard:show()
        --提示按钮
        self.Buttontishi:show()
        if self.m_cbTurnCardCount==0 then
            self.ButtonPassCard:setButtonEnabled(false)
            self.BtPassEnableTrue=cc.uiloader:seekNodeByName(self.ButtonPassCard,"Image_True")
            self.BtPassEnableTrue:hide()
            self.BtPassEnableFalse=cc.uiloader:seekNodeByName(self.ButtonPassCard,"Image_False")
            self.BtPassEnableFalse:show()
        else
            self.ButtonPassCard:setButtonEnabled(true)
            self.BtPassEnableTrue=cc.uiloader:seekNodeByName(self.ButtonPassCard,"Image_True")
            self.BtPassEnableTrue:show()
            self.BtPassEnableFalse=cc.uiloader:seekNodeByName(self.ButtonPassCard,"Image_False")
            self.BtPassEnableFalse:hide()
        end
        --查找提示牌
        self:FindOutCard()    
    else
       self.ButtonOutCard:hide()
        --不出按钮抬起
        self.ButtonPassCard:hide()
        --提示按钮
        self.Buttontishi:hide() 
    end
end

--设置操作按钮
function ErRenLandScene:SetLandButtonStatus() 
    self.ButtonCall:hide()--叫地主按钮
    self.ButtonNoCall:hide()--不叫按钮
    self.ButtonQiang:hide()--抢地主按钮
    self.ButtonNoQiang:hide()--不抢按钮
    --当前用户是自己则显示按钮
    if self.m_wCurrentUser==self.m_GameKernel:GetMeChairID() then
        if self:GetCallLandStatus()==ErRenLandDefine.CSD_NORMAL then
            self.ButtonCall:show()
            self.ButtonNoCall:show()
        end
        if self:GetCallLandStatus()==ErRenLandDefine.CSD_SNATCHLAND then
            self.ButtonQiang:show()
            self.ButtonNoQiang:show()
        end
    end
end



------------------------------------------------------
--检查能否出牌
function ErRenLandScene:VerdictOutCard()
    --状态判断
    if self.m_wCurrentUser~=self.m_GameKernel:GetMeChairID() then
       return false
    end
    if self:GetGameStatus()~=ErRenLandDefine.GS_T_PLAY then
       return false
    end
    local ShootCard=self.m_HandCardControl:GetShootCard()
    --获取扑克
    local cbCardData=ShootCard.data
    local cbShootCount=ShootCard.count

    --出牌判断
    if cbShootCount>0 then
        --类型判断
        local cardType=self.m_CardLogic:GetCardType(cbCardData,cbShootCount)
        if cardType==ErRenLandDefine.CT_ERROR then 
            return false 
        end
        --跟牌判断
        if self.m_cbTurnCardCount==0 then
         return true
        end
        local bcompare=self.m_CardLogic:CompareCard(self.m_cbTurnCardData,cbCardData,self.m_cbTurnCardCount,cbShootCount)
        return bcompare
    end
end


---------------[[以下是接收游戏服务端场景消息处理]]--------------
--场景
function ErRenLandScene:OnGameScenceMsg(evt)
    
    local  statusInfo = {}
    local unResolvedData = evt.para.unResolvedData

    --等待开始
    if self.ClientKernel.cbGameStatus==ErRenLandDefine.GS_T_FREE then
        statusInfo = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusFree")
        --//时间定义
        self.m_cbTimeOutCard=statusInfo.cbTimeOutCard
        self.m_cbTimeCallScore=statusInfo.cbTimeCallScore
        self.m_cbTimeStartGame=statusInfo.cbTimeStartGame
        self.m_cbTimeHeadOutCard=statusInfo.cbTimeHeadOutCard
        self:SetGameStatus(ErRenLandDefine.GS_T_FREE)
        --self.ButtonStart:setPositionY(display.cy-100)
       -- self.ButtonStart:show() 
--        self.m_Player:SetUserClock(ErRenLandDefine.MYSELF_VIEW_ID,self.m_cbTimeStartGame,ErRenLandDefine.IDI_START_GAME)
    end
    --叫分状态  
    if self.ClientKernel.cbGameStatus==ErRenLandDefine.GS_T_CALL then
        statusInfo = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusCall")
        self.HandCardCount={0,0}
        --当前玩家
        self.m_wCurrentUser=statusInfo.wCurrentUser
        self:SetCallLandStatus(statusInfo.bCallScorePhase)
        --扑克数据
        for  i=1,ErRenLandDefine.GAME_PLAYER do
            self.HandCardCount[i]=ErRenLandDefine.NORMAL_COUNT
        end 
        self.m_HandCardControl:SetCardData(ErRenLandDefine.NORMAL_COUNT,statusInfo.cbHandCardData)
        self.OtheUserCardNum1:setString(tostring(ErRenLandDefine.NORMAL_COUNT))
        self.m_handCardData=statusInfo.cbHandCardData
        --//时间定义
        self.m_cbTimeOutCard=statusInfo.cbTimeOutCard
        self.m_cbTimeCallScore=statusInfo.cbTimeCallScore
        self.m_cbTimeStartGame=statusInfo.cbTimeStartGame
        self.m_cbTimeHeadOutCard=statusInfo.cbTimeHeadOutCard
        self:SetGameStatus(ErRenLandDefine.GS_T_CALL)
        self:ShowTopView(true,false)
        self.OtheUserCardImage:show()
        self:SetTopViewRangCount(statusInfo.m_cbRangPaiCount)
        self:SetTopViewAllBeishu(statusInfo.cbBankerScore)
        --设置基数
       -- self.CellScore=cc.uiloader:seekNodeByName(self.jsonnode,"CellScore")
        --self.CellScore:setString(tostring(statusInfo.lCellScore))
        --self.CellScore:show()

 
        local viewID=self.m_GameKernel:SwitchViewChairID(self.m_wCurrentUser)
        self.m_Player:SetUserClock(viewID,self.m_cbTimeCallScore,ErRenLandDefine.IDI_CALL_SCORE)
        self:SetLandButtonStatus()
    end
    --游戏进行 
    if self.ClientKernel.cbGameStatus==ErRenLandDefine.GS_T_PLAY then
        statusInfo = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusPlay")
        
        self.HandCardCount={0,0}


        --//设置变量
        -- m_cbBombCount=pStatusPlay->cbBombCount
        self.m_wBankerUser=statusInfo.wBankerUser
        self.m_wBeiRangUser=statusInfo.wBeiRangUser
        -- m_cbLandScore = pStatusPlay->cbBankerScore
        self.m_wCurrentUser=statusInfo.wCurrentUser

            --让牌张数
        self.m_RangpaiCount=statusInfo.m_cbRangPaiCount


        
        self:ShowTopView(true,false)
        self:SetTopViewRangCount(statusInfo.m_cbRangPaiCount)
        self:SetTopViewAllBeishu(statusInfo.cbBankerScore)
        
        --设置底牌（底牌倍数 ，底牌倍数描述，）
        local Type, Score = self.m_BackCard:GetCardTypeAndScore(statusInfo.cbBankCardType,statusInfo.cbBankCardScore)
        self:SetTopViewBackcardstr(Type,Score)
        --self:SetTopViewBackBeishu(Score)
        local ishaneBeishu=false
        if statusInfo.cbBankCardScore>=2 then
            ishaneBeishu=true
        end

        self.m_BackCard:ShowBackCard(ishaneBeishu)
        self.m_BackCard:SetbackCarddata(statusInfo.cbBankerCard)

        --手牌
        self.OtheUserCardImage:show()
        for i=1,ErRenLandDefine.GAME_PLAYER do
            local ViewID=self.m_GameKernel:SwitchViewChairID(i-1)
            self.HandCardCount[ViewID+1]=statusInfo.cbHandCardCount[i]
            if ViewID==ErRenLandDefine.MYSELF_VIEW_ID then
                self.m_HandCardControl:SetCardData(self.HandCardCount[ViewID+1],statusInfo.cbHandCardData)
            else
                self.OtheUserCardNum1:setString(tostring(self.HandCardCount[ViewID+1]))
            end
        end
        self.m_handCardData={}
        local findindex=0
        for k,v in pairs(statusInfo.cbHandCardData) do
            if v~=0 then
                findindex=findindex+1
                self.m_handCardData[findindex]=statusInfo.cbHandCardData[k]
            end
        end

        --设置可以点击了
        self.m_HandCardControl:SetCardTouchEnabled(true)
        --对家手牌让张数
        if self.m_wBeiRangUser~=self.m_GameKernel:GetMeChairID() then
            self.OtheUserCardNum2:setString(tostring(statusInfo.m_cbRangPaiCount))
        end

        --当前牌数据
        self.m_cbTurnCardCount=statusInfo.cbTurnCardCount
        self.m_cbTurnCardData={}
        for i=1,self.m_cbTurnCardCount do
            self.m_cbTurnCardData[i]=statusInfo.cbTurnCardData[i]
        end

        if statusInfo.wTurnWiner~=65535 then
            local  outviewid=self.m_GameKernel:SwitchViewChairID(statusInfo.wTurnWiner)
            --显示出牌
            self.UserCardControl[outviewid+1]:FreeControl()
            self.UserCardControl[outviewid+1]:SetCardData(self.m_cbTurnCardCount,self.m_cbTurnCardData)
            if statusInfo.wTurnWiner== self.m_wBankerUser then 
                self.UserCardControl[outviewid+1]:SetLandCard()
            end
        end

        --设置首牌地主角标
        if self.m_wBankerUser==self.m_GameKernel:GetMeChairID() then        
            self.m_HandCardControl:SetLandCard()
        end
        --显示地主标志
        local ViewID=self.m_GameKernel:SwitchViewChairID(self.m_wBankerUser)
        self.m_Player:SetBankerUser(ViewID)

        --设置基数
      --  self.CellScore=cc.uiloader:seekNodeByName(self.jsonnode,"CellScore")
       -- self.CellScore:setString(tostring(statusInfo.lCellScore))
       -- self.CellScore:show()

        self.m_cbTimeOutCard=statusInfo.cbTimeOutCard
        self.m_cbTimeCallScore=statusInfo.cbTimeCallScore
        self.m_cbTimeStartGame=statusInfo.cbTimeStartGame
        self.m_cbTimeHeadOutCard=statusInfo.cbTimeHeadOutCard
        self:SetGameStatus(ErRenLandDefine.GS_T_PLAY)

         --当前玩家视图ID
        local Curviewid=self.m_GameKernel:SwitchViewChairID(self.m_wCurrentUser)
        --开始计时器
        self.m_Player:SetUserClock(Curviewid,self.m_cbTimeOutCard,ErRenLandDefine.IDI_OUT_CARD)
        --更新出牌按钮
        self:SetHandButtonStatus()

        if self.m_bTrustee==true then
           self.m_HandCardControl:SetTuoguanStatus(true)
           self.m_HandCardControl:SetCardTouchEnabled(false)
        else
           self.m_HandCardControl:SetTuoguanStatus(false)
           self.m_HandCardControl:SetCardTouchEnabled(true)
        end
        self:ShowRangpai(self.m_wBeiRangUser,self.m_RangpaiCount)
        self:SetWinCardCount()
    end

end

------------------------以下是游戏接收服务端逻辑消息处理-----------------

--游戏开始
function ErRenLandScene:OnSubGameStatrt(evt)
--    print("游戏开始")

    self.WaitMoment:hide()
    self.m_MatchWaitnextronud:hide()
    self:FreeAllData()        --初始化数据
    self.m_Player:KillUserClock()
    self.m_Player:ClearBankerUser()
    --当前桌面扑克张数
    self.m_cbTurnCardCount=0
    --当前桌面扑克数据
    self.m_cbTurnCardData={}
    self.HandCardCount={0,0}
    self.m_handCardData={}

    local GameStartDB=evt.para 
    --当前玩家
    self.m_wCurrentUser=GameStartDB.wCurrentUser
    --叫分
    self.m_wLandScore=GameStartDB.m_cbLandScore
    --首发用户
    self.FirstDispatchUser=GameStartDB.wStartUser
    --设置为叫分状态
    self:SetGameStatus(ErRenLandDefine.GS_T_CALL)
    self:SetCallLandStatus(ErRenLandDefine.CSD_NORMAL)
    --发牌数据

    self.m_handCardData=self.m_CardLogic:SortCardData(GameStartDB.cbCardData)
    --开始发牌
    self:StartDisPachCard()

    local szSoundName="errenlandmatch/audio/GAME_START.mp3"
    SoundManager:playMusicEffect(szSoundName, false, false)
end

--设置基数
function ErRenLandScene:OnSubSetCellScore(evt)
--    print("设置基数")
    --dump(evt.para);
    --设置基数
  --  self.CellScore=cc.uiloader:seekNodeByName(self.jsonnode,"CellScore")
   -- self.CellScore:setString(tostring(evt.para.CellScore))
   -- self.CellScore:show()
end

--叫地主
function ErRenLandScene:OnSubCallScore(evt)  
    self.m_Player:ClearUserOper()
    self.m_Player:KillUserClock()

    local CallLandDb=evt.para
     self:PalyCalllandSound(CallLandDb.cbCallScore,CallLandDb.wCallScoreUser,CallLandDb.m_cbRangPaiCount)
    if CallLandDb.wCurrentUser~=65535 then
      self.m_wCurrentUser=CallLandDb.wCurrentUser
      self:SetCallLandStatus(CallLandDb.bCallScorePhase)
      local viewID=self.m_GameKernel:SwitchViewChairID(self.m_wCurrentUser)
      self.m_Player:SetUserClock(viewID,self.m_cbTimeCallScore,ErRenLandDefine.IDI_CALL_SCORE)
      self:SetLandButtonStatus()
      --让牌张数
      self:SetTopViewRangCount(CallLandDb.m_cbRangPaiCount)
      self:SetTopViewAllBeishu(CallLandDb.cbCurrentScore)
    end
    local userview=self.m_GameKernel:SwitchViewChairID(CallLandDb.wCallScoreUser) 
    --叫
    if CallLandDb.bOldCallScorePhase==ErRenLandDefine.CSD_NORMAL then
        if CallLandDb.cbCallScore==1 then  
            self.m_Player:SetUserOper(userview,2)
        else
            self.m_Player:SetUserOper(userview,3)
        end
    end
    --抢
    if CallLandDb.bOldCallScorePhase==ErRenLandDefine.CSD_SNATCHLAND then
        if CallLandDb.cbCallScore==1 then  
            self.m_Player:SetUserOper(userview,4)
        else
            self.m_Player:SetUserOper(userview,5)
        end
    end
   
end

--设置地主
function ErRenLandScene:OnSubBankerInfo(evt)

    local LandInfoDB=evt.para

    self.m_Player:ClearUserOper()
    self.m_Player:KillUserClock()
    --设置游戏状态
    self:SetGameStatus(ErRenLandDefine.GS_T_PLAY)

    --当前玩家
    self.m_wCurrentUser=LandInfoDB.wCurrentUser
    --地主
    self.m_wBankerUser=LandInfoDB.wBankerUser

    --让牌张数
    self.m_RangpaiCount=LandInfoDB.m_cbRangPaiCount
    --被让用户
    self.BeiRangUser=LandInfoDB.wBeiRangUser
    --设置底牌（底牌倍数 ，底牌倍数描述，）
    local Type, Score = self.m_BackCard:GetCardTypeAndScore(LandInfoDB.cbBankCardType,LandInfoDB.cbBackCardScore)
    self:SetTopViewBackcardstr(Type,Score)
    --self:SetTopViewBackBeishu(Score)
    --让牌张数
    self:SetTopViewRangCount(LandInfoDB.m_cbRangPaiCount)
    self:SetTopViewAllBeishu(LandInfoDB.cbBankerScore)
    local isHaveBeishu=false

    if LandInfoDB.cbBackCardScore>=2 then
        isHaveBeishu=true
    end
    self.m_BackCard:ShowBackCard(isHaveBeishu)
    self.m_BackCard:SetOpenbackCard(LandInfoDB.cbBankerCard)

    --设置让牌描述
    self:ShowRangpai(LandInfoDB.wBeiRangUser,LandInfoDB.m_cbRangPaiCount)

    local ViewID=self.m_GameKernel:SwitchViewChairID(LandInfoDB.wBankerUser)
    --显示地主标志
    self.m_Player:SetBankerUser(ViewID)

    --插入底牌到手牌
    self.HandCardCount[ViewID+1]=self.HandCardCount[ViewID+1]+3

    if LandInfoDB.wBankerUser==self.m_GameKernel:GetMeChairID() then
        for i=1,3 do
            table.insert(self.m_handCardData,LandInfoDB.cbBankerCard[i])
        end
        self.m_HandCardControl:SetBackCardData(LandInfoDB.cbBankerCard)  
        self.m_HandCardControl:SetLandCard()
    else
        self.OtheUserCardNum1:setString(tostring(self.HandCardCount[ViewID+1]))
    end

   -- print("插入底牌到手牌"..self.HandCardCount[ViewID+1])
   -- dump(self.m_handCardData)

    --设置可以点击了
    self.m_HandCardControl:SetCardTouchEnabled(true)
    --当前用户设置为出牌,更新出牌按钮状态
    self:SetHandButtonStatus()
    self:OnSetOutCardStatus()
    local CurViewID=self.m_GameKernel:SwitchViewChairID(LandInfoDB.wCurrentUser)
    --开始计时器
    self.m_Player:SetUserClock(CurViewID,self.m_cbTimeHeadOutCard,ErRenLandDefine.IDI_OUT_CARD)
    self.ButtonTuoguan:show() 

    if self.m_wBankerUser~=65535 then

        SoundManager:playMusicEffect("errenlandmatch/audio/BANKER_INFO.mp3", false, false)
    end

    self:SetWinCardCount()


end
function  ErRenLandScene:SetWinCardCount()
    -- body
      --让牌张数
    --self.m_RangpaiCount=LandInfoDB.m_cbRangPaiCount
    --被让用户
    --self.BeiRangUser=LandInfoDB.wBeiRangUser

    if self.BeiRangUser==self.m_GameKernel:GetMeChairID() then

    local ViewID=self.m_GameKernel:SwitchViewChairID(self.m_GameKernel:GetMeChairID())
        self.BeiRang2:setString(tostring(self.HandCardCount[ViewID+1]-self.m_RangpaiCount))
    else
        self.Rangduifang2:setString(tostring(self.HandCardCount[1]-self.m_RangpaiCount))
    end
end
--出牌
function ErRenLandScene:OnSubOutCard(evt)

    
    self.m_Player:KillUserClock()
    self.m_Player:ClearUserOper()
    local UserOutCardDb=evt.para
    self.m_wCurrentUser=UserOutCardDb.wCurrentUser

    --当前玩家视图ID
    local Curviewid=self.m_GameKernel:SwitchViewChairID(UserOutCardDb.wCurrentUser)
    --设置新的倍数
    self:SetTopViewAllBeishu(UserOutCardDb.wAllBeishuNew)
    --清空当前玩家出的牌
    self.UserCardControl[Curviewid+1]:FreeControl()
    --出牌玩家视图ID
    local outviewid=self.m_GameKernel:SwitchViewChairID(UserOutCardDb.wOutCardUser)
    --删除手牌
    --自己直接删除牌数据
    --更新张数
    local oldCardcount= self.HandCardCount[ErRenLandDefine.MYSELF_VIEW_ID+1]
    self.HandCardCount[outviewid+1]=self.HandCardCount[outviewid+1]-UserOutCardDb.cbCardCount


    if UserOutCardDb.wOutCardUser==self.m_GameKernel:GetMeChairID() then
        local data=self.m_handCardData
        self.m_handCardData={}
        self.m_HandCardControl:RemoveCard(UserOutCardDb.cbCardCount,UserOutCardDb.cbCardData)
        self.count,self.m_handCardData= self.m_CardLogic:RemoveCardList(UserOutCardDb.cbCardData,UserOutCardDb.cbCardCount,data,oldCardcount)
    else --对家更新张数
        if self.HandCardCount[outviewid+1]==0 then
            self.OtheUserCardImage:hide()
        end
        self.OtheUserCardNum1:setString(tostring(self.HandCardCount[outviewid+1]))
    end


    if UserOutCardDb.wOutCardUser==self.BeiRangUser then
        if (self.HandCardCount[outviewid+1]-self.m_RangpaiCount)<=4 and (self.HandCardCount[outviewid+1]-self.m_RangpaiCount)>0 then
            self.m_Player:SetWarning(outviewid)
            local szSoundName="errenlandmatch/audio/COUNT_WARN.mp3"
            SoundManager:playMusicEffect(szSoundName, false, false)
        end
    else
        if self.HandCardCount[outviewid+1]<=4 and self.HandCardCount[outviewid+1]>0 then
            self.m_Player:SetWarning(outviewid)
            local szSoundName="errenlandmatch/audio/COUNT_WARN.mp3"
            SoundManager:playMusicEffect(szSoundName, false, false)
        end
    end
    

    --删除时间
    self:stopAction(self.MostCardtimer)
    --显示出牌
    self.UserCardControl[outviewid+1]:FreeControl()
  --  print("出牌设置----"..UserOutCardDb.cbCardCount)
   -- dump(UserOutCardDb.cbCardData)
    self.UserCardControl[outviewid+1]:SetCardData(UserOutCardDb.cbCardCount,UserOutCardDb.cbCardData)
    if UserOutCardDb.wOutCardUser== self.m_wBankerUser then 
        self.UserCardControl[outviewid+1]:SetLandCard()
    end
    if self.m_wCurrentUser~=65535 then
         --//最大判断
        if self.m_wCurrentUser==UserOutCardDb.wOutCardUser then
            --//设置用户
            self.m_wCurrentUser=65535
            self.m_wMostCardUser=UserOutCardDb.wCurrentUser
            --//出牌变量
            self.m_cbTurnCardCount=0
            self.m_cbTurnCardData={}
            --//放弃动作
            for i=1,ErRenLandDefine.GAME_PLAYER do
                --//用户过虑
                local chairID=i-1
                --//放弃界面
                local wViewChairID=self.m_GameKernel:SwitchViewChairID(chairID)
                if UserOutCardDb.wOutCardUser~=chairID then

                    --显示过牌
                    self.m_Player:SetUserOper(wViewChairID,1)
                    self.UserCardControl[wViewChairID+1]:FreeControl()
                end
                
            end
            --计时器
            self.MostCardtimer=self:schedule(handler(self,self.OnMostCard), 1)
        else
            --当前牌数据
            self.m_cbTurnCardCount=UserOutCardDb.cbCardCount
            self.m_cbTurnCardData={}
            for i=1,self.m_cbTurnCardCount do
                self.m_cbTurnCardData[i]=UserOutCardDb.cbCardData[i]
            end
            --更新出牌按钮
            self:SetHandButtonStatus()
            self:OnSetOutCardStatus()

        end
        --设置新的倒计时
        local m_cbTimeOutCard=UserOutCardDb.cbTimeOut
        --开始计时器
        self.m_Player:SetUserClock(Curviewid,m_cbTimeOutCard,ErRenLandDefine.IDI_OUT_CARD)
    end
   
    self:PlayAnimation(UserOutCardDb.cbCardData,UserOutCardDb.cbCardCount)
    self:PlayOutCardSound(UserOutCardDb.wOutCardUser,UserOutCardDb.cbCardData,UserOutCardDb.cbCardCount)

    self:SetWinCardCount()
end

--过牌
function ErRenLandScene:OnSubPassCard(evt)

    self.m_Player:KillUserClock()
    self.m_Player:ClearUserOper()
    local PassCardDb=evt.para

    --设置变量
    self.m_wCurrentUser=PassCardDb.wCurrentUser
    --print("2222222222222222222222222----"..self.m_wCurrentUser) 
    local m_cbTimeOutCard=PassCardDb.cbTimeOut

    --一轮判断
    if PassCardDb.cbTurnOver==1 then
        self.m_cbTurnCardCount=0
        self.m_cbTurnCardData={}
    end

    local viewid=self.m_GameKernel:SwitchViewChairID(PassCardDb.wPassCardUser)
    --显示过牌
    self.m_Player:SetUserOper(viewid,1)
    --设置新的倒计时
    local m_cbTimeOutCard=PassCardDb.cbTimeOut
    local Curviewid=self.m_GameKernel:SwitchViewChairID(PassCardDb.wCurrentUser)
    --开始计时器
    self.m_Player:SetUserClock(Curviewid,m_cbTimeOutCard,ErRenLandDefine.IDI_OUT_CARD)
    self.UserCardControl[Curviewid+1]:FreeControl()
    --更新出牌按钮
    self:SetHandButtonStatus()
    self:OnSetOutCardStatus()
   
    if PassCardDb.wPassCardUser~=65535 then
        local UserItem=self.ClientKernel:SearchUserByChairID(PassCardDb.wPassCardUser)
        local cbGender=UserItem.cbGender
        local strGender
        if cbGender==GENDER_FEMALE then --女性
            strGender="GIRL/"
        end
        if cbGender==GENDER_MANKIND then --男性
            strGender="BOY/"
        end
        local index=math.random(1,4)
        local name="buyao"..index..".mp3"
        SoundManager:playMusicEffect("errenlandmatch/audio/"..strGender..name, false, false)
    end

    if self.m_wCurrentUser==self.m_GameKernel:GetMeChairID() and self.m_cbTurnCardCount==0 then
        --获取类型
        local HandCardcount= self.HandCardCount[ErRenLandDefine.MYSELF_VIEW_ID+1]
        local cbCardType=self.m_CardLogic:GetCardType(self.m_handCardData,HandCardcount)
        if cbCardType~=ErRenLandDefine.CT_ERROR 
            and cbCardType~=ErRenLandDefine.CT_FOUR_TAKE_ONE 
            and cbCardType~=ErRenLandDefine.CT_FOUR_TAKE_TWO
            and cbCardType~=ErRenLandDefine.CT_BOMB_CARD then
            self:AutoOutCard(false)
        end
    end
end

--游戏托管
function ErRenLandScene:OnSubSetTuoguan(evt)
    local Gametuoguan=evt.para

    if Gametuoguan.ChairID==self.m_GameKernel:GetMeChairID() then
        if Gametuoguan.tuoguan==1 then
            self:SetMeTuoguan(true)
        else
            self:SetMeTuoguan(false)
        end 
    else
        if Gametuoguan.tuoguan==1 then
            self.m_Player:SetUserTuoguan(0,true)
        else
            self.m_Player:SetUserTuoguan(0,false)
        end   
    end
end

--游戏结束您让   张牌，对手再出     您被让  张牌，再出  张可获胜
function ErRenLandScene:OnSubGameOver(evt)
    local GameEndDb=evt.para
    self:ReSetTuoGuan()
    self:HideRangpai()
    self.m_Player:ClearUserOper()
    self.m_Player:ClearWarning()
    self.m_wCurrentUser=65535

--print("游戏结束了")
    local cbCardIndex=1
    for  i=1, ErRenLandDefine.GAME_PLAYER do
        --设置扑克
        if (i-1)~=self.m_GameKernel:GetMeChairID() then
            if GameEndDb.cbCardCount[i]>0 then
                local card={}
                for j=1,GameEndDb.cbCardCount[i] do
                    local index = cbCardIndex+j-1
                    card[j]=GameEndDb.cbHandCardData[index]
                end
                self.OtheUserCardImage:hide()
                self.m_OthHandCardControl:SetOthHandCardData(GameEndDb.cbCardCount[i],card,cc.p(display.cx,display.cy+165))
            end
        end
        --设置索引
        cbCardIndex=cbCardIndex+GameEndDb.cbCardCount[i]
    end
    --总倍数
    local beishu=1
    for i=1,GameEndDb.bChunTian do 
        beishu=beishu*2
    end
    for i=1,GameEndDb.bFanChunTian do 
        beishu=beishu*2
    end
    for i=1,GameEndDb.cbHuojianCount do 
        beishu=beishu*2
    end
    for i=1,GameEndDb.cbBombCount do 
        beishu=beishu*2
    end
    local AllBeishu=beishu*GameEndDb.cbBankerScore

    local m_chuntian=0
    if GameEndDb.bChunTian~=0 or GameEndDb.bFanChunTian~=0 then
        m_chuntian=1
    end

    local meResutScore=0
    for i=1,ErRenLandDefine.GAME_PLAYER do
        if (i-1)==self.m_GameKernel:GetMeChairID() then
            meResutScore=GameEndDb.lGameScore[i]
        end
    end
    if meResutScore<0 then
        local szSoundName="errenlandmatch/audio/GAME_LOSE.mp3"
        SoundManager:playMusicEffect(szSoundName, false, false)
    end
    if meResutScore>0 then
        local szSoundName="errenlandmatch/audio/GAME_WIN.mp3"
        SoundManager:playMusicEffect(szSoundName, false, false)
    end
    if m_chuntian==1 then
        self.m_gameAni:DoSpring()
    end
    local enddb=
    {
        mescore=meResutScore,
        chuntian=m_chuntian,
        huojian=GameEndDb.cbHuojianCount,
        zhadan=GameEndDb.cbBombCount,
        zongbeishu=AllBeishu,
        servertype=self.m_GameKernel:GetSerVerType()
    }
    self:SetHandButtonStatus()
    self:SetLandButtonStatus()
    if m_chuntian==1 then

        --print("游戏结束了AAAA")
        self:performWithDelay(function ( )  
            self.m_GameEndView:SetGameEndInfo(enddb)
        end, 2.0)
    else
        --print("游戏结束了BBBBB")
        --self:performWithDelay(function ( )  
        self.m_GameEndView:SetGameEndInfo(enddb)
        --end, 1.0)
    end
    
    self:SetGameStatus(ErRenLandDefine.GS_T_FREE)
    
--    self.m_Player:SetUserClock(ErRenLandDefine.MYSELF_VIEW_ID,self.m_cbTimeStartGame,ErRenLandDefine.IDI_START_GAME)
end


------------------------以下为比赛消息---------------------

--比赛等待开始
function ErRenLandScene:OnSubMatchUserReady(evt)
    self:BtStartGame()
end
--比赛动态
function ErRenLandScene:OnSubMatchInfo(evt)
    
    local Gametuoguan=evt.para
    self.m_Matchinfo:show()
    self.m_Matchinfo:SetInfo(Gametuoguan)
end
--比赛等待开始
function ErRenLandScene:OnSubMatchWaitStart(evt)

   --[[ struct CMD_GR_Match_WAITSTART
{
    BYTE                            dwmatchStatus;                      //比赛状态
    DWORD                           dwWaitting;                         //等待人数
    DWORD                           dwTotal;                            //开赛人数
    DWORD                           MeUserID;
    CMD_GR_MatchDesc                d_MatchDesc;
    BYTE                            NeedSortUserList;
};
struct CMD_GR_MatchDesc
{
    TCHAR                           szMatchName[32];        //比赛标题
    WORD                            Times;                  //平均时间
    SCORE                           No1Score;               //冠军奖励
    SCORE                           No2Score;               //冠军奖励
    SCORE                           No3Score;               //冠军奖励
    TCHAR                           szNorDescribe[128];     //描述内容常规
    TCHAR                           szSysDescribe[128];     //描述内容小贴士
    COLORREF                        crTitleColor;           //标题颜色
    COLORREF                        crNorDescribe;          //描述颜色
    COLORREF                        crSysDescribe;          //描述颜色
    CTimeSpan                       TimerSpan;              //开赛剩余时间
    BYTE                            MatchType;               //赛场类型
    TCHAR                               szAward1[32];
    TCHAR                               szAward2[32];
    TCHAR                               szAward3[32];
};


]]

    local waitstartDB=evt.para

--dump(waitstartDB)
    --设置参数
    if waitstartDB.dwmatchStatus==MS_SIGNUP then
        self.m_MatchWaitStartFull:show() 
        self.m_MatchWaitStartFull:SetInfo(waitstartDB)
        --m_pGameFrameView->SetMatchWaitStart(pMatchInfo);
    
    else
       self.m_MatchWaitStartFull:hide() 
       -- m_pGameFrameView->SetMatchWaitStart(NULL);
    end   

end
--比赛晋级等待动态
function ErRenLandScene:OnSubMatchTip(evt)
    --local Gametuoguan=evt.para
    local  statusInfo = {}
    local unResolvedData = evt.para.unResolvedData

    --等待开始
    if unResolvedData and unResolvedData.size~=0 then
        statusInfo = self.ClientKernel:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_GR_Match_Wait_Tip")
        statusInfo.Bisairenshu=self.m_Matchinfo.havecount
        self.m_MatchWaitnextronud:show()
        self.m_MatchWaitnextronud:SetInfo(statusInfo)
    else
        
        self.m_MatchWaitnextronud:hide()
    end

end
--比赛等待分组
function ErRenLandScene:OnSubMatchWaitMsg(evt)
    local Gamemsg=evt.para
   
    if string.find(Gamemsg.szString, "系统配桌")~=nil then
        self.WaitMoment:show()
    end 
end
--比赛结果
function ErRenLandScene:OnSubMatchResult(evt)
    self.m_MatchWaitnextronud:hide()
    local Gametuoguan=evt.para
    dump(Gametuoguan)
    if Gametuoguan.ResultType==1 then--奖励范围内的 
        self.m_Matchresultwin:SetInfo(Gametuoguan)
        self.m_Matchresultwin:show()
    end

    if Gametuoguan.ResultType==0 then--奖励范围外的 
        self.m_Matchresultlose:show()
    end

    self.m_Matchinfo:setLastRank(Gametuoguan.wRankLast)
end


-------------------------以下为让牌描述----------------

--让牌信息
function ErRenLandScene:ShowRangpai(beirang,userCount)


    self.Rangduifang:hide()
    self.BeiRang:hide()

    if beirang==self.m_GameKernel:GetMeChairID() then
        self.BeiRang:show()
        self.BeiRang1:setString(tostring(userCount))
        self.BeiRang2:setString(tostring(userCount))
    else
        self.Rangduifang:show()
        self.Rangduifang1:setString(tostring(userCount))
        self.Rangduifang2:setString(tostring(userCount))
    end


end
--隐藏让牌信息
function ErRenLandScene:HideRangpai()
    self.Rangduifang:hide()
    self.BeiRang:hide()
end





-------------------------以下顶部区域信息--------------

--上方信息
function ErRenLandScene:ShowTopView(show,move)
    --上方信息
    self.TopBack=cc.uiloader:seekNodeByName(self.jsonnode,"TOP_BACK")
    if show then 

    else
        self.TopBack:hide()
        self:SetTopViewAllBeishu(1)
        self:SetTopViewRangCount(0)
        self:SetTopViewBackBeishu("")
        self:SetTopViewBackcardstr("","")
        self.m_BackCard:ClearBackCard()
    end  
end

--上方信息设置倍数
function ErRenLandScene:SetTopViewAllBeishu(beishu)
        --总倍数
        self.TopBackAllBeishu=cc.uiloader:seekNodeByName(self.TopBack,"AllBeishu")
        self.TopBackAllBeishu:setString(tostring(beishu))

        self.m_beishu=cc.uiloader:seekNodeByName(self.jsonnode,"beishu")
        self.m_beishu:setString(tostring(beishu))
end

--上方信息设置让牌张数
function ErRenLandScene:SetTopViewRangCount(count)
        --总倍数
        self.TopBackRangcount=cc.uiloader:seekNodeByName(self.TopBack,"rangnum")
        self.TopBackRangcount:setString(tostring(count))
end

--上方信息设置底牌倍数
function ErRenLandScene:SetTopViewBackBeishu(str)
    self.TopBackbackDIbeishu=cc.uiloader:seekNodeByName(self.jsonnode,"Image_dibeishu")
    self.TopBackbackbeishu=cc.uiloader:seekNodeByName(self.TopBackbackDIbeishu,"beishutext")
    if str~="" then
        self.TopBackbackDIbeishu:show()  
    else
        self.TopBackbackDIbeishu:hide()
    end
    self.TopBackbackbeishu:setString(str)
end

--上方信息设置底牌描述
function ErRenLandScene:SetTopViewBackcardstr(str,score)
    self.TopBackbackcardstrf=cc.uiloader:seekNodeByName(self.jsonnode,"Image_DI")
    self.TopBackbackcardstr=cc.uiloader:seekNodeByName(self.TopBackbackcardstrf,"beishustr")
    if str~="" then
        if score~="" then
          str=str..score  
        end
        --倍数
        self.TopBackbackcardstrf:show()  
    else
        self.TopBackbackcardstrf:hide()
    end
    self.TopBackbackcardstr:setString(str)
end






-----------------------以下为按钮事件处理--------------------------------

--开始按钮
function ErRenLandScene:BtStartGame()

    
    --self.m_gameAni:DoBombAni()
    --self.m_gameAni:DoDoubleLine()
    --self.m_gameAni:DoPlane()
    --self.m_gameAni:DoRocket()
    --self.m_gameAni:DoSpring()
    --self.m_gameAni:DoCardLine()
    self:FreeAllData()        --初始化数据
    self.m_GameKernel:StartGame()
    --self.ButtonStart:hide()
    self.m_Player:KillUserClock()
    self.m_Player:ClearBankerUser()


    --self.m_OthHandCardControl=HandCardControl.new()
    --self.m_OthHandCardControl:addTo(self)



    --local card={1,2,3,4,5,6,7,8,9}
   -- self.m_OthHandCardControl:SetOthHandCardData(9,card,cc.p(display.cx-492,display.cy+50))

    --self:PalyCalllandSound(1,self.m_GameKernel:GetMeChairID(),1)
    
    --SoundManager:playMusicEffect("errenlandmatch/audio/ready.mp3", false, false)
end

--叫地主按钮
function ErRenLandScene:BtCallLand()
    self.ButtonCall:hide()--叫地主按钮
    self.ButtonNoCall:hide()--不叫按钮
    self.m_Player:KillUserClock()
    local CallScore = {}
    CallScore.cbCallScore = 1
    self.ClientKernel:requestCommand(MDM_GF_GAME,ErRenLandDefine.SUB_C_CALL_SCORE,CallScore,"CMD_C_CallScore")
end

--不叫按钮
function ErRenLandScene:BtNoCallLand()
    local CallScore = {}
    CallScore.cbCallScore = 255
    self.ButtonCall:hide()--叫地主按钮
    self.ButtonNoCall:hide()--不叫按钮
    self.m_Player:KillUserClock()
    self.ClientKernel:requestCommand(MDM_GF_GAME,ErRenLandDefine.SUB_C_CALL_SCORE,CallScore,"CMD_C_CallScore")
end

--抢地主按钮
function ErRenLandScene:BtQiang()
    self.ButtonQiang:hide()--抢地主按钮
    self.ButtonNoQiang:hide()--不抢按钮
    self.m_Player:KillUserClock()
    local CallScore = {}
    CallScore.cbCallScore = 1
    self.ClientKernel:requestCommand(MDM_GF_GAME,ErRenLandDefine.SUB_C_CALL_SCORE,CallScore,"CMD_C_CallScore")
end

--不抢按钮
function ErRenLandScene:BtNoQiang()
    self.ButtonQiang:hide()--抢地主按钮
    self.ButtonNoQiang:hide()--不抢按钮
    self.m_Player:KillUserClock()
    local CallScore = {}
    CallScore.cbCallScore = 255
    self.ClientKernel:requestCommand(MDM_GF_GAME,ErRenLandDefine.SUB_C_CALL_SCORE,CallScore,"CMD_C_CallScore")
end

--出牌按钮
function ErRenLandScene:BtOutCard(timeout)
    self.ButtonOutCard:hide()
    --不出按钮抬起
    self.ButtonPassCard:hide()
    --提示按钮
    self.Buttontishi:hide() 
    self.m_Player:KillUserClock()
    local OutCard = {}
    local shootCard=self.m_HandCardControl:GetShootCard()
    OutCard.cbCardCount = shootCard.count
    OutCard.cbCardData = shootCard.data
    OutCard.cbTimeOut = timeout
    self.ClientKernel:requestCommand(MDM_GF_GAME,ErRenLandDefine.SUB_C_OUT_CARD,OutCard,"CMD_C_OutCard")
end

--不出按钮
function ErRenLandScene:BtPassCard(timeout)
    local PassCard = {}
    PassCard.cbTimeOut = timeout
    self.ClientKernel:requestCommand(MDM_GF_GAME,ErRenLandDefine.SUB_C_PASS_CARD,PassCard,"CMD_C_PassCard")
    self.m_HandCardControl:SetCardLowDown()
end

--提示按钮
function ErRenLandScene:BtTishi()
    if self.CurSearchOutindex>self.SearchOutCount then
        self.CurSearchOutindex=1
    end
    if self.SearchOutCount>=1 then
        self.m_HandCardControl:ShootCard(self.SearchOutCardData[self.CurSearchOutindex],false)
        self:OnHintHandCard()
        self.CurSearchOutindex=self.CurSearchOutindex+1
    else
        self:BtPassCard(1)
    end
end
function ErRenLandScene:SetMeTuoguan(tuoguan)
     self.m_bTrustee=tuoguan
     if tuoguan==true then
        self.m_Player:SetUserTuoguan(ErRenLandDefine.MYSELF_VIEW_ID,true)
        self.ButtonTuoguan:hide()
        self.Image_TuoguanMe:show()
        self.m_HandCardControl:SetTuoguanStatus(true)
        self.m_HandCardControl:SetCardTouchEnabled(false)
     else
        self.OutTimeCount=0
        self.m_Player:SetUserTuoguan(ErRenLandDefine.MYSELF_VIEW_ID,false)
        self.ButtonTuoguan:show()
        self.Image_TuoguanMe:hide()
        self.m_HandCardControl:SetTuoguanStatus(false)
        self.m_HandCardControl:SetCardTouchEnabled(true)
     end
   




end
--托管按钮
function ErRenLandScene:BtTuoguan()
    self:SetMeTuoguan(true)

    local m_Tuoguan = {}

    m_Tuoguan.tuoguan=1
    self.ClientKernel:requestCommand(MDM_GF_GAME,ErRenLandDefine.SUB_C_TUOGUAN,m_Tuoguan,"CMD_C_Tuoguan")

end

--取消托管按钮
function ErRenLandScene:BtQuxiaoTuoguan()

    self:SetMeTuoguan(false)
    local m_Tuoguan = {}
    m_Tuoguan.tuoguan=0
    self.ClientKernel:requestCommand(MDM_GF_GAME,ErRenLandDefine.SUB_C_TUOGUAN,m_Tuoguan,"CMD_C_Tuoguan")
 
end

--设置按钮 
function ErRenLandScene:BtShezhi()
    --local settingView     = import("..Kernel.SettingView").new()--设置
    local settingView = require("errenlandmatch.App.Kernel.SettingView").new()
    settingView:setPosition(cc.p(display.cx,display.cy))
    self:addChild(settingView)
    settingView:zorder(300)
end
--关闭游戏
function ErRenLandScene:CloseGame()
    if self:GetGameStatus()~=ErRenLandDefine.GS_T_FREE then
        local dataMsgBox = 
        {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OKCANCEL,
            msgInfo="您当前正在游戏中，退出将会受到惩罚，是否确定退出？",
            callBack=function(ret)
                if ret == MSGBOX_RETURN_OK then
                    self.ClientKernel:exitGameApp()
                end
            end
        }
        local msgbox=require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        --msgbox:zorder(500)
    else
        self.ClientKernel:exitGameApp()
    end
   
end
function ErRenLandScene:SingUpNext()
    self.ClientKernel:exitGameApp(true)
end
-------------------------分割线-----------------------------

--预先查找提示牌组
function ErRenLandScene:FindOutCard()
    --print("预先查找提示牌组"..self.HandCardCount[ErRenLandDefine.MYSELF_VIEW_ID+1])
    --dump(self.m_handCardData)
    self.CurSearchOutindex=0
    if self.m_wCurrentUser==self.m_GameKernel:GetMeChairID() then
      self.SearchOutCount,self.SearchOutCardData=self.m_CardLogic:SearchOutCard(self.m_handCardData, self.HandCardCount[ErRenLandDefine.MYSELF_VIEW_ID+1],self.m_cbTurnCardData,  self.m_cbTurnCardCount )
      self.CurSearchOutindex=1
    end  
end

--自动处理出牌操作
function ErRenLandScene:AutoOutCard(isLast)
     --状态判断
    if self:GetGameStatus()~=ErRenLandDefine.GS_T_PLAY then 
        return false
    end
    if self.m_wCurrentUser~=self.m_GameKernel:GetMeChairID() then
       return false
    end
    --出牌处理
    if self.m_cbTurnCardCount==0 or self.m_bTrustee==true then
    
        if self:VerdictOutCard()==true and isLast==true then
            --出牌动作
            if self.m_bTrustee==true then
                self:BtOutCard(1)
            else
                self:BtOutCard(0)
            end
            
            return true
        else
                    --设置界面
            if self.SearchOutCount>0  then
                --设置界面
                self.m_HandCardControl:ShootCard(self.SearchOutCardData[1],true)
                self:OnSetOutCardStatus()
                --出牌动作
                if self.m_bTrustee==true then
                    self:BtOutCard(1)
                else
                    self:BtOutCard(0)
                end
                return true
            end
        end

    end
    --放弃出牌
    if self.m_cbTurnCardCount>0 then
       self:BtPassCard(0)
    end
end



--场景进入
function ErRenLandScene:onEnter()
    SoundManager:playMusicBackground("errenlandmatch/audio/BACK_MUSIC.mp3", true)
end

--场景销毁
function ErRenLandScene:onExit()
    SoundManager:stopMusicBackground()
end
function ErRenLandScene:onCleanup()
    print("场景销毁")

    display.removeSpriteFramesWithFile("errenlandmatch/gamecommon.plist","errenlandmatch/gamecommon.png")
    display.removeSpriteFrameByImageName("errenlandmatch/u_game_table.jpg") 

    self.ClientKernel:removeListenersByTable(self.GameeventHandles)
    self.ClientKernel:removeListenersByTable(self.CardeventHandles)

    self.m_Player:OnFreeInterface()
    self.m_GameKernel:OnFreeInterface()
    self.ClientKernel:cleanup() 
end
--事件管理
function ErRenLandScene:RegistEventManager()  
    
    --游戏类操作消息
    local eventListeners = eventListeners or {}
    eventListeners[ErRenLandDefine.GAME_SCENCE] = handler(self, self.OnGameScenceMsg)
    
    eventListeners[ErRenLandDefine.GAME_START] = handler(self, self.OnSubGameStatrt)
    eventListeners[ErRenLandDefine.GAME_SET_CELL_SCORE] = handler(self, self.OnSubSetCellScore)
    eventListeners[ErRenLandDefine.GAME_CALL_SCORE] = handler(self, self.OnSubCallScore)
    eventListeners[ErRenLandDefine.GAME_BANKER_INFO] = handler(self, self.OnSubBankerInfo)
    eventListeners[ErRenLandDefine.GAME_OUT_CARD] = handler(self, self.OnSubOutCard)
    eventListeners[ErRenLandDefine.GAME_PASS_CARD] = handler(self, self.OnSubPassCard)
    eventListeners[ErRenLandDefine.GAME_OVER] = handler(self, self.OnSubGameOver)
    eventListeners[ErRenLandDefine.GAME_TUOGUAN] = handler(self, self.OnSubSetTuoguan)


 
--比赛相关
    eventListeners[ErRenLandDefine.GAME_MATCH_INFO] = handler(self, self.OnSubMatchInfo)

    
    eventListeners[self.ClientKernel.Message.GR_MATCHCLIENT_STATUS] = handler(self, self.OnSubMatchWaitStart)
    eventListeners[ErRenLandDefine.GAME_MATCH_USER_READY] = handler(self, self.OnSubMatchUserReady)

    eventListeners[ErRenLandDefine.GAME_MATCH_MSG] = handler(self, self.OnSubMatchWaitMsg)
    eventListeners[ErRenLandDefine.GAME_MATCH_TIP] = handler(self, self.OnSubMatchTip)
    eventListeners[ErRenLandDefine.GAME_MATCH_RESULT] = handler(self, self.OnSubMatchResult)
    -- body
    self.GameeventHandles = self.ClientKernel:addEventListenersByTable( eventListeners )
end


--控件消息
function ErRenLandScene:ButtonMsg()

    
   --self.ButtonStart:onButtonClicked(function () self:BtStartGame() end)--开始按钮事件
   self.ButtonExit:onButtonClicked(function () self:CloseGame() end)--离开按钮事件
   self.ButtonOutCard:onButtonClicked(function ()  self:BtOutCard(1)  end) --出牌按钮事件
   self.ButtonPassCard:onButtonClicked(function ()  self:BtPassCard(1)  end)--不出按钮事件
   self.Buttontishi:onButtonClicked(function () self:BtTishi() end)--提示按钮事件
   self.ButtonCall:onButtonClicked(function () self:BtCallLand() end)--叫地主按钮
   self.ButtonNoCall:onButtonClicked(function () self:BtNoCallLand() end)--不叫按钮
   self.ButtonQiang:onButtonClicked(function () self:BtQiang() end)--抢地主按钮
   self.ButtonNoQiang:onButtonClicked(function () self:BtNoQiang() end)--不抢按钮
   self.ButtonTuoguan:onButtonClicked(function () self:BtTuoguan() end)--托管按钮
   self.ButtonQuxiaoTuoguan:onButtonClicked(function () self:BtQuxiaoTuoguan() end)--取消托管按钮
   self.ButtonShezhi:onButtonClicked(function () self:BtShezhi() end)--设置按钮


    
   -- self.ButtonStart:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonStart)end)--开始按钮按下
    self.ButtonExit:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonExit)end)--离开按钮按下
    self.ButtonOutCard:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonOutCard)end)--出牌按钮按下
    self.ButtonPassCard:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonPassCard)end)--不出按钮按下
    self.Buttontishi:onButtonPressed(function ()self:playScaleAnimation(true,self.Buttontishi)end)--提示按钮
    self.ButtonCall:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonCall)end)--叫地主按钮
    self.ButtonNoCall:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonNoCall)end)--不叫按钮
    self.ButtonQiang:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonQiang)end)--抢地主按钮
    self.ButtonNoQiang:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonNoQiang)end)--不抢按钮
    self.ButtonTuoguan:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonTuoguan)end)--托管按钮
    self.ButtonQuxiaoTuoguan:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonQuxiaoTuoguan)end)--取消托管按钮
    self.ButtonShezhi:onButtonPressed(function ()self:playScaleAnimation(true,self.ButtonShezhi)end)--设置按钮


    
    --self.ButtonStart:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonStart)end)--开始按钮抬起
    self.ButtonExit:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonExit)end)--离开按钮抬起
    self.ButtonOutCard:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonOutCard)end)--出牌按钮抬起
    self.ButtonPassCard:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonPassCard)end)--不出按钮抬起 
    self.Buttontishi:onButtonRelease(function ()self:playScaleAnimation(false,self.Buttontishi)end)--提示按钮
    self.ButtonCall:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonCall)end)--叫地主按钮
    self.ButtonNoCall:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonNoCall)end)--不叫按钮
    self.ButtonQiang:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonQiang)end)--抢地主按钮
    self.ButtonNoQiang:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonNoQiang)end)--不抢按钮
    self.ButtonTuoguan:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonTuoguan)end)--托管按钮
    self.ButtonQuxiaoTuoguan:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonQuxiaoTuoguan)end)--取消托管按钮
    self.ButtonShezhi:onButtonRelease(function ()self:playScaleAnimation(false,self.ButtonShezhi)end)--设置按钮
end
--播放叫抢地主声音
function ErRenLandScene:PalyCalllandSound(cbCallScore,chairID,Count)

    local UserItem=self.ClientKernel:SearchUserByChairID(chairID)
   -- print("播放声音")
   -- dump(UserItem)
    

    local cbGender=UserItem.cbGender
    local strGender

    if cbGender==GENDER_FEMALE then --女性
        strGender="GIRL/"
    end
    if cbGender==GENDER_MANKIND then --男性
        strGender="BOY/"
    end
    if self:GetCallLandStatus()==ErRenLandDefine.CSD_NORMAL then
        --叫地主
        if cbCallScore==1 then 
--             print("播放声音"..strGender)
            SoundManager:playMusicEffect("errenlandmatch/audio/"..strGender.."SCORE_1.mp3", false, false)
        else --不叫
            SoundManager:playMusicEffect("errenlandmatch/audio/"..strGender.."SCORE_NONE.mp3", false, false)   
        end
        --todo
    end
    if self:GetCallLandStatus()==ErRenLandDefine.CSD_SNATCHLAND then
        --抢地主
        if cbCallScore==1 then 
            if Count==1 then
                SoundManager:playMusicEffect("errenlandmatch/audio/"..strGender.."SCORE_2.mp3", false, false)
            end
            if Count==2 then
                SoundManager:playMusicEffect("errenlandmatch/audio/"..strGender.."SCORE_3.mp3", false, false)
            end
            if Count==3 then
                SoundManager:playMusicEffect("errenlandmatch/audio/"..strGender.."SCORE_3.mp3", false, false)
            end
            if Count==4 then
                SoundManager:playMusicEffect("errenlandmatch/audio/"..strGender.."IAmLord.mp3", false, false)
            end
        else --不抢
            SoundManager:playMusicEffect("errenlandmatch/audio/"..strGender.."NOQIANG.mp3", false, false)   
        end
    end
    
end

    --

    --
    --
    --

    --播放出牌声音
function ErRenLandScene:PlayAnimation(carddata,cardcount)

    --获取类型
    local cbCardType=self.m_CardLogic:GetCardType(carddata,cardcount)

    if cbCardType==ErRenLandDefine.CT_SINGLE_LINE then
        self.m_gameAni:DoCardLine() 
    end
    if cbCardType==ErRenLandDefine.CT_DOUBLE_LINE then
        self.m_gameAni:DoDoubleLine()
    end

    if cbCardType==ErRenLandDefine.CT_THREE_TAKE_ONE then
        if cardcount>=8 then
            self.m_gameAni:DoPlane()
        end
    end
    if cbCardType==ErRenLandDefine.CT_THREE_TAKE_TWO then
        if cardcount>=10 then
            self.m_gameAni:DoPlane()
        end
    end

    if cbCardType==ErRenLandDefine.CT_BOMB_CARD then
        self.m_gameAni:DoBombAni()
    end
    if cbCardType==ErRenLandDefine.CT_MISSILE_CARD then
        self.m_gameAni:DoRocket()
    end
end
--播放出牌声音
function ErRenLandScene:PlayOutCardSound(chairID,carddata,cardcount)
    local UserItem=self.ClientKernel:SearchUserByChairID(chairID)
    local cbGender=UserItem.cbGender
    local strGender
    if cbGender==GENDER_FEMALE then --女性
        strGender="errenlandmatch/audio/GIRL/"
    end
    if cbGender==GENDER_MANKIND then --男性
        strGender="errenlandmatch/audio/BOY/"
    end

    --获取类型
    local cbCardType=self.m_CardLogic:GetCardType(carddata,cardcount)

    if cbCardType==ErRenLandDefine.CT_SINGLE then
        local cbCardValue=self.m_CardLogic:GetCardValue(carddata[1])
        --构造声音
        local szSoundName=strGender.."SINGLE_"..cbCardValue..".mp3"
        SoundManager:playMusicEffect(szSoundName, false, false)
    end
    if cbCardType==ErRenLandDefine.CT_DOUBLE then
        local cbCardValue=self.m_CardLogic:GetCardValue(carddata[1])
        --构造声音
        local szSoundName=strGender.."dui"..cbCardValue..".mp3"
        SoundManager:playMusicEffect(szSoundName, false, false)
    end
    if cbCardType==ErRenLandDefine.CT_THREE then
        local cbCardValue=self.m_CardLogic:GetCardValue(carddata[1])
        --构造声音
        local szSoundName=strGender.."THREE.mp3"
        SoundManager:playMusicEffect(szSoundName, false, false)

        self:performWithDelay(function ( )  
          szSoundName=strGender.."SINGLE_"..cbCardValue..".mp3"
          SoundManager:playMusicEffect(szSoundName, false, false)
        end, 0.45)
        --构造声音
    end
    if cbCardType==ErRenLandDefine.CT_SINGLE_LINE then
        --构造声音
        local szSoundName=strGender.."SINGLE_LINE.mp3"
        SoundManager:playMusicEffect(szSoundName, false, false)
        --构造声音
    end
    if cbCardType==ErRenLandDefine.CT_DOUBLE_LINE then
        --构造声音
        local szSoundName=strGender.."DOUBLE_LINE.mp3"
        SoundManager:playMusicEffect(szSoundName, false, false)
        --构造声音
    end
    if cbCardType==ErRenLandDefine.CT_THREE_LINE then
        --构造声音
        local szSoundName=strGender.."THREE_LINE.mp3"
        SoundManager:playMusicEffect(szSoundName, false, false)
        --构造声音
    end
    if cbCardType==ErRenLandDefine.CT_THREE_TAKE_ONE then
        --构造声音
        if cardcount<8 then
            local szSoundName=strGender.."THREE_TAKE_ONE.mp3"
            SoundManager:playMusicEffect(szSoundName, false, false)
        else
            local szSoundName=strGender.."THREE_ONE_LINE.mp3"
            SoundManager:playMusicEffect(szSoundName, false, false)

            SoundManager:playMusicEffect("errenlandmatch/audio/PLANE.mp3", false, false)
        end
        
        --构造声音
    end
    if cbCardType==ErRenLandDefine.CT_THREE_TAKE_TWO then
        --构造声音
        if cardcount<10 then
            local szSoundName=strGender.."THREE_TAKE_TWO.mp3"
            SoundManager:playMusicEffect(szSoundName, false, false)
        else
            local szSoundName=strGender.."THREE_ONE_LINE.mp3"
            SoundManager:playMusicEffect(szSoundName, false, false)
            SoundManager:playMusicEffect("errenlandmatch/audio/PLANE.mp3", false, false)
        end
       
        --构造声音
    end
    if cbCardType==ErRenLandDefine.CT_FOUR_TAKE_ONE then
        --构造声音
        local szSoundName=strGender.."FOUR_TAKE_ONE.mp3"
        SoundManager:playMusicEffect(szSoundName, false, false)
        --构造声音
    end
    if cbCardType==ErRenLandDefine.CT_FOUR_TAKE_TWO then
        --构造声音
        local szSoundName=strGender.."FOUR_TAKE_TWO.mp3"
        SoundManager:playMusicEffect(szSoundName, false, false)
        --构造声音CT_BOMB_CARD
    end
    if cbCardType==ErRenLandDefine.CT_BOMB_CARD then
        --构造声音
        local szSoundName=strGender.."BOMB_CARD.mp3"
        SoundManager:playMusicEffect(szSoundName, false, false)

        SoundManager:playMusicEffect("errenlandmatch/audio/BOMB.mp3", false, false)

        
        --构造声音CT_BOMB_CARD
    end
    if cbCardType==ErRenLandDefine.CT_MISSILE_CARD then
        --构造声音
        local szSoundName=strGender.."MISSILE_CARD.mp3"
        SoundManager:playMusicEffect(szSoundName, false, false)
        --构造声音CT_BOMB_CARD
    end
end


--获取系统时间字串
function ErRenLandScene:GetSystime()
    local time=os.date("*t", os.time())
    local systime=self:timestr(time["hour"])..":"..self:timestr(time["min"])
    return systime
end

--格式时间数字
function ErRenLandScene:timestr(num)
    local str
    if num<10 then
        str="0"..num
    else
        str=""..num
    end
    return str
end

--定义按钮缩放动画函数
function ErRenLandScene:playScaleAnimation(less, pSender)
    local  scale = less and 0.9 or 1
    pSender:runAction(cc.ScaleTo:create(0.2,scale))
end

return ErRenLandScene