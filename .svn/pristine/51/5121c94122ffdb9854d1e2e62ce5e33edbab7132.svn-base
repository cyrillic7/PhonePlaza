CURRENT_MODULE_NAME = ...

local baccaratWorkflow = class("baccaratWorkflow")

function baccaratWorkflow:ctor(delegate)
    print("baccaratWorkflow ->ctor")
    -- 外部回调处理
    self.delegate = delegate
    --APP 单一实例
    self.app = AppBaseInstanse.BaccaratApp
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
    
    -- 网络命令发送
    self.command = import("..Command.baccaratCommand", CURRENT_MODULE_NAME).new(self.delegate:getCurClientKernel())
end

function baccaratWorkflow:cleanup()
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

function baccaratWorkflow:registerEvents(  )
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
    
    --eventListeners["GF_USER_CHAT"] = handler(self, self.receiveUserChatMessage)
    --eventListeners["GF_USER_EXPRESSION"] = handler(self, self.receiveUserExpressionMessage)
    --网络高延迟消息
    --eventListeners[PublicResponseHandler.BadNetworkingMessage] = handler(self, self.handleBadNetworking)
    --网络恢复消息
    --eventListeners[PublicResponseHandler.NetworkingTurnGoodMessage] = handler(self, self.handleNetworkingTurnGood)

  
    self.eventHandles = self.app.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function baccaratWorkflow:unregisterEvents( )
    -- 移除所有lua层事件
    self.app.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end


function baccaratWorkflow:receiveUserEnterMessage(evt)
    --print("baccaratWorkflow:receiveUserEnterMessage"..evt.para.szNickName)
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
end

function baccaratWorkflow:sortByCharid(item1,item2)
    return item1.wChairID < item2.wChairID
end

--刷新玩家列表项 
function baccaratWorkflow:receiveUserScoreUpdateMessage(evt)
    --刷新庄家列表中的每一项数据
    self.delegate:refreshBankerItemInfo(evt.para.clientUserItem)
    for k , v in pairs(self.players) do
        if type(v) =="table" and v.wChairID == evt.para.clientUserItem.wChairID then
            v.lScore = evt.para.clientUserItem.lScore
            --刷新庄家列表的中每一项数据
            AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
                    name = AppBaseInstanse.BaccaratApp.Message.UpdateBankerListItem,
                    para = v,
                })
            break
        end
    end
end

function baccaratWorkflow:checkInPlayerList(dwUserID)
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
function baccaratWorkflow:isPlaying()
    return self.isPlayingGame
end

function baccaratWorkflow:getMyChairID()
    return self.chairId
end

function baccaratWorkflow:getMyUserID()
    return self.myUserId
end

function baccaratWorkflow:getPlayers()
    return self.players
end


function baccaratWorkflow:receiveUserLeaveMessage(evt)
    print("baccaratWorkflow:receiveUserLeaveMessage"..evt.para.szNickName)
    if evt.para.dwUserID == self.myUserId then
        if self.delegate.serviceClient.exitGameApp then
            self.delegate.serviceClient:exitGameApp()
        else
            --TO DO 发站立包
            cc.Director:getInstance():popToRootScene() 
        end
    else
        
        --判断离开玩家是否在庄家列表
        local pos = table.indexof(self.bankerChardIds,evt.para.wChairID)
        if pos then
            table.remove(self.bankerChardIds,pos)
            --重新初化庄家列表
            --self.delegate:updatBankerList(self.bankerChardIds)
            AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
                name = AppBaseInstanse.BaccaratApp.Message.DeleteBankerItem,
                para = {wChairID = evt.para.wChairID},
            })
        end
    end
end

function baccaratWorkflow:receiveStatusMessage(evt)
    dump(evt.para)
    if evt.para.cbGameStatus == GAME_STATUS_PLAY  then
        self.isPlayingGame = true
    end
    self.allowLookon = evt.para.cbAllowLookon
end

--开始下注
function baccaratWorkflow:receiveGameStartMessage(evt)
    self.isPlayingGame = true
    self.delegate:receiveGameStartPro(evt.para)
    if self.curBankerUserId == self:getMyChairID() then
        AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
                name = AppBaseInstanse.BaccaratApp.Message.RefreshDownBankerBtn,
                para = {isEnable = false},
            })
    end
