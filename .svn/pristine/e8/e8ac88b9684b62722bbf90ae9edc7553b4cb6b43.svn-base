-- ninePiece 
local CURRENT_MODULE_NAME = ...

local ninePieceScene  = class("ninePiece", function()
    return display.newScene("ninePieceScene")
end)

--座位
local PlayerSeatView = require("common.Widget.PlayerSeatView")
-- 桌子
local PokerTableView = require("common.Widget.PokerTableView")
--聊天控件
local talkWidget = require("common.Widget.TalkWidget")
--结算界面
local overView = import("..View.NPRoundOverView")

ninePieceScene.bg = "ys9zhang/u_game_table.jpg"

local ClientKernel = require("common.ClientKernel")

local NpOperateBtnView = import("..View.NPOperateBtnView")

--桌子上，4个人的位置
local PlayerSeatPosArray = {
    cc.p(display.cx, display.top - 90),
    cc.p(display.cx - 428, display.cy+70),
    cc.p(display.cx - 428, display.bottom + 50),--cc.p(display.cx - 428, display.cy-280),
    cc.p(display.cx*2 - 140, display.cy+70),
}

local MainUITag = 
{
    BgTag = 4,
    BtnExitTag = 24,
    LabelTimeTag = 25,
    BtnTalkTag = 26,
    ImageCellScoreTag = 61,
    LabelCellScoreTag = 62,
    BtnTuoGuanTag = 100,
    BtnSettingTag = 101,
}

function ninePieceScene:ctor(args)
	print("ninePieceScene:ctor")
	self:setNodeEventEnabled(true)
	if args.gameClient then
		self.gameClient = args.gameClient
		self.serviceClient = ClientKernel.new(self.gameClient,AppBaseInstanse.NinePieceApp.notificationCenter)
		
		self.workflow = import("..Controller.NinePiecesWorkflow", CURRENT_MODULE_NAME).new(self)
		
		self.ResponseHandler = import("..Command.NinePiecesResponseHandler", CURRENT_MODULE_NAME).new(self.gameClient)
	end

	self:loadUI()

	--加载牌的资源
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Common/AnimationCard.ExportJson")
    --一局结算效果资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Common/OverLoseAnimation.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Common/OverWinAnimation.ExportJson")

    --是否是超时托管
    self.isOutTime = false

    self.preloadCount = 1
end

--加载声音资源
function ninePieceScene:loadSoundRes()
    audio.preloadSound("ys9zhang/audio/dispatchCard.mp3")
    audio.preloadSound("ys9zhang/audio/outCard.mp3")
    audio.preloadSound("ys9zhang/audio/passCard.mp3")
    audio.preloadSound("ys9zhang/audio/ready.mp3")
    audio.preloadSound("ys9zhang/audio/roundOver.mp3")
    audio.preloadSound("ys9zhang/audio/selectCard.mp3")
    audio.preloadSound("ys9zhang/audio/waring.mp3")
    
    --[[for i= 1,22 do
        audio.preloadSound(string.format("ys9zhang/woman/0_phrase_%d.mp3",i))
        audio.preloadSound(string.format("ys9zhang/man/1_phrase_%d.mp3",i))
    end]]

    --加载男女常用语音效
    self.preloadCount = 1
    
end

function ninePieceScene:onCleanup()
    -- 这个schedule必须释放掉
    if self.schedulerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerId)
        self.schedulerId = nil
    end
    self.workflow:cleanup()
    self.workflow = nil  
    -- 释放音效资源
    self:unloadSoundRes()
    self.serviceClient:cleanup() 
end

function ninePieceScene:unloadSoundRes()
    for i=1,self.preloadCount do
        audio.unloadSound(string.format("ys9zhang/woman/0_phrase_%d.mp3",i))
        audio.unloadSound(string.format("ys9zhang/man/1_phrase_%d.mp3",i))
    end

    audio.unloadSound("ys9zhang/audio/dispatchCard.mp3")
    audio.unloadSound("ys9zhang/audio/outCard.mp3")
    audio.unloadSound("ys9zhang/audio/passCard.mp3")
    audio.unloadSound("ys9zhang/audio/ready.mp3")
    audio.unloadSound("ys9zhang/audio/roundOver.mp3")
    audio.unloadSound("ys9zhang/audio/selectCard.mp3")
    audio.unloadSound("ys9zhang/audio/waring.mp3")
