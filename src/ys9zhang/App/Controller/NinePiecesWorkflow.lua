CURRENT_MODULE_NAME = ...

local NinePiecesWorkflow = class("NinePiecesWorkflow")

function NinePiecesWorkflow:ctor(delegate)
    print("NinePiecesWorkflow ->ctor")
    -- 外部回调处理
    self.delegate = delegate
    --APP 单一实例
    self.app = AppBaseInstanse.NinePieceApp
	-- 为了方便测试，player分两种模式，操作界面和不操作界面
	-- 默认操作界面
    self.playerOperatingUI = true

	-- 注册事件
    self:registerEvents()

    --游戏中
    self.isPlayingGame = false

    -- 初始化所有player
    self.players = {}

    --是否空閑
    self.isIdle =false
    --空閑盤數
    self.idleRounds = 0

    --玩家USERID
    self.myUserId = GlobalUserInfo.dwUserID
    --每轮玩家操作的PID 顺序
    self.operatePids = {}
    --是否允许旁观
    self.allowLookon = false
    --当前操作玩家椅子ID
    self.currentPlayerId = -1
    --当前玩家必须带3
    self.mustHave3User = -1

    self.cellScore = 0
    --GameUtil:test()
end

function NinePiecesWorkflow:cleanup()
    if self.players then
        for k,v in pairs(self.players) do
            v:getPlayerView():stop()
            self.players[k] = nil   
        end  
        self.players = nil
    end
    self.operatePids = {}
    -- 清除所有注册事件
    self:unregisterEvents()
end

function NinePiecesWorkflow:registerEvents(  )
    -- 注册lua层事件
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    -- 初期化事件
    eventListeners[self.app.Message.Status] = handler(self, self.receiveStatusMessage)
    -- 添加游戏开始消息监听
    eventListeners[self.app.Message.Start] = handler(self, self.receiveGameStartMessage)

    --游戏类操作消息
    eventListeners[self.app.Message.OutCard] = handler(self, self.receiveOutCardMessage)
    eventListeners[self.app.Message.Pass] = handler(self, self.receivePassMessage)
    eventListeners[self.app.Message.Scene] = handler(self, self.receiveSceneMessage)
    eventListeners[self.app.Message.RoundOver] = handler(self, self.receiveRoundOverMessage)
    eventListeners[self.app.Message.BaseScore] = handler(self, self.receiveBaseScoreMessage)
    --公共消息
    local commonMsg = require("common.GameUserManagerController").Message
    eventListeners[commonMsg.GAME_UserItemAcitve] = handler(self, self.receiveUserEnterMessage)
    eventListeners[commonMsg.GAME_UserItemDelete] = handler(self, self.receiveUserLeaveMessage)
    eventListeners[commonMsg.GAME_UserItemScoreUpdate] = handler(self, self.receiveUserScoreUpdateMessage)
    eventListeners[commonMsg.GAME_UserItemStatusUpdate] = handler(self, self.receiveUserStatusMessage)
    eventListeners[commonMsg.GAME_UserItemAttribUpdate] = handler(self, self.receiveUserAttribUpdateMessage)
    
    eventListeners["GF_USER_CHAT"] = handler(self, self.receiveUserChatMessage)
    eventListeners["GF_USER_EXPRESSION"] = handler(self, self.receiveUserExpressionMessage)
    --网络高延迟消息
    --eventListeners[PublicResponseHandler.BadNetworkingMessage] = handler(self, self.handleBadNetworking)
    --网络恢复消息
    --eventListeners[PublicResponseHandler.NetworkingTurnGoodMessage] = handler(self, self.handleNetworkingTurnGood)

  
    self.eventHandles = self.app.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function NinePiecesWorkflow:unregisterEvents( )
    -- 移除所有lua层事件
    self.app.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end


function NinePiecesWorkflow:receiveUserEnterMessage(evt)
    print("NinePiecesWorkflow:receiveUserEnterMessage")
    dump(evt.para)
    local Player = import(".NinePiecesPlayer", CURRENT_MODULE_NAME) 

    self.chairId = self.chairId or self.delegate.serviceClient.userAttribute.wChairID

    local  pid = GameUtil:SwitchViewChairID(self.chairId,evt.para.wChairID)

    if evt.para and evt.para.wChairID ~= -1  then
        local player = Player.new{workflow = self,statusChangedHandler = handler(self, self.playerStatusChanged),
                                  cardGroupStatusChangedHandler = handler(self, self.playerCardGroupStatusChanged)}
        local playerData = evt.para
        
        playerData.playerId = pid
        player.operatingUI = false
        player:setPlayerData(playerData)
        self.players[pid] = player
        
        dump(player:getPlayerData())
        --初始化新加入的用户UI 环境
        self.delegate:addPlayer(player)

        if playerData.cbUserStatus == US_READY then
            if not self.isPlayingGame then
                player:onReadyPro()
            end
        elseif playerData.cbUserStatus == US_FREE or playerData.cbUserStatus == US_SIT then
            if playerData.dwUserID == self:getMyUserID() then
                self.delegate:showStartBtn(true)
            end
        end
    end
