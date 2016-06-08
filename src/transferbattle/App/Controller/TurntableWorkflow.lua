CURRENT_MODULE_NAME = ...

local TurntableWorkflow = class("TurntableWorkflow")

function TurntableWorkflow:ctor(delegate)
    print("TurntableWorkflow ->ctor")
    -- 外部回调处理
    self.delegate = delegate
    --APP 单一实例
    self.app = AppBaseInstanse.TurntableApp
	-- 为了方便测试，player分两种模式，操作界面和不操作界面
	-- 默认操作界面
    self.playerOperatingUI = true

	-- 注册事件
    self:registerEvents()

    --游戏中
    self.isPlayingGame = false

    -- 初始化所有player
    self.players = {}
    --申请的所有庄家椅子数组
    self.bankerChardIds = {}
    --
    --self.bankerChairArray = cc.Array:create()
    --当前庄家USERID
    self.curBankerUserId = -1
    --所有开出的动物记录
    self.recordInfo ={}
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
    -- 网络命令发送
    self.command = import("..Command.TurntableCommand", CURRENT_MODULE_NAME).new(self.delegate:getCurClientKernel())
end

function TurntableWorkflow:cleanup()
    if self.players then
        for k,v in pairs(self.players) do
            self.players[k] = nil   
        end  
        self.players = nil
    end
    self.operatePids = {}
    -- 清除所有注册事件
    self:unregisterEvents()
end

function TurntableWorkflow:registerEvents(  )
    -- 注册lua层事件
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    -- 初期化事件
    eventListeners[self.app.Message.Status] = handler(self, self.receiveStatusMessage)
    -- 添加游戏开始消息监听
    eventListeners[self.app.Message.Start] = handler(self, self.receiveGameStartMessage)
    eventListeners[self.app.Message.Free] = handler(self, self.receiveGameFreeMessage)
    --游戏类操作消息
    eventListeners[self.app.Message.Bet] = handler(self, self.receiveUserBetMessage)
    eventListeners[self.app.Message.BetFail] = handler(self, self.receiveBetFailedMessage)
    eventListeners[self.app.Message.Scene] = handler(self, self.receiveSceneMessage)
    eventListeners[self.app.Message.RoundOver] = handler(self, self.receiveRoundOverMessage)
    eventListeners[self.app.Message.ApplyBanker] = handler(self, self.receiveApplyBankerMessage)
    eventListeners[self.app.Message.CancelBanker] = handler(self, self.receiveCancelBankerMessage)
    eventListeners[self.app.Message.QiangBanker] = handler(self, self.receiveQiangBankerMessage)
    eventListeners[self.app.Message.WaitBanker] = handler(self, self.receiveWaitBankerMessage)
    eventListeners[self.app.Message.GameRecord] = handler(self, self.receiveGameRecordMessage)
    eventListeners[self.app.Message.ChangeBanker] = handler(self, self.receiveChangeBankerMessage)

    --银行操作成功/失败
    eventListeners[self.app.Message.InsureSuccess] = handler(self,self.receiveInsureSuccessMessage)
    eventListeners[self.app.Message.InsureFailure] = handler(self,self.receiveInsureFailureMessage)

    --公共消息
    local commonMsg = require("common.GameUserManagerController").Message
    eventListeners[commonMsg.GAME_UserItemAcitve] = handler(self, self.receiveUserEnterMessage)
    eventListeners[commonMsg.GAME_UserItemDelete] = handler(self, self.receiveUserLeaveMessage)
    --分数变化
    eventListeners[commonMsg.GAME_UserItemScoreUpdate] = handler(self, self.receiveUserScoreUpdateMessage)
    --eventListeners[commonMsg.GAME_UserItemStatusUpdate] = handler(self, self.receiveUserStatusMessage)
    --eventListeners[commonMsg.GAME_UserItemAttribUpdate] = handler(self, self.receiveUserAttribUpdateMessage)
    
    eventListeners["GF_USER_CHAT"] = handler(self, self.receiveUserChatMessage)
    eventListeners["GF_USER_EXPRESSION"] = handler(self, self.receiveUserExpressionMessage)
    --网络高延迟消息
    --eventListeners[PublicResponseHandler.BadNetworkingMessage] = handler(self, self.handleBadNetworking)
    --网络恢复消息
    --eventListeners[PublicResponseHandler.NetworkingTurnGoodMessage] = handler(self, self.handleNetworkingTurnGood)

  
    self.eventHandles = self.app.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function TurntableWorkflow:unregisterEvents( )
    -- 移除所有lua层事件
    self.app.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end