end

function ninePieceScene:getCurClientKernel()
    return self.serviceClient
end

function ninePieceScene:onEnter()
	self.ResponseHandler:registerPlayHandlers()
    self:loadSoundRes()
end

function ninePieceScene:onExit()
	self.ResponseHandler:unregisterPlayHandlers()
end

function ninePieceScene:loadUI()

	--加载JSON
    self.mainWidget = GameUtil:widgetFromCocostudioFile("ys9zhang/gameScene"):addTo(self)

    self.mainWidget:setTouchEnabled(true)
    self.mainWidget:addTouchEventListener(handler(self,self.panelOnTouched))

    local  bg = self.mainWidget:getChildByTag(MainUITag.BgTag)
    local scale = display.height/bg:getContentSize().height
    bg:setScale(scale)

    self.operateBtnView = NpOperateBtnView.new{ parent = self.mainWidget,
                                   operateBtnHandler = handler(self,self.onOperateBtnPressed)}

	 --游戏桌子
    self.pokerTable = PokerTableView.new(PlayerSeatPosArray):addTo(self)


    --开始按钮
    self.btnStart = ccui.Button:create():addTo(self)
    self.btnStart:loadTextureNormal("ys9zhang/u_game_btn_start.png",0)
    self.btnStart:loadTexturePressed("ys9zhang/u_game_btn_start.png",0)
    self.btnStart:setPosition(cc.p(display.cx,display.cy - 200))
    self.btnStart:addTouchEventListener(handler(self, self.startGame))
    self.btnStart:setVisible(false)
    --开始文字
    local textStart = ccui.ImageView:create()
    textStart:loadTexture("ys9zhang/u_game_text_start.png",0)
    textStart:setPosition(cc.p(self.btnStart:getContentSize().width/2,self.btnStart:getContentSize().height/2))
    self.btnStart:addChild(textStart)

    local btnExit = self.mainWidget:getChildByTag(MainUITag.BtnExitTag)
    btnExit:addTouchEventListener(handler(self, self.exitGame)) 

    local btnTalk = self.mainWidget:getChildByTag(MainUITag.BtnTalkTag)
    btnTalk:addTouchEventListener(handler(self, self.onClickTalk)) 

    local btnSetting = self.mainWidget:getChildByTag(MainUITag.BtnSettingTag)
    btnSetting:addTouchEventListener(handler(self, self.onClickSetting))


    self.btnTuoguan = self.mainWidget:getChildByTag(MainUITag.BtnTuoGuanTag)
    self.btnTuoguan:addTouchEventListener(handler(self, self.onClickTuoguan)) 
    self.btnTuoguan:setVisible(false)

    self.lableTime = self.mainWidget:getChildByTag(MainUITag.LabelTimeTag)

    --当前时间
    self.sTimeNow = {
            wHour = tonumber(os.date("%H")),
            wMin = tonumber(os.date("%M")),
    }
    self.lableTime:setString(string.format("%02d:%02d",self.sTimeNow.wHour,self.sTimeNow.wMin))
    if not self.schedulerId then
        self.schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.refreshsystemtime), 1 , false)
    end
    --对时间隔
    self.timeInterVal = 0

    --准备时间
    self.timeStart = 0
    --底分
    local scoreBg =  self.mainWidget:getChildByTag(MainUITag.ImageCellScoreTag)
    self.labelScore = scoreBg:getChildByTag(MainUITag.LabelCellScoreTag)

    --准备到计时
    self.leftTime = ccui.ImageView:create()
    self.leftTime:loadTexture("ys9zhang/u_game_icon_clock.png",0)
    self.leftTime:setVisible(false)
    self.leftTime:setPosition(cc.p(display.cx,display.cy))
    
    self:addChild(self.leftTime)

    self.labelTime = cc.LabelAtlas:_create("0:","ys9zhang/u_game_num_clock.png",20,27,string.byte("0"))
    self.labelTime:align(display.CENTER, self.leftTime:getContentSize().width/2,self.leftTime:getContentSize().height/2-5)
    self.leftTime:addChild(self.labelTime)