end

--是否在游戏中
function NinePiecesWorkflow:isPlaying()
    return self.isPlayingGame
end

function NinePiecesWorkflow:getMyChairID()
    return self.chairId
end

function NinePiecesWorkflow:getMyUserID()
    return self.myUserId
end


function NinePiecesWorkflow:receiveUserLeaveMessage(evt)
    print("NinePiecesWorkflow:receiveUserLeaveMessage")
    if evt.para.dwUserID == self.myUserId then
        if self.delegate.serviceClient.exitGameApp then
            self.delegate.serviceClient:exitGameApp()
        else
            self:sendStandUpRequest()
            cc.Director:getInstance():popToRootScene() 
        end
    else
        local  viewChairId = GameUtil:SwitchViewChairID(self.chairId,evt.para.wChairID)
        if self.players[viewChairId] and not self.isPlayingGame then
            self.delegate:removePlayer(self.players[viewChairId])
            self.players[viewChairId] = nil
        end
    end
end

function NinePiecesWorkflow:receiveUserScoreUpdateMessage(evt)
    for k ,v in pairs(self.players) do
        local playerData = v:getPlayerData()
        if playerData.dwUserID == evt.para.clientUserItem.dwUserID then
            if v:getPlayerView() then
                v:getPlayerView():updateHeadInfo(evt.para.clientUserItem)
            end
            break
        end
    end
end

function NinePiecesWorkflow:receiveUserAttribUpdateMessage(evt)
    print("NinePiecesWorkflow:receiveUserAttribUpdateMessage")
end

function NinePiecesWorkflow:receiveUserStatusMessage(evt)
    local  clientUserItem = evt.para.clientUserItem
    if clientUserItem.dwUserID == self:getMyUserID() then
        if clientUserItem.cbUserStatus == US_READY or clientUserItem.cbUserStatus == US_PLAYING then
            --隐藏开始按钮
            self.delegate:showStartBtn(false)
        else
            --self.delegate:showStartBtn(true)
        end
    else
       
    end

    if clientUserItem.cbUserStatus == US_READY  then
        for k ,v in pairs(self.players) do 
            if v:getPlayerData().dwUserID == clientUserItem.dwUserID and not self.isPlayingGame then
                v:onReadyPro()
                break
            end
        end
    end
end


function NinePiecesWorkflow:receiveStatusMessage(evt)
    dump(evt.para)
    if evt.para.cbGameStatus == GAME_STATUS_9zhangPLAY  then
        self.isPlayingGame = true
    end
    self.allowLookon = evt.para.cbAllowLookon
end

function NinePiecesWorkflow:receiveGameStartMessage(evt)
    self.isPlayingGame = true
    --计算玩家操作顺序
    self:calcOprateOrder(evt.para.wStartUser)
    --先清牌
    for k ,v in pairs(self.players) do
        v:getPlayerView():getOutCardView():clearOutCards()
    end
    table.sort(evt.para.cbCardData,handler(self,GameUtil.compByIndex))
    --播放发播音效
    SoundManager:playMusicEffect("ys9zhang/audio/dispatchCard.mp3", false)
    local dealDelay = 0
    for i= 1, 9 do 
        for k ,pid in pairs(self.operatePids) do
            local  player  = self.players[pid]
            if player then
                player.operatingUI  = true
                if player:getPlayerData().dwUserID == self.myUserId then
                    player:giveCard{index = evt.para.cbCardData[i], isDeal = true ,delay = dealDelay,isGameStart = true}
                else
                    player:giveCoverCard{isDeal = true ,delay = dealDelay,isGameStart = true}
                end
                dealDelay = dealDelay+0.05
            end
        end
    end

    if  evt.para.wCurrentUser then
        self.currentPlayerId = evt.para.wCurrentUser
    end

    if evt.para.wMustHave3User then
        self.mustHave3User = evt.para.wMustHave3User
    end
end