function TurntableWorkflow:receiveUserEnterMessage(evt)
    --print("TurntableWorkflow:receiveUserEnterMessage"..evt.para.szNickName)
    --dump(evt.para)
    --玩家桌位号
    self.chairId = self.chairId or self.delegate.serviceClient.userAttribute.wChairID
    local index = self:checkInPlayerList(evt.para.dwUserID)
    if index == -1 and evt.para.wChairID >=0 then
        playerData ={}
        playerData.dwUserID = evt.para.dwUserID
        playerData.szNickName = evt.para.szNickName
        playerData.initScore  = evt.para.lScore --进入桌子的初始金币数
        playerData.lScore  = evt.para.lScore
        playerData.wChairID = evt.para.wChairID
        table.insert(self.players,playerData)
    end
    --按椅子ID 升序排
    if #self.players >=2 then
        table.sort(self.players,handler(self,self.sortByCharid))
    end
    --刷新玩家列表
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.UpdatePlayerList,
            para = {},
        })
end

function TurntableWorkflow:sortByCharid(item1,item2)
    return item1.wChairID < item2.wChairID
end
--刷新玩家列表项 
function TurntableWorkflow:receiveUserScoreUpdateMessage(evt)
    --刷新庄家列表中的每一项数据
    self.delegate:refreshBankerItemInfo(evt.para.clientUserItem)
    for k , v in pairs(self.players) do
        if type(v) =="table" and v.wChairID == evt.para.clientUserItem.wChairID then
            v.lScore = evt.para.clientUserItem.lScore
            --刷新玩家列表的中每一项数据
            AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
                    name = AppBaseInstanse.TurntableApp.Message.UpdatePlayerListItem,
                    para = v,
                })
            break
        end
    end
end

function TurntableWorkflow:checkInPlayerList(dwUserID)
   local index = -1
   for k ,v in pairs(self.players) do
       if type(v) =="table" and v.dwUserID == dwUserID then
            index = k
            break
       end 
   end
   return index
end

--是否在游戏中
function TurntableWorkflow:isPlaying()
    return self.isPlayingGame
end

function TurntableWorkflow:getMyChairID()
    return self.chairId
end

function TurntableWorkflow:getMyUserID()
    return self.myUserId
end

function TurntableWorkflow:getPlayers()
    return self.players
end


function TurntableWorkflow:receiveUserLeaveMessage(evt)
    print("NinePiecesWorkflow:receiveUserLeaveMessage"..evt.para.szNickName)
    if evt.para.dwUserID == self.myUserId then
        if self.delegate.serviceClient.exitGameApp then
            self.delegate.serviceClient:exitGameApp()
        else
            --TO DO 发站立包
            cc.Director:getInstance():popToRootScene() 
        end
    else
        local index = self:checkInPlayerList(evt.para.dwUserID)
        if index ~=-1 then
            print("remove index"..index)
            table.remove(self.players,index)
            --刷新玩家列表
            AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
                name = AppBaseInstanse.TurntableApp.Message.DeletePlayerItem,
                para = {dwUserID = evt.para.dwUserID},
            })
        end

        --判断离开玩家是否在庄家列表
        local pos = table.indexof(self.bankerChardIds,evt.para.wChairID)
        if pos then
            table.remove(self.bankerChardIds,pos)
            --重新初化庄家列表
            self.delegate:updatBankerList(self.bankerChardIds) 
        end
    end