end

--游戏空闲消息处理
function baccaratWorkflow:receiveGameFreeMessage(evt)
    print("receiveGameFreeMessage")
    self.isPlayingGame = false
    self.delegate:receiveGameFreePro(evt.para)
    if self.curBankerUserId == self:getMyChairID() then
        AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
                name = AppBaseInstanse.BaccaratApp.Message.RefreshDownBankerBtn,
                para = {isEnable = true},
            })
    end
end 


function baccaratWorkflow:receiveSceneMessage(evt)
    print("baccaratWorkflow:receiveSceneMessage")
    local  statusInfo = {}
    local unResolvedData = evt.para.unResolvedData
    local isFreeStatus = true
    local serviceClient = self.delegate.serviceClient
    if self.isPlayingGame or serviceClient.cbGameStatus ~=0 then --还原游戏场景
        statusInfo = self.delegate:getCurClientKernel():ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusPlay")
        isFreeStatus = false
        self.isPlayingGame = true
    else
        statusInfo = self.delegate:getCurClientKernel():ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"CMD_S_StatusFree")
    end
    print("baccaratWorkflow:receiveSceneMessage2222222222"..statusInfo.wBankerUser)
    dump(statusInfo)
    --当前庄家椅子ID
    self.curBankerUserId = statusInfo.wBankerUser
    --记录上庄条件
    self.lApplyBankerCondition = statusInfo.lApplyBankerCondition
    --区域限制条件
    self.lAreaLimitScore = statusInfo.lAreaLimitScore
    --界面收到场景消息处理
    self.delegate:receiveSceneMessagePro(statusInfo,isFreeStatus)
    --庄家当庄局数
    self.wBankerTime =statusInfo.wBankerTime 
    --刷新界面庄家信息
    self.delegate:refreshPlayerInfo()
    self.delegate:refreshBankerInfo()
end

function baccaratWorkflow:getCurBankerTime()
    return self.wBankerTime
end

function baccaratWorkflow:isCanApplyBanker(lScore)
    return self.lApplyBankerCondition <= lScore
end

--收到申请做庄消息处理
function baccaratWorkflow:receiveApplyBankerMessage(evt)
    print("receiveApplyBankerMessage"..self.curBankerUserId)
    local chairId = evt.para.wApplyUser
    local pos = table.indexof(self.bankerChardIds,chairId)
    if not pos and self.curBankerUserId ~= chairId  then
        table.insert(self.bankerChardIds,chairId)
    end
    --刷新庄家列表
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.UpdateBankerList,
            para = {},
    })
end

function baccaratWorkflow:getCurBankerUserId()
    return self.curBankerUserId
end

function baccaratWorkflow:receiveUserBetMessage(evt)
    self.delegate:receiveUserBetPro(evt.para) 
end

--收到下注结束消息处理
function baccaratWorkflow:receiveRoundOverMessage(evt)
    --记录庄家次数
    self.wBankerTime =evt.para.nBankerTime
    self.delegate:receiveRoundOverMessage(evt.para)
end

function baccaratWorkflow:addRecordIem(itemInfo)
    table.insert(self.recordInfo,itemInfo)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.NewAddRecord,
            para = {info = itemInfo},
    })
end


function baccaratWorkflow:receiveCancelBankerMessage(evt)
    local pos = table.indexof(self.bankerChardIds,evt.para.wCancelUser)
    if pos then
        table.remove(self.bankerChardIds,pos)
        --重新初化庄家列表
        AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.DeleteBankerItem,
            para = {wChairID = evt.para.wCancelUser},
        })
    end
end

--通过昵称获取椅子ID
function baccaratWorkflow:getChairIdByNick(nick)
    for k, player in pairs(self.players) do
        if player.szNickName == nick then
            return player.wChairID
        end
    end
    return -1
end

