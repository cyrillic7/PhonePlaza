local MissionItem = require("plazacenter.controllers.MissionItem")
local ServerViewItemController = class("ServerViewItemController",MissionItem)

function ServerViewItemController:ctor(frameScene,gameServer)
	self.frameScene = frameScene
	self.gameServer = gameServer
	self.plazaUserManager = require("plazacenter.controllers.PlazaUserManagerController").new()

	ServerViewItemController.super.ctor(self,CLIENT_TYPE_GAME_ROOM,nil)
	self.GameServerNetWork = require("plazacenter.controllers.GameServerNetWork").new(self.scriptHandler,self.serviceClient)
    self.GameClientManager = require("common.GameClientManager").new(self.scriptHandler,self.serviceClient)

    self.ConfigServer = {
        --wTableCount= ,
        --wChairCount= ,
        --wServerType= ,
        --dwServerRule= 
        }
    self.dwUserRight = 0
    self.dwMasterRight = 0
    self.wReqTableID=INVALID_TABLE
    self.wReqChairID=INVALID_CHAIR
end

function ServerViewItemController:gameName()
    local gameKind = ServerListData:GetGameKindByKind(self.gameServer.wKindID)
    if not gameKind then
        local dataMsgBox = {
            nodeParent=self.frameScene,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="获取游戏种类失败，进入游戏失败！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        self:onDisconnectSocket()
        return
    end
    local strExeName = string.lower(gameKind.szProcessName)
    local index,_ = string.find(strExeName,".exe")
    if index then
        strExeName = string.sub(strExeName,1,index-1)
    end
    return strExeName
	--return GAME_SERVER_CLIENT_NAME_PRE..self.gameServer.wKindID
end

function ServerViewItemController:onInitServerView()
    print("ServerViewItemController:onInitServerView")

    self:registerHandlers()
    self:initServerViewItem()
end

function ServerViewItemController:onCleanServerView( )    
    print("ServerViewItemController:onCleanServerView")
    self:unRegisterHandlers()
    self:removeServiceClient()
end

function ServerViewItemController:showLoadingWidget()
    if not self.loadingWidget then
        self.loadingWidget = require("plazacenter.widgets.CommonLoadingWidget").new(self.frameScene)
    end
end

function ServerViewItemController:hideLoadingWidget()
    if self.loadingWidget ~= nil then
        self.loadingWidget:hideLoadingWidget()
        self.loadingWidget = nil
    end
end

function ServerViewItemController:updateStatusLabel(statusText)
    if self.loadingWidget ~= nil then
        self.loadingWidget:updateStatusLabel(statusText)
    end
end

function ServerViewItemController:registerHandlers()
   self.GameServerNetWork:registerDataHandlers()
   self:registerEvents()
end

function ServerViewItemController:unRegisterHandlers()
   self.GameServerNetWork:unRegisterDataHandlers()
   self:unregisterEvents()
end
function ServerViewItemController:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[appBase.Message.GS_LinkConnect] = handler(self, self.receiveConnectMessage)
    eventListeners[appBase.Message.GS_LinkShutDown] = handler(self, self.receiveGameShutDownMessage)
    eventListeners[appBase.Message.GS_LoginSuccess] = handler(self, self.receiveGameLoginSuccessMessage)
    eventListeners[appBase.Message.GS_LoginFailure] = handler(self, self.receiveGameLoginFailedMessage)
    eventListeners[appBase.Message.GS_LoginFinish] = handler(self, self.receiveGameLoginFinishMessage)
    eventListeners[appBase.Message.GS_UpdateNotify] = handler(self, self.receiveUpdateNotifyMessage)
    eventListeners[appBase.Message.GS_ConfigServer] = handler(self, self.receiveConfigServerMessage)
    eventListeners[appBase.Message.GS_ConfigUserRight] = handler(self, self.receiveConfigUserRightMessage)
    eventListeners[appBase.Message.GS_RequestFailure] = handler(self, self.receiveRequestFailureMessage)
    eventListeners[appBase.Message.GS_UserEnter] = handler(self, self.receiveUserEnterMessage)
    eventListeners[appBase.Message.GS_UserScore] = handler(self, self.receiveUserScoreMessage)
    eventListeners[appBase.Message.GS_UserStatus] = handler(self, self.receiveUserStatusMessage)
    eventListeners[appBase.Message.GS_SystemMessage] = handler(self, self.receiveSystemMessageMessage)
    eventListeners[appBase.Message.GS_ActionMessage] = handler(self, self.receiveActionMessageMessage)
    eventListeners[self.plazaUserManager.Message.PLAZA_UserItemAcitve] = handler(self, self.onUserItemAcitve)
    eventListeners[self.plazaUserManager.Message.PLAZA_UserItemDelete] = handler(self, self.onUserItemDelete)
    eventListeners[self.plazaUserManager.Message.PLAZA_UserItemScoreUpdate] = handler(self, self.onUserItemScoreUpdate)
    eventListeners[self.plazaUserManager.Message.PLAZA_UserItemStatusUpdate] = handler(self, self.onUserItemStatusUpdate)
    eventListeners[self.plazaUserManager.Message.PLAZA_UserItemAttribUpdate] = handler(self, self.onUserItemAttribUpdate)
    eventListeners[appBase.Message.Ctrl_TableViewChairClicked] = handler(self, self.receiveTableChairClickedMessage)
    eventListeners[appBase.Message.Ctrl_QuickJoinBtnClicked] = handler(self, self.receiveQuickJoinBtnClickedMessage)
    eventListeners[appBase.Message.Ctrl_SetTableLockBtnClicked] = handler(self, self.receiveSetTableLockBtnClickedMessage)
    
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function ServerViewItemController:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
    self.eventHandles = {}
end

function ServerViewItemController:onDisconnectSocket()
    self.super.onDisconnectSocket(self)
    -- 下帧返回主界面,避免游戏未退出房间已经销毁
    local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    scheduler.performWithDelayGlobal(function ()
        if self.frameScene then
            self.frameScene:switchToTableFrame(false)
        end
    end, 0)
end

function ServerViewItemController:initServerViewItem()
    self.mySelfUserItem = nil
	if self.frameScene then
		self:showLoadingWidget()
        self.serviceClient:Connect(self.gameServer.szServerAddr,self.gameServer.wServerPort)
        self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
    end
end

function ServerViewItemController:performSitDownAction(wTableID, wChairID, bEfficacyPass, bLocker)
    if self.wReqTableID ~= INVALID_TABLE and self.wReqTableID == wTableID then
        return false
    end
    if self.wReqChairID ~= INVALID_TABLE and self.wReqChairID == wChairID then
        return false
    end
    -- 自己状态
    if self.mySelfUserItem.cbUserStatus >= US_PLAYING then
        local dataMsgBox = {
            nodeParent=display.getRunningScene(),
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="您正在游戏中，暂时不能离开，请先结束当前游戏！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return false
    end
    -- 权限判断
    if (0 ~= bit._and(self.dwUserRight, UR_CANNOT_PLAY)) then
        local dataMsgBox = {
            nodeParent=display.getRunningScene(),
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="抱歉，您暂时没有加入游戏的权限！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return false
    end
    -- 桌子校验
    if wTableID ~= INVALID_TABLE and wChairID ~= INVALID_CHAIR then
        if wTableID >= self.ConfigServer.wTableCount or wChairID >= self.ConfigServer.wChairCount then
            return false
        end
    end
    -- 密码判断
    if self.mySelfUserItem.cbMasterOrder == 0 and bEfficacyPass and wTableID ~= INVALID_TABLE and wChairID ~= INVALID_CHAIR then
        if bLocker then
            -- 添加密码框
            require("plazacenter.widgets.TableLockWidget").new(self.frameScene,function (pwd)
                self.wReqTableID = wTableID
                self.wReqChairID = wChairID
                print("pwd",pwd)
                self.GameServerNetWork:sendSitDownPacket(wTableID,wChairID,pwd)
            end)
            return
        end
    end
    self.wReqTableID = wTableID
    self.wReqChairID = wChairID
    self.GameServerNetWork:sendSitDownPacket(wTableID,wChairID,szPassword)
    -- 显示加载界面
    self:showLoadingWidget()
    self:updateStatusLabel("发送请求中,请耐心稍候片刻")
    return true
end

function ServerViewItemController:performLookonAction(wTableID, wChairID)
    if self.wReqTableID == wTableID and self.wReqChairID == wChairID then
        return false
    end
    if self.mySelfUserItem.cbUserStatus >= US_PLAYING then
        local dataMsgBox = {
            nodeParent=self.frameScene,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="您正在游戏中，暂时不能离开，请先结束当前游戏！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return false
    end
    -- 权限判断
    if (0 ~= bit._and(self.dwUserRight, UR_CANNOT_LOOKON)) then
        local dataMsgBox = {
            nodeParent=self.frameScene,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="抱歉，您暂时没有旁观游戏的权限！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return false
    end
    -- 设置变量
    self.wReqTableID = wTableID
    self.wReqChairID = wChairID
    -- 发送命令
    self.GameServerNetWork:sendLookonPacket(wTableID,wChairID)
end

function ServerViewItemController:showUserInfo(userInfo,positionX,positionY)
    if not self.userInfoWidget then
        local userInfoWidget = require("plazacenter.widgets.UserInfoWidget")
        self.userInfoWidget = userInfoWidget.new(self.frameScene, userInfoWidget.TABLE_TYPE)
    end
    self.userInfoWidget:updateUserInfo(userInfo,positionX,positionY)
    self.userInfoWidget:showUserInfo(true)
end

function ServerViewItemController:enterGameApp()
    print("ServerViewItemController:enterGameApp()")
    -- 隐藏加载界面
    self:hideLoadingWidget()
    -- 进入游戏
    self.GameClientManager:enterGameApp(self:gameName())
    -- 发送房间信息
    self.GameClientManager:sendGameServerInfo({wTableID=self.mySelfUserItem.wTableID,
                            wChairID=self.mySelfUserItem.wChairID,
                            dwUserID=self.mySelfUserItem.dwUserID,
                            dwUserRight=self.dwUserRight,
                            dwMasterRight=self.dwMasterRight,
                            wKindID=self.gameServer.wKindID,
                            wServerID=self.gameServer.wServerID,
                            wServerType=self.ConfigServer.wServerType,
                            dwServerRule=self.ConfigServer.dwServerRule,
                            szServerName=self.gameServer.szServerName
                        })
    -- 发送用户
    if self.mySelfUserItem.wTableID ~= INVALID_TABLE 
        and self.mySelfUserItem.wChairID ~= INVALID_CHAIR then
        local count,items = self.plazaUserManager:GetUserItemsByTable(self.mySelfUserItem.wTableID)
        if count > 0 then
            for k,v in pairs(items) do
                if v.cbUserStatus ~= US_LOOKON then
                    self.GameClientManager:sendUserItem(v)
                end
            end
        end
    end
    -- 发送配置完成
    self.GameClientManager:sendProcessData(IPC_CMD_GF_CONFIG,IPC_SUB_GF_CONFIG_FINISH)
end

function ServerViewItemController:getClientVersion()
    local version = AppBaseInstanse.PLAZACENTER_APP:getClientVersion(self.gameServer.wKindID,eGameItemType.eItemTypeNormalGame) or VERSION_GAME
    return version
end

function ServerViewItemController:searchGameTable()
    local chairCount = self.ConfigServer.wChairCount or 0
    local tableCount = self.ConfigServer.wTableCount or 0
    local tableViewArray = self.frameScene and self.frameScene.TableFrameController and self.frameScene.TableFrameController.TableViewArray
    if chairCount > 1 and tableViewArray and table.nums(tableViewArray) == tableCount then
        for i=1,chairCount do
            for k=0,tableCount-1 do
                local tableView = tableViewArray[tostring(k)]
                -- 排除加锁
                if not tableView:getLockerFlag() and tableView:getNullChairCount() == i then
                    local chairID = tableView:getFirstNullChairID()
                    if chairID then
                        return k,chairID
                    end
                end
            end
        end
    end
end

function ServerViewItemController:receiveConnectMessage(event)
   if event.para.bConnectSucc then
        print("bConnectSucc: 连接成功！")
        --self.GameServerNetWork:sendLoginMsg(self.gameServer.wKindID, 16777217, 17301505)
        self.GameServerNetWork:sendLoginMsg(self.gameServer.wKindID, 16777217, self:getClientVersion())
        --self.GameServerNetWork:sendLoginMsg(self.gameServer.wKindID, 16777217, 17104897)
        self:updateStatusLabel("正在验证用户登录信息")
    else
        local dataMsgBox = {
            nodeParent=display.getRunningScene(),
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="连接失败",
            callBack=function()
                self:hideLoadingWidget()
            end
        }
        self:onDisconnectSocket()
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    end
end

function ServerViewItemController:receiveGameShutDownMessage(event)
   print("ServerViewItemController:receiveGameShutDownMessage:"..event.para.cbShutReason)

   if event.para.cbShutReason ~= 0 then
        -- 关闭游戏
        self.GameClientManager:exitGameApp()

        local dataMsgBox = {
            nodeParent=self.frameScene,
            msgboxType=MSGBOX_TYPE_OKCANCEL,
            msgInfo="与服务器断开连接，是否重新连接？",
            callBack=function(ret)
                self:hideLoadingWidget()
                if ret == MSGBOX_RETURN_OK then
                    self:initServerViewItem()
                else                    
                    self:onDisconnectSocket()
                end
            end
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
   end
   
end

function ServerViewItemController:receiveGameLoginSuccessMessage(event)
    local Params = event.para
    self.dwUserRight=Params.dwUserRight
    self.dwMasterRight=Params.dwMasterRight
    self:updateStatusLabel("正在读取房间信息")
    -- 清空用户列表
    self.plazaUserManager:removeAllUserItems()
end

function ServerViewItemController:receiveGameLoginFailedMessage(event)
    local Params = event.para

    local dataMsgBox = {
        nodeParent=self.frameScene,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString,
        callBack=function()
            self:hideLoadingWidget()
        end
    }
    self:onDisconnectSocket()
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function ServerViewItemController:receiveGameLoginFinishMessage(event)
    if self.frameScene then
        if not self.bHundredGame and not GlobalPlatInfo.isInReview then
            self.frameScene:switchToTableFrame(true)
        end
        self.bLogin = true
    end
    self:hideLoadingWidget()
    -- 进入游戏
    if self.mySelfUserItem and self.mySelfUserItem.wTableID ~= INVALID_TABLE then
        self:enterGameApp()
    end
    -- 百人游戏发送坐下操作/IOS审核
    if self.bHundredGame or GlobalPlatInfo.isInReview then
        self:performSitDownAction(INVALID_TABLE,INVALID_CHAIR,false)
        print("百人游戏发送坐下操作")
    end
end

function ServerViewItemController:receiveUpdateNotifyMessage(event)
    local Params = event.para

    local dataMsgBox = {
        nodeParent=self.frameScene,
        msgboxType=MSGBOX_TYPE_OKCANCEL,
        msgInfo="游戏已经升级，是否进行升级？(建议在Wifi环境下升级)",
        callBack=function(ret)
            if ret == MSGBOX_RETURN_OK then
                AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
                    name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_DownLoadClient,
                    para = {wKindID=self.gameServer.wKindID,nItemType=eGameItemType.eItemTypeNormalGame}
                })
            end
            self:hideLoadingWidget()
        end
    }
    self:onDisconnectSocket()
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function ServerViewItemController:receiveConfigServerMessage(event)
    self.ConfigServer = event.para
    print("ServerViewItemController:receiveConfigServerMessage")
    for k,v in pairs(self.ConfigServer) do
        print(k,v)
    end

    -- sortID 低于510的，显示防作弊模式
    if self.gameServer.wSortID < 510 then
        self.ConfigServer.dwServerRule = bit._or(self.ConfigServer.dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE)
    end

    self.bHundredGame = (self.ConfigServer.wChairCount >= HUNDRRED_GAME_NUM)
end

function ServerViewItemController:receiveConfigUserRightMessage(event)
    print("receiveConfigUserRightMessage")
    self.dwUserRight = event.para.dwUserRight
end

function ServerViewItemController:receiveRequestFailureMessage(event)
    local Params = event.para

    -- 设置变量
    self.wReqTableID = INVALID_TABLE
    self.wReqChairID = INVALID_CHAIR

    local dataMsgBox = {
        nodeParent=display.getRunningScene(),
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString,
        callBack=function()
            self:hideLoadingWidget()
        end
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    -- 百人游戏请求失败，则退出游戏/ios 审核版本
    if self.bHundredGame  or GlobalPlatInfo.isInReview then        
        self:onDisconnectSocket()
        self.GameClientManager:exitGameApp()
    end

    -- 隐藏加载界面
    self:hideLoadingWidget()
end

function ServerViewItemController:onUserItemAcitve(event)
    local clientUserItem = event.para
    -- 判断自己
    if not self.mySelfUserItem then
        self.mySelfUserItem = clientUserItem
    end
end

function ServerViewItemController:onUserItemDelete(event)
    if not self.mySelfUserItem then
        return
    end
    local clientUserItem = event.para
    local wLastTableID = clientUserItem.wTableID
    local wLastChairID = clientUserItem.wChairID
    local dwLeaveUserID = clientUserItem.dwUserID
    local wMyTableID = self.mySelfUserItem.wTableID or INVALID_TABLE
    if wLastTableID ~= INVALID_TABLE and wLastChairID ~= INVALID_CHAIR then
        if GlobalUserInfo.dwUserID == dwLeaveUserID or wLastTableID == wMyTableID then
            local tagUserStatus = {
                wTableID=INVALID_TABLE,
                wChairID=INVALID_CHAIR,
                cbUserStatus=US_NULL
                }
            self.GameClientManager:sendUserStatus(dwLeaveUserID,tagUserStatus)
        end
    end

    -- 自己离开，退出桌子
    if self.mySelfUserItem.dwUserID == clientUserItem.dwUserID then
        local dataMsgBox = {
            nodeParent=self.frameScene,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="温馨提醒：您已进入其他游戏房间，被迫退出当前房间！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        self:onDisconnectSocket()
        self.GameClientManager:exitGameApp()
    end
end

function ServerViewItemController:onUserItemScoreUpdate(event)
    local clientUserItem = event.para.clientUserItem
    local preUserScore = event.para.preUserScore
    -- 界面通知
    if clientUserItem.dwUserID == GlobalUserInfo.dwUserID then
        print("onUserItemScoreUpdate ",clientUserItem.lScore)
        -- 是否体验场
        if (0 == bit._and(self.ConfigServer.dwServerRule, SR_IS_TRAIN_ROOM)) then
            if GAME_GENRE_GOLD == self.ConfigServer.wServerType then
                --GlobalUserInfo.lUserScore = GlobalUserInfo.lUserScore+clientUserItem.lScore-preUserScore.lScore
                GlobalUserInfo.lUserScore = clientUserItem.lScore
            end
            --GlobalUserInfo.lUserInsure = GlobalUserInfo.lUserInsure+clientUserItem.lInsure-preUserScore.lInsure
            --GlobalUserInfo.dwUserMedal = GlobalUserInfo.dwUserMedal+clientUserItem.dwUserMedal-preUserScore.dwUserMedal
            GlobalUserInfo.lUserInsure = clientUserItem.lInsure
            GlobalUserInfo.dwUserMedal = clientUserItem.dwUserMedal
            GlobalUserInfo.lLoveLiness = clientUserItem.lLoveLiness
            GlobalUserInfo.dwExperience = clientUserItem.dwExperience
            -- 刷新用户信息
            AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_UpdateUserInfo,
            para = {}
        })
        end
    end
    -- 游戏通知
    if self.mySelfUserItem.wTableID ~= INVALID_TABLE 
        and clientUserItem.wTableID == self.mySelfUserItem.wTableID then
        local UserScore = {lScore = clientUserItem.lScore,
                                lGrade = clientUserItem.lGrade,
                                lInsure = clientUserItem.lInsure,
                                dwWinCount = clientUserItem.dwWinCount,
                                dwLostCount = clientUserItem.dwLostCount,
                                dwDrawCount = clientUserItem.dwDrawCount,
                                dwFleeCount = clientUserItem.dwFleeCount,
                                dwUserMedal = clientUserItem.dwUserMedal,
                                dwExperience = clientUserItem.dwExperience,
                                lLoveLiness = clientUserItem.lLoveLiness,
                                lCapacityScore = clientUserItem.lJifen}
        -- 发送数据
        self.GameClientManager:sendUserScore(clientUserItem.dwUserID,UserScore);
    end
end

function ServerViewItemController:onUserItemStatusUpdate(event)
    local clientUserItem = event.para.clientUserItem
    local preUserStatus = event.para.preUserStatus
    local wNowTableID = clientUserItem.wTableID
    local wLastTableID = preUserStatus.wTableID
    local wNowChairID = clientUserItem.wChairID
    local wLastChairID = preUserStatus.wChairID
    local cbNowStatus = clientUserItem.cbUserStatus
    local cbLastStatus = preUserStatus.cbUserStatus
    local dwMyUserID = GlobalUserInfo.dwUserID
    local dwCurUserID = clientUserItem.dwUserID
    -- 自己离开，百人游戏，IOS审核版本退出房间
    if dwMyUserID == dwCurUserID and wLastTableID ~= INVALID_TABLE  
        and wNowTableID == INVALID_TABLE then
        if self.bHundredGame  or GlobalPlatInfo.isInReview then        
            self:onDisconnectSocket()
            self.GameClientManager:exitGameApp()
        end
    end
    -- 离开通知
    if wLastTableID ~= INVALID_TABLE 
        and (wNowTableID ~= wLastTableID or wNowChairID ~= wLastChairID) then
        if dwMyUserID == dwCurUserID 
           or wLastTableID == self.mySelfUserItem.wTableID then
            local tagUserStatus = {
                wTableID=wNowTableID,
                wChairID=wNowChairID,
                cbUserStatus=cbNowStatus
                }
            self.GameClientManager:sendUserStatus(dwCurUserID,tagUserStatus)
        end
        return
    end
    -- 加入处理
    if wNowTableID ~= INVALID_TABLE 
        and (wNowTableID ~= wLastTableID or wNowChairID ~= wLastChairID) then
        -- 游戏通知
        if dwMyUserID ~= dwCurUserID and wNowTableID == self.mySelfUserItem.wTableID then
            self.GameClientManager:sendUserItem(clientUserItem);
        end
        -- 自己判断
        if dwMyUserID == dwCurUserID then
            self.wReqTableID = INVALID_TABLE
            self.wReqChairID = INVALID_CHAIR
            -- 进入游戏
            self:enterGameApp()
        end
        return
    end
    -- 状态改变
    if wNowTableID ~= INVALID_TABLE and wNowTableID == wLastTableID and self.mySelfUserItem.wTableID == wNowTableID then
        local tagUserStatus = {
                wTableID=wNowTableID,
                wChairID=wNowChairID,
                cbUserStatus=cbNowStatus
                }
            self.GameClientManager:sendUserStatus(dwCurUserID,tagUserStatus)
        return
    end
end

function ServerViewItemController:onUserItemAttribUpdate(event)
    -- body
end

function ServerViewItemController:receiveUserEnterMessage(event)
    local Params = event.para
    local userInfo = event.para
    local bHideUserInfo = (0 ~= bit._and(self.ConfigServer.dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE))
    local bMySelf = (userInfo.dwUserID == GlobalUserInfo.dwUserID)
    if bMySelf then
        GlobalUserInfo.cbMasterOrder = userInfo.cbMasterOrder
    end
    local bMasterUser = userInfo.cbMasterOrder>0 or GlobalUserInfo.cbMasterOrder>0
    if not bHideUserInfo or bMySelf or bMasterUser then
        if Params.unResolvedData ~= nil then
            local  unResolvedData = Params.unResolvedData
            local DataDes = self.serviceClient:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"tagDataDescribe")
            while DataDes ~= nil do
                unResolvedData = DataDes.unResolvedData
                -- 用户昵称
                if DataDes.wDataDescribe == DTP_GR_NICK_NAME then
                    local nickName = self.serviceClient:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"DTP_GR_NickName")
                    if nickName then
                        userInfo.szNickName = nickName.szNickName or ""
                        if nickName.unResolvedData ~= nil then
                            DataDes = self.serviceClient:ParseStruct(nickName.unResolvedData.dataPtr,nickName.unResolvedData.size,"tagDataDescribe")
                        else
                            DataDes = nil
                        end
                    else
                        break
                    end
                -- 个性签名
                elseif DataDes.wDataDescribe == DTP_GR_UNDER_WRITE then
                    local underWrite = self.serviceClient:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"DTP_GR_UnderWrite")
                    if underWrite then
                        userInfo.szUnderWrite=underWrite.szUnderWrite or ""
                        if underWrite.unResolvedData ~= nil then
                            DataDes = self.serviceClient:ParseStruct(underWrite.unResolvedData.dataPtr,underWrite.unResolvedData.size,"tagDataDescribe")
                        else
                            DataDes = nil
                        end
                    else
                        break
                    end
                -- 用户社团
                elseif DataDes.wDataDescribe == DTP_GR_GROUP_NAME then
                    local groupNameInfo = self.serviceClient:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"DTP_GR_GroupName")
                    if groupNameInfo ~= nil then
                        userInfo.szGroupName=groupNameInfo.szGroupName or ""
                        if groupNameInfo.unResolvedData ~= nil then
                            DataDes = self.serviceClient:ParseStruct(groupNameInfo.unResolvedData.dataPtr,groupNameInfo.unResolvedData.size,"tagDataDescribe")
                        else
                            DataDes = nil
                        end
                    else
                        break
                    end
                -- 能力积分
                elseif DataDes.wDataDescribe == DTP_GR_CAPACITY_SCORE then
                    local capacityScore = self.serviceClient:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"DTP_GR_CapacityScore")
                    
                    if bMySelf then
                        dump(capacityScore)
                    end
                    if capacityScore ~= nil then
                        userInfo.lJifen=capacityScore.lJifen or 0
                        if capacityScore.unResolvedData ~= nil then
                            DataDes = self.serviceClient:ParseStruct(capacityScore.unResolvedData.dataPtr,groupNameInfo.unResolvedData.size,"tagDataDescribe")
                        else
                            DataDes = nil
                        end
                    else
                        break
                    end
                else
                    break
                end
            end
        end 
    else
        userInfo.szNickName = "游戏玩家"
    end

    local clientUserItem = self.plazaUserManager:SearchUserByUserID(userInfo.dwUserID)
    if clientUserItem then
        self.plazaUserManager:DeleteUserItem(userInfo.dwUserID)
    end
    self.plazaUserManager:ActiveUserItem(userInfo)