end

function TurntableWorkflow:receiveStatusMessage(evt)
    dump(evt.para)
    if evt.para.cbGameStatus == GAME_STATUS_PLAY  then
        self.isPlayingGame = true
    end
    self.allowLookon = evt.para.cbAllowLookon
end

--开始下注
function TurntableWorkflow:receiveGameStartMessage(evt)
    self.isPlayingGame = true
    if SessionManager:sharedManager():getEffectOn() then
        --ccexp.AudioEngine:play2d("transferbattle/audio/gamestart.mp3", false)
        --ccexp.AudioEngine:play2d("transferbattle/audio/pleasebet.mp3", false)
        SoundManager:playMusicEffect("transferbattle/audio/gamestart.mp3", false)
        SoundManager:playMusicEffect("transferbattle/audio/pleasebet.mp3", false)
    end
    self.delegate:receiveGameStartPro(evt.para)
end

--游戏空闲消息处理
function TurntableWorkflow:receiveGameFreeMessage(evt)
    dump(evt.para)
    self.delegate:receiveGameFreePro(evt.para)
end


function TurntableWorkflow:receiveSceneMessage(evt)
    --print("TurntableWorkflow:receiveSceneMessage")
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
    --print("TurntableWorkflow:receiveSceneMessage2222222222"..statusInfo.wBankerUser)
    --dump(statusInfo)
    --当前庄家椅子ID
    self.curBankerUserId = statusInfo.wBankerUser
    --记录上庄条件
    self.lApplyBankerCondition = statusInfo.lApplyBankerCondition
    --区域限制条件
    self.lAreaLimitScore = statusInfo.lAreaLimitScore
    --界面收到场景消息处理
    self.delegate:receiveSceneMessagePro(statusInfo,isFreeStatus)
    --刷新界面庄家信息
    self.delegate:refreshPlayerInfo()
    self.delegate:refreshBankerInfo()
end

function TurntableWorkflow:isCanApplyBanker(lScore)
    return self.lApplyBankerCondition <= lScore
end

--收到申请做庄消息处理
function TurntableWorkflow:receiveApplyBankerMessage(evt)
    print("receiveApplyBankerMessage"..self.curBankerUserId)
    local chairId = evt.para.wApplyUser
    local pos = table.indexof(self.bankerChardIds,chairId)
    if not pos and self.curBankerUserId ~= chairId  then
        table.insert(self.bankerChardIds,chairId)
        --自已申请做庄家，
        if chairId == self.chairId then
            self.delegate:refreshApplyBankerState(true)
        end
    end
    --重新初化庄家列表
    self.delegate:updatBankerList(self.bankerChardIds)
end

function TurntableWorkflow:getCurBankerUserId()
    return self.curBankerUserId
end

function TurntableWorkflow:receiveUserBetMessage(evt)
    --print("receiveUserBetMessage")
    --dump(evt.para)
    --播放下注音效
    self.delegate:updateTotalChipsInfo(evt.para) 
end

--收到下注结束消息处理
function TurntableWorkflow:receiveRoundOverMessage(evt)
    self.delegate:setGameState(GAME_STATE_BETOVER)
    self.delegate:receiveRoundOverMessage(evt.para)
end

function TurntableWorkflow:addRecordIem(cardIndex)
    table.insert(self.recordInfo,cardIndex)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.UpdateRecord,
            para = {},
    })
end


function TurntableWorkflow:receiveCancelBankerMessage(evt)
    print("取消庄家")
    dump(evt.para)
    local chairId = self:getChairIdByNick(evt.para.szCancelUser)
    local pos = table.indexof(self.bankerChardIds,chairId)
    if pos then
        table.remove(self.bankerChardIds,pos)
        dump(self.bankerChardIds)
        --重新初化庄家列表
        self.delegate:updatBankerList(self.bankerChardIds)
        --自已取消庄家
        if chairId == self.chairId then
            self.delegate:refreshApplyBankerState(false)
        end
    end