function NinePiecesWorkflow:calcOprateOrder(startChair)
    local  viewStartChair = GameUtil:SwitchViewChairID(self.chairId,startChair)
    for i = 1, 4 do
        self.operatePids[i] = (viewStartChair+i-1) % 4 
    end
end


function NinePiecesWorkflow:receiveOutCardMessage(evt)
    SoundManager:playMusicEffect("ys9zhang/audio/outCard.mp3", false)
    for k ,v in pairs(self.players) do
        v:receiveOutCardMessage(evt.para)
    end

    --自已必带出3 返回处理
    if evt.para.wOutCardUser == self:getMyChairID()  and self.mustHave3User ==self:getMyChairID() then
        --判断牌中是否有3
        if self:cardshasDiamond3(evt.para.cbCardData,evt.para.cbCardCount)  then
            self.mustHave3User = -1
        end  
    end
end

--判断牌中是否带片3
function NinePiecesWorkflow:cardshasDiamond3(cards,cardCnt)
    for i=1,cardCnt do
        local  number = cards[i]
        if number == 3 then
           return true
        end
    end
    return false
end

function NinePiecesWorkflow:receivePassMessage(evt)
    SoundManager:playMusicEffect("ys9zhang/audio/passCard.mp3", false)
    for k ,v in pairs(self.players) do
        v:receivePassMessage(evt.para)
    end
end

function NinePiecesWorkflow:getOperatePlayeId()
    return self.currentPlayerId
end

function NinePiecesWorkflow:receiveSceneMessage(evt)
    local  statusInfo = {}
    local unResolvedData = evt.para.unResolvedData
    local isFreeStatus = true
    local serviceClient = self.delegate.serviceClient
    if self.isPlayingGame or serviceClient.cbGameStatus ~=0 then --游戏还在继续还原游戏场景
        statusInfo = self.delegate:getCurClientKernel():ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusPlay")
        isFreeStatus = false
        self.isPlayingGame = true
    else
        statusInfo = self.delegate:getCurClientKernel():ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusFree")
    end

    dump(statusInfo)
    if not isFreeStatus then
         --隐藏开始按钮
        self.delegate:showStartBtn(false)
        for k ,v in pairs(self.players) do
            v.operatingUI  = true
            v:receiveStatusPlayingMessage(statusInfo)
        end

        if  statusInfo.wCurrentUser then
            self.currentPlayerId = statusInfo.wCurrentUser
        end

        if statusInfo.wMustHave3User then
            self.mustHave3User = statusInfo.wMustHave3User
        end
        
    else
        self.firstOutCardTime = statusInfo.cbTimeHeadOutCard
    end
    --底分
    self.cellScore = statusInfo.lCellScore
    self.startTime = statusInfo.cbTimeStartGame
    self.delegate:addCellScore(self.cellScore)
    -- test 
    self.startTime = 15
    self.delegate:setReadyTime(self.startTime)
end

--获取首出时间
function NinePiecesWorkflow:getFirstOutCardTime()
    return self.firstOutCardTime
end

function NinePiecesWorkflow:receiveRoundOverMessage(evt)
    SoundManager:playMusicEffect("ys9zhang/audio/roundOver.mp3", false)
    --玩家可以退出
    for k ,v in pairs(self.players) do
        if v.playerData.dwUserID == self:getMyUserID() then
            self.delegate:hideTuoGuan()
        end
        v:receiveRoundOverMessage(evt.para)
    end

    local powerInfo = evt.para.lGameBeishu 
    local index = self:getMyChairID()+1
    local isWinFlag = false
    if powerInfo[index] >=0 then
        isWinFlag = true
    end
    self.cellScore = evt.para.lCellScore 
    self.delegate:showOverView(isWinFlag,powerInfo,evt.para.lGameScore)
    self.delegate:setReadyTime(self.startTime)
    self.isPlayingGame = false
end

--收到底分消息
function NinePiecesWorkflow:receiveBaseScoreMessage( evt )
    self.cellScore = evt.para.CellScore
    self.delegate:addCellScore(self.cellScore)
end

--获取底分
function NinePiecesWorkflow:getCellScore()
    return self.cellScore
end

function NinePiecesWorkflow:checkClickCard(winPos)
    for k ,v in pairs(self.players) do
        if v:getPlayerData().dwUserID == self.myUserId then
            v:checkClickCard(winPos)
            break
        end
    end
end

function NinePiecesWorkflow:clickEndedPro()
    for k ,v in pairs(self.players) do
        if v:getPlayerData().dwUserID == self.myUserId then
            v:clickEndedPro()
            break
        end
    end