function baccaratWorkflow:receiveQiangBankerMessage(evt)
    print("receiveQiangBankerMessage")
    --dump(evt.para)
    local chairId = self.bankerChardIds[evt.para.wSwap1+1]
    table.remove(self.bankerChardIds,evt.para.wSwap1+1)
    table.insert(self.bankerChardIds,evt.para.wSwap2+1,chairId)
    --dump(self.bankerChardIds)
    --重新初化庄家列表
     AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.UpdateBankerList,
            para = {},
    })
end


function baccaratWorkflow:receiveWaitBankerMessage(evt)
    print("receiveWaitBankerMessage")
    dump(evt.para)
    --self.delegate:setGameState(GAME_STATE_CHNAGEBANKER)
end

function baccaratWorkflow:receiveGameRecordMessage(evt)
    print("receiveGameRecordMessage")
    dump(evt.para)
    if evt.para.unResolvedData then
       local info = self.delegate:getCurClientKernel():ParseStructGroup(evt.para.unResolvedData,"tagServerGameRecord")
       dump(info)
       for k,v in pairs(info) do
            local itemInfo = {}
            itemInfo.winScore = 0
            itemInfo.isPlayer= -1
            itemInfo.isBanker = -1
            itemInfo.isSamePoint =  -1
            itemInfo.cbPlayerCount = v.cbPlayerCount
            itemInfo.cbBankerCount = v.cbBankerCount
            if v.cbPlayerCount > v.cbBankerCount then
                itemInfo.isPlayer =  1
            elseif v.cbPlayerCount < v.cbBankerCount then
                itemInfo.isBanker =  1
            else
                itemInfo.isSamePoint =  1
            end
            table.insert(self.recordInfo,itemInfo)
       end
    end
    
end

function baccaratWorkflow:getRecordInfo()
   return self.recordInfo
end

function baccaratWorkflow:receiveBetFailedMessage(evt)
    print("下注失败")
    dump(evt.para)
end

function baccaratWorkflow:receiveChangeBankerMessage(evt)
    print("切换庄家")
    if self.curBankerUserId == self:getMyChairID() then
        --上一个庄家是自已
        self.delegate:refreshPlayerInfo()   
    end

    self.curBankerUserId = evt.para.wBankerUser

 
    local pos = table.indexof(self.bankerChardIds,self.curBankerUserId)
    if pos then
        table.remove(self.bankerChardIds,pos)
    end

    self.wBankerTime = 0
    --刷新当前庄家数据
    self.delegate:refreshBankerInfo()
    --重新初化庄家列表
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
        name = AppBaseInstanse.BaccaratApp.Message.DeleteBankerItem,
        para = {wChairID = self.curBankerUserId},
    })
end

--银行操作成功处理
function baccaratWorkflow:receiveInsureSuccessMessage(evt)
    local dataMsgBox = {
        nodeParent=self.delegate,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=evt.para.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

--银行操作失败处理
function baccaratWorkflow:receiveInsureFailureMessage(evt)
    local dataMsgBox = {
        nodeParent=self.delegate,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=evt.para.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end


--判断自已是否在庄家列表中
function baccaratWorkflow:checkInBankerList()
    for k ,v in pairs(self.bankerChardIds) do
        if v == self:getMyChairID() then
            return true
        end
    end
    return false
end

--下注
function baccaratWorkflow:placeBet(area,score)
    self.command:bet(area,score)
end

--发送站立消息
function baccaratWorkflow:sendStandUpRequest()
    self.command:standUp()
end

function baccaratWorkflow:sendApplyBankerRequest()
    self.command:applyBanker()
end

function baccaratWorkflow:sendCancelBankerRequest()
    self.command:cancelBanker()
end

function baccaratWorkflow:sendQiangBankerRequest()
    self.command:qiangBanker()
end

function baccaratWorkflow:sendQueryBankInfoRequest()
    self.command:PerformQueryInfo()
end

function baccaratWorkflow:sendSaveScoreRequest(lSaveScore)
    self.command:PerformSaveScore(lSaveScore)
end

function baccaratWorkflow:sendTakeScoreRequest(lTakeScore,md5Pwd)
    self.command:PerformTakeScore(lTakeScore, md5Pwd)
end

return baccaratWorkflow