end

--通过昵称获取椅子ID
function TurntableWorkflow:getChairIdByNick(nick)
    for k, player in pairs(self.players) do
        if player.szNickName == nick then
            return player.wChairID
        end
    end
    return -1
end

function TurntableWorkflow:receiveQiangBankerMessage(evt)
    local chairId = self.bankerChardIds[evt.para.wSwap1+1]
    table.remove(self.bankerChardIds,evt.para.wSwap1+1)
    table.insert(self.bankerChardIds,evt.para.wSwap2+1,chairId)
    dump(self.bankerChardIds)
    --重新初化庄家列表
    self.delegate:updatBankerList(self.bankerChardIds)
end


function TurntableWorkflow:receiveWaitBankerMessage(evt)
    self.delegate:setGameState(GAME_STATE_CHNAGEBANKER)
end

function TurntableWorkflow:receiveGameRecordMessage(evt)
    --print("receiveGameRecordMessage")
    if evt.para.unResolvedData then
       local info = self.delegate:getCurClientKernel():ParseStructGroup(evt.para.unResolvedData,"tagServerGameRecord")
       for k,v in pairs(info) do
           table.insert(self.recordInfo,v.cbAnimal)
       end
    end
    --dump(self.recordInfo)
end

function TurntableWorkflow:getRecordInfo()
   return self.recordInfo
end

function TurntableWorkflow:receiveBetFailedMessage(evt)
    print("下注失败")
end

function TurntableWorkflow:receiveChangeBankerMessage(evt)
    print("切换庄家")
    if self.curBankerUserId == self:getMyChairID() then
        --上一个庄家是自已
        self.delegate:refreshPlayerInfo()   
    end

    self.curBankerUserId = evt.para.wBankerUser

    local userInfo = self.delegate:getCurClientKernel():SearchUserByChairID(self.curBankerUserId)
    --dump(userInfo)
    if userInfo  then
        local pos = table.indexof(self.bankerChardIds,userInfo.wChairID)
        if pos then
            table.remove(self.bankerChardIds,pos)
        end
    end
    --刷新当前庄家数据
    self.delegate:refreshBankerInfo()
    --同时刷新庄家列表
    self.delegate:updatBankerList(self.bankerChardIds)
end

--银行操作成功处理
function TurntableWorkflow:receiveInsureSuccessMessage(evt)
    local dataMsgBox = {
        nodeParent=self.delegate,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=evt.para.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

--银行操作失败处理
function TurntableWorkflow:receiveInsureFailureMessage(evt)
    local dataMsgBox = {
        nodeParent=self.delegate,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=evt.para.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end


--判断自已是否在庄家列表中
function TurntableWorkflow:checkInBankerList()
    for k ,v in pairs(self.bankerChardIds) do
        if v == self:getMyChairID() then
            return true
        end
    end
    return false
end

--下注
function TurntableWorkflow:placeBet(area,score)
    self.command:bet(area,score)
end

--发送站立消息
function TurntableWorkflow:sendStandUpRequest()
    self.command:standUp()
end

function TurntableWorkflow:sendApplyBankerRequest()
    self.command:applyBanker()
end

function TurntableWorkflow:sendCancelBankerRequest()
    self.command:cancelBanker()
end

function TurntableWorkflow:sendQiangBankerRequest()
    self.command:qiangBanker()
end

function TurntableWorkflow:sendQueryBankInfoRequest()
    self.command:PerformQueryInfo()
end

function TurntableWorkflow:sendSaveScoreRequest(lSaveScore)
    self.command:PerformSaveScore(lSaveScore)
end

function TurntableWorkflow:sendTakeScoreRequest(lTakeScore,md5Pwd)
    self.command:PerformTakeScore(lTakeScore, md5Pwd)
end

return TurntableWorkflow