end

function ServerViewItemController:receiveUserScoreMessage(event)
    local userScoreInfo = event.para
    if userScoreInfo then
        local clientUserItem = self.plazaUserManager:SearchUserByUserID(userScoreInfo.dwUserID)
        if not clientUserItem then
            return
        end
        local bAvertCheatMode = (0 ~= bit._and(self.ConfigServer.dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE))
        local bMySelf = (userScoreInfo.dwUserID == GlobalUserInfo.dwUserID)
        local bMasterUser = clientUserItem.cbMasterOrder>0 or GlobalUserInfo.cbMasterOrder>0
        if not bAvertCheatMode or bMySelf or bMasterUser then
            self.plazaUserManager:UpdateUserItemScore(userScoreInfo.dwUserID,userScoreInfo.UserScore)
        end
    end    
end

function ServerViewItemController:receiveUserStatusMessage(event)
    local userStatusInfo = event.para
    if userStatusInfo then
        local clientUserItem = self.plazaUserManager:SearchUserByUserID(userStatusInfo.dwUserID)
        if not clientUserItem then
            return
        end
        if userStatusInfo.UserStatus.cbUserStatus==US_NULL then
            self.plazaUserManager:DeleteUserItem(userStatusInfo.dwUserID)
        else
            self.plazaUserManager:UpdateUserItemStatus(userStatusInfo.dwUserID,userStatusInfo.UserStatus)
        end
    end    