end

-- 某个玩家状态切换
function NinePiecesWorkflow:playerStatusChanged(player, event)
    self.delegate:playerStatusChanged(player, event)
end

-- 某个玩家手中的牌发生变化
function NinePiecesWorkflow:playerCardGroupStatusChanged(player)  
    --self.delegate:playerCardGroupStatusChanged(player,cardGroupIndex,cardGroupStatus,showBlueBtn)  
end


function NinePiecesWorkflow:sendReadyRequest()
    for k ,v in pairs(self.players) do
        if v:getPlayerData().dwUserID == self.myUserId then
            v:sendReadyRequest()
            break
        end
    end
end

function NinePiecesWorkflow:sendStandUpRequest() 
    for k ,v in pairs(self.players) do
        if v:getPlayerData().dwUserID == self.myUserId then
            v:sendStandUpRequest()
            break
        end
    end
end

function NinePiecesWorkflow:playerDecidingCountDownEnd(pid)
    print("NinePiecesWorkflow:playerDecidingCountDownEnd pid="..pid)
    if self.players[pid] then
        self.players[pid]:DecidingCountDownEnd()
    end
end

--点击不出
function NinePiecesWorkflow:pass() 
    print("NinePiecesWorkflow:pass")
    for k ,v in pairs(self.players) do
        if v:getPlayerData().dwUserID == self.myUserId then
            v:pass()
            break
        end
    end
end

function NinePiecesWorkflow:prompt() 
    for k ,v in pairs(self.players) do
        if v:getPlayerData().dwUserID == self.myUserId then
            v:prompt()
            break
        end
    end
end

function NinePiecesWorkflow:outCard() 
    for k ,v in pairs(self.players) do
        if v:getPlayerData().dwUserID == self.myUserId then
            v:outCard()
            break
        end
    end
end

function NinePiecesWorkflow:modifyOprateStatus(args)
   self.delegate:modifyOprateStatus(args)
end

function NinePiecesWorkflow:getPlayerByChairId(chairId)
    for k ,v in pairs(self.players) do
        local playerData = v:getPlayerData()
        if playerData.wChairID == chairId then
            return v 
        end
    end
    return nil
end

--关连托管界面
function NinePiecesWorkflow:tuoGuanPro(isOutTime)
    self.delegate:tuoGuanPro(isOutTime)
end

--主动托管
function NinePiecesWorkflow:autoTuoGuan()
    for k ,v in pairs(self.players) do
        if v:getPlayerData().dwUserID == self.myUserId then
            v:autoTuoGuan()
            break
        end
    end
end

--一张牌显示托管按钮
function NinePiecesWorkflow:canTuoguanMySelf()
    self.delegate:showBtnTuoGuan()
end

--取消托管
function NinePiecesWorkflow:cancelTuoGuan()
    for k ,v in pairs(self.players) do
        if v:getPlayerData().dwUserID == self.myUserId then
            v:cancelTuoGuan()
            break
        end
    end
end

--退出房间
function NinePiecesWorkflow:onExitGameRoom()
    if self.delegate.serviceClient.exitGameApp then
        self.delegate.serviceClient:exitGameApp()
    else
        self:sendStandUpRequest()
        cc.Director:getInstance():popToRootScene() 
    end
end

function NinePiecesWorkflow:receiveUserChatMessage(evt)
    for k ,v in pairs(self.players) do
        local playerData = v:getPlayerData()
        if playerData.dwUserID == evt.para.dwSendUserID and v:getPlayerView() then
            v:getPlayerView():sayMessage{ messageType = 0, message = evt.para.szChatString}
            if evt.para.bShortMsgIndex ~= 255 then
                if playerData.cbGender == GENDER_FEMALE then
                    SoundManager:playMusicEffect(string.format("ys9zhang/woman/0_phrase_%d.mp3",evt.para.bShortMsgIndex+1), false)
                elseif playerData.cbGender == GENDER_MANKIND then
                    SoundManager:playMusicEffect(string.format("ys9zhang/man/1_phrase_%d.mp3",evt.para.bShortMsgIndex+1), false)
                end
            end
            break
        end
    end
end

function NinePiecesWorkflow:receiveUserExpressionMessage(evt)
     for k ,v in pairs(self.players) do
        local playerData = v:getPlayerData()
        if playerData.dwUserID == evt.para.dwSendUserID and v:getPlayerView() then
            v:getPlayerView():sayMessage{ messageType = 1, message = evt.para.wItemIndex}
            break
        end
    end
end

return NinePiecesWorkflow