end

function ninePieceScene:showBtnTuoGuan()
    self.btnTuoguan:setVisible(true)
end

--关连底分
function ninePieceScene:addCellScore(cellScore)
    self.labelScore:setString(tostring(cellScore))
end

function ninePieceScene:setReadyTime(time)
    self.startTime = time
end

function ninePieceScene:refreshsystemtime(dt)
    --准备倒计时和音效
    if not self.workflow:isPlaying()  then
        if self.startTime and self.startTime >=1 then
            self.startTime = self.startTime - 1
            if self.startTime <= 5 then
                if not self.playReady then
                    self.playReady = true
                    SoundManager:playMusicEffect("ys9zhang/audio/ready.mp3", true, true)
                end
            end
            if not self.leftTime:isVisible() then
                self.leftTime:setVisible(true)
            end
            self.labelTime:setString(tostring(self.startTime))
        else
            self.leftTime:setVisible(false)
            SoundManager:stopMusicEffect("ys9zhang/audio/ready.mp3")
        end
    else
        self.leftTime:setVisible(false)
        SoundManager:stopMusicEffect("ys9zhang/audio/ready.mp3")
    end
    self.timeInterVal = self.timeInterVal + 1 
    --一分钟对时
    if self.timeInterVal == 60 then
        self.sTimeNow = {
            wHour = tonumber(os.date("%H")),
            wMin = tonumber(os.date("%M")),
        }
        self.timeInterVal = 0
    end
    if self.sTimeNow.wMin <= 0 then
        self.lableTime:setString(string.format("%02d:%02d",self.sTimeNow.wHour-1,59))
    else
        self.lableTime:setString(string.format("%02d:%02d",self.sTimeNow.wHour,self.sTimeNow.wMin))
    end

    --加载声音资源
    local  cur = self.preloadCount
    if self.preloadCount ~=22 then
        if 22- cur >= 5 then
            for i= cur,cur+4 do
                audio.preloadSound(string.format("ys9zhang/woman/0_phrase_%d.mp3",i))
                audio.preloadSound(string.format("ys9zhang/man/1_phrase_%d.mp3",i))
            end
            self.preloadCount = self.preloadCount + 5
        else
            for i= cur,22-cur do
                audio.preloadSound(string.format("ys9zhang/woman/0_phrase_%d.mp3",i))
                audio.preloadSound(string.format("ys9zhang/man/1_phrase_%d.mp3",i))
            end
            self.preloadCount = 22
        end
    end
end

function ninePieceScene:panelOnTouched( sender, touchType)
    if touchType == TOUCH_EVENT_ENDED then
        --屏幕有点击，退出空闲状态
        if self.talk and self.talk:isVisible() then
            self.talk:setVisible(false)
        end
    end
end


function ninePieceScene:showStartBtn(isvisible)
    self.btnStart:setVisible(isvisible)
    if not isvisible then
        --已经准备倒计时为0 
        self.startTime = 0

        self.leftTime:setVisible(false)

        SoundManager:stopMusicEffect("ys9zhang/audio/ready.mp3")
    end
end