end

function ServerViewItemController:receiveSystemMessageMessage(event)
    local systemMessage = event.para
    if systemMessage then
        local wType = systemMessage.wType
        --弹出消息
        if (0 ~= bit._and(wType, SMT_EJECT)) then
            local dataMsgBox = {
                nodeParent=self.frameScene,
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo=systemMessage.szString
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        end
        if (0 ~= bit._and(wType, SMT_CLOSE_ROOM)) or 
            (0 ~= bit._and(wType, SMT_CLOSE_LINK)) then
            --断链
            self:onDisconnectSocket()
            --关闭游戏
            self.GameClientManager:exitGameApp()
        end
    end    
end

function ServerViewItemController:receiveActionMessageMessage(event)
    local actionMessage = event.para
    if actionMessage then
        local wType = actionMessage.wType
        if (0 ~= bit._and(wType, SMT_CLOSE_ROOM)) or 
            (0 ~= bit._and(wType, SMT_CLOSE_LINK)) then
            --断链
            self:onDisconnectSocket()
            --关闭游戏
            self.GameClientManager:exitGameApp()
        end
    end    
end

function ServerViewItemController:receiveTableChairClickedMessage(event)
    local wTableID = event.para.wTableID
    local wChairID = event.para.wChairID
    local chairUserItem = event.para.chairUserItem
    local bLocker = event.para.bLocker
    if wTableID == INVALID_TABLE or wChairID == INVALID_CHAIR then
        return
    end
    if self.wReqTableID == wTableID and self.wReqChairID == wChairID then
        return
    end
    if (0 ~= bit._and(self.ConfigServer.dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE)) then
        self:performSitDownAction(INVALID_TABLE,INVALID_CHAIR,false)
        return
    end
    if chairUserItem then
        if chairUserItem.dwUserID == GlobalUserInfo.dwUserID then
            return
        else
            if self.wReqTableID ~= INVALID_TABLE or self.wReqChairID ~= INVALID_CHAIR then
                return
            end
            --self:performLookonAction(wTableID,wChairID)
            local sender = event.para.sender
            if sender then
                local position = sender:getParent():convertToWorldSpace(cc.p(sender:getPosition()))
                self:showUserInfo(chairUserItem, position.x, position.y)
            end
        end
    else
        self:performSitDownAction(wTableID,wChairID,true,bLocker)
    end
end

function ServerViewItemController:receiveQuickJoinBtnClickedMessage(event)
    print("receiveQuickJoinBtnClickedMessage",event.para.wTableID,event.para.wChairID)
    if (0 ~= bit._and(self.ConfigServer.dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE)) then
        self:performSitDownAction(INVALID_TABLE,INVALID_CHAIR,false)
        return
    end
    local wTableID,wChairID = self:searchGameTable()
    if wTableID and wChairID then
        self:performSitDownAction(wTableID,wChairID,false)
    else
        local dataMsgBox = {
                nodeParent=display.getRunningScene(),
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="抱歉，现在暂时没有可以加入的游戏桌，请稍后再次尝试！"
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    end
end

function ServerViewItemController:receiveSetTableLockBtnClickedMessage(event)
    print("receiveSetTableLockBtnClickedMessage")
    
    require("plazacenter.widgets.SetTableLockWidget").new(self.frameScene,function (pwd)
                self.GameServerNetWork:sendUserRulePacket(pwd)
            end)
end
return ServerViewItemController