function ninePieceScene:startGame(sender, touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, sender)
    else
        GameUtil:playScaleAnimation(false, sender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        self.workflow:sendReadyRequest()
        self.startTime = 0
        --隐藏倒计时
        self.leftTime:setVisible(false)
        --关闭音效
        SoundManager:stopMusicEffect("ys9zhang/audio/ready.mp3")
    end
end

function ninePieceScene:exitGame(sender, touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, sender)
    else
        GameUtil:playScaleAnimation(false, sender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        if not self.workflow:isPlaying() then
            if self.serviceClient.exitGameApp then
                self.serviceClient:exitGameApp()
            else
                self.workflow:sendStandUpRequest()
                cc.Director:getInstance():popToRootScene() 
            end
        else
            local dataMsgBox = {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OKCANCEL,
                msgInfo="您当前正在游戏中，退出将会进入系统托管，是否确定退出？",
                callBack=function(ret)
                    if ret == MSGBOX_RETURN_OK then
                        if self.serviceClient.exitGameApp then
                            self.serviceClient:exitGameApp()
                        else
                            self.workflow:sendStandUpRequest()
                            cc.Director:getInstance():popToRootScene() 
                        end
                    end
                end
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        end
    end
end

function ninePieceScene:onClickTalk(sender, touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, sender)
    else
        GameUtil:playScaleAnimation(false, sender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        if not self.talk then
            self.talk = talkWidget.new(self.serviceClient):addTo(self)
            
            self.talk:setPosition(cc.p(display.width-408,self.talk:getContentSize().height/2+55))
        end
        if not self.talk:isVisible() then
            self.talk:setVisible(true)
        end
    end
end

function ninePieceScene:onClickSetting(sender, touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, sender)
    else
        GameUtil:playScaleAnimation(false, sender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        local settingView = require("ys9zhang.App.View.NPSettingView").new()
        settingView:setPosition(cc.p(display.cx,display.cy))
        self:addChild(settingView)
    end
end

function ninePieceScene:onClickTuoguan(sender, touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, sender)
    else
        GameUtil:playScaleAnimation(false, sender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        if not self.isOutTime then
            self:tuoGuanPro(false)
            self.workflow:autoTuoGuan()
        end
    end
end


--加入玩家
function ninePieceScene:addPlayer(player)
    local  playerData = player:getPlayerData()
    print(string.format("[ninePieceScene], [玩家加入，玩家userID %d, 玩家名字 %s]",playerData.dwUserID,playerData.szNickName))

    local  isMySelf = false

    if self.workflow:getMyUserID() == playerData.dwUserID then
        print("is my Self")
        isMySelf = true
    end

    --self.pokerTable:addPlayer(playerData.playerId, isMySelf)
    --新建座位视图
    local seat = PlayerSeatView.new{id = playerData.playerId,
                                    userID = playerData.dwUserID,
                                        name = playerData.szNickName, 
                                        isMyself = isMySelf,                            
                                        countDownTimeInterval = 30,
                                        countDownHandler = handler(self, self.playerDecidingCountDownEnd),
                                        clickHeadHandler = handler(self,self.clickHeadHandler),
                                        vipLevel = playerData.dwVipLevel,
                                        headId   = playerData.wFaceID,
                                        score    = playerData.lScore
                                       }:addTo(self.pokerTable)

    if isMySelf then
        seat:setLocalZOrder(2)
    end
    dump(seat)
    print("pid "..playerData.playerId)
    seat:setPos(PlayerSeatPosArray[playerData.playerId+1])
    --关联上排好座位的视图和玩家
    player:setPlayerView(seat,isMySelf)

    --重排所有玩家
    --[[for i,v in pairs(self.workflow.players) do
        --除自己以为的玩家重排位置
        if tonumber(v:getPlayerData().playerId) ~= self.workflow:getMyId() then
            v:getPlayerView():setPos(positions[tonumber(v:getPlayerData().playerId)])
            --重置CHIPSVIEW 位置
            v:resetChipsView()
        end
    end]]
end

function ninePieceScene:removePlayer( player )
    player:getPlayerView():stop()

    player:getPlayerView():removeFromParent()
end

--玩家操作倒计时结束后回调
function ninePieceScene:playerDecidingCountDownEnd(seatView)	
    local pid = tonumber(seatView.id)
    --玩家操作超时处理
    self.workflow:playerDecidingCountDownEnd(pid)
end

--点击玩家头像回调事件
function ninePieceScene:clickHeadHandler(seat,userId)
    if not self.userInfoWidget then
        local userInfoWidget = require("ys9zhang.App.View.UserInfoWidget")
        self.userInfoWidget = userInfoWidget.new(self, userInfoWidget.TABLE_TYPE)
    end
    local seatPos = PlayerSeatPosArray[seat.id+1]
    local userInfo = self.serviceClient:SearchUserByUserID(userId)
    if userInfo then
        self.userInfoWidget:updateUserInfo(userInfo,seatPos.x-120,seatPos.y-45)
        self.userInfoWidget:showUserInfo(true)
    end
end

function ninePieceScene:onOperateBtnPressed(command )
    if  command == "pass" then -- 不出
        self.workflow:pass()
    elseif command == "prompt" then --提示
        self.workflow:prompt()
    elseif command == "outCard" then --出牌
        self.workflow:outCard()
    end
end

--玩家状态切换
function ninePieceScene:playerStatusChanged(player, event)
    --自已
    if self.workflow:getMyUserID() == tonumber(player.playerData.dwUserID) then
        --切换到Idle状态处理
        if  event.name == "end" then
            self.args= { isShow = false,isCanPass = false,isCanPlay = false }
            self.operateBtnView:setBottomBtnBarShow(self.args)
            self.operateBtnView:reSet()
        --切换到deciding 状态处理
        elseif  event.name == "decide" then 
            --隱藏藍色操作欄，顯示黃色操作按紐
            local  isAutoPass= 0
            for k,autoPass in pairs(event.args) do
                isAutoPass =  autoPass
            end
            
            if not player:getTuoGuanFlag() then
                if isAutoPass ~=0 then
                    --不能出牌情况，大住上，封牌
                    self.args= { isShow = false,isCanPass = false,isCanPlay = false}
                else
                    if player:getCanPassFalg() then
                        --不能过牌
                        self.args= { isShow = true,isCanPass = false,isCanPlay = false}
                    else
                        --能过牌
                        self.args= { isShow = true,isCanPass = true,isCanPlay = false}
                    end
                end
            else
                --托管不显示操作按钮
                self.args= { isShow = false,isCanPass = false,isCanPlay = false}
            end

            self.operateBtnView:setBottomBtnBarShow(self.args)     
        end
    end
end

function ninePieceScene:modifyOprateStatus(args)
    self.operateBtnView:modifyOprateStatus(args)
end

--托管界面 --是超时托管
function ninePieceScene:tuoGuanPro(isOutTime)
    self.isOutTime = isOutTime
    if not self.tuoGuanNode then
        self.tuoGuanNode = ccui.ImageView:create()
        self.tuoGuanNode:loadTexture("ys9zhang/u_game_icon_hosting.png",0)
        self.tuoGuanNode:setPosition(cc.p(display.cx - 30,160))
        self:addChild(self.tuoGuanNode)

        local btnCancelTuoGuan = ccui.Button:create()
        btnCancelTuoGuan:loadTextureNormal("ys9zhang/u_game_btn_canceltg.png",0)
        btnCancelTuoGuan:loadTexturePressed("ys9zhang/u_game_btn_canceltg.png",0)
        btnCancelTuoGuan:setPosition(cc.p(self.tuoGuanNode:getContentSize().width/2+30,-10))
        btnCancelTuoGuan:addTouchEventListener(handler(self, self.onClickCancelTuoGuan))
        self.tuoGuanNode:addChild(btnCancelTuoGuan)
    end

    if not self.tuoGuanNode:isVisible() then
        self.tuoGuanNode:setVisible(true)
    end
end

--隐藏托管
function ninePieceScene:hideTuoGuan()
    if self.tuoGuanNode then
        self.tuoGuanNode:setVisible(false)
    end
    self.btnTuoguan:setVisible(false) 
end

--取消托管
function ninePieceScene:onClickCancelTuoGuan(pSender,touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        self.tuoGuanNode:setVisible(false)
        --取消托管
        self.workflow:cancelTuoGuan()
    end
end

function ninePieceScene:showOverView(isWin,powerInfo,scoreInfo)
    --self.isWin = isWin
    --self.powerInfo = powerInfo
    --self.scoreInfo = scoreInfo 
    local overView = overView.new{isWin = isWin,workflow = self.workflow, powerInfo = powerInfo,scoreInfo = scoreInfo }
    overView:setPosition(cc.p(display.cx,display.cy))
    overView:setVisible(false)
    self:addChild(overView,999)
    local actionArray = {}
    local delay = cc.DelayTime:create(1.0)
    table.insert(actionArray,delay)
    local call = cc.CallFunc:create(handler(self, self.realShow))
    table.insert(actionArray,call)
    overView:runAction(cc.Sequence:create(actionArray))
    --可以播放
    self.playReady = false
end

function ninePieceScene:realShow(pSender)
    pSender:setVisible(true)
end

return ninePieceScene