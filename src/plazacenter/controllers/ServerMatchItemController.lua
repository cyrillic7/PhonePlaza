local MissionItem = require("plazacenter.controllers.MissionItem")
local ServerMatchItemController = class("ServerMatchItemController",MissionItem)

function ServerMatchItemController:ctor(frameScene,matchServer)
	self.frameScene = frameScene
	self.matchServer = matchServer
    self.gameKind = ServerMatchData:SearchMatchKind(matchServer.MatchSerial.dwKindID)
	self.plazaUserManager = require("plazacenter.controllers.PlazaUserManagerController").new(true)

	ServerMatchItemController.super.ctor(self,CLIENT_TYPE_GAME_ROOM,nil)
	self.GameServerNetWork = require("plazacenter.controllers.GameServerNetWork").new(self.scriptHandler,self.serviceClient,true)
    self.GameClientManager = require("common.GameClientManager").new(self.scriptHandler,self.serviceClient)

    self.ConfigServer = {
        --wTableCount= ,
        --wChairCount= ,
        --wServerType= ,
        --dwServerRule= 
        }
    self.sMatchWaitStart = {
        dwmatchStatus=MS_NULL,
        dwWaitting=0,
        dwTotal=0,
        MeUserID=0,
        d_MatchDesc={},
        NeedSortUserList=0
    }
    self.ClientCanSendFinish = 0
    self.dwUserRight = 0
    self.dwMasterRight = 0
    self.wReqTableID=INVALID_TABLE
    self.wReqChairID=INVALID_CHAIR
end

function ServerMatchItemController:gameName()
    local gameName = ServerMatchData:GetMatchExeNameByKind(self.gameKind.dwKindID)
    if not gameName then
        local dataMsgBox = {
            nodeParent=self.frameScene,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="获取游戏种类失败，进入游戏失败！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        self:onDisconnectSocket()
        return
    end
	return gameName
end

function ServerMatchItemController:onInitServerMatch()
    print("ServerMatchItemController:onInitServerMatch")

    self:registerHandlers()
    self:initServerMatchItem()
end

function ServerMatchItemController:onCleanServerMatch( )    
    print("ServerMatchItemController:onCleanServerMatch")
    self:unRegisterHandlers()
    self:removeServiceClient()
end

function ServerMatchItemController:showLoadingWidget()
    self.loadingWidget = require("plazacenter.widgets.CommonLoadingWidget").new(self.frameScene)
end

function ServerMatchItemController:hideLoadingWidget()
    if self.loadingWidget ~= nil then
        self.loadingWidget:hideLoadingWidget()
        self.loadingWidget = nil
    end
end

function ServerMatchItemController:updateStatusLabel(statusText)
    if self.loadingWidget ~= nil then
        self.loadingWidget:updateStatusLabel(statusText)
    end
end

function ServerMatchItemController:registerHandlers()
   self.GameServerNetWork:registerDataHandlers()
   self:registerEvents()
end

function ServerMatchItemController:unRegisterHandlers()
   self.GameServerNetWork:unRegisterDataHandlers()
   self:unregisterEvents()
end
function ServerMatchItemController:registerEvents()
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
    eventListeners[appBase.Message.GS_UserRank] = handler(self, self.receiveUserRankMessage)
    eventListeners[appBase.Message.GS_UserStatus] = handler(self, self.receiveUserStatusMessage)
    eventListeners[appBase.Message.GS_UserMatchStatus] = handler(self, self.receiveUserMatchStatusMessage)
    eventListeners[appBase.Message.GS_MatchFee] = handler(self, self.receiveMatchFeeMessage)
    eventListeners[appBase.Message.GS_MatchNum] = handler(self, self.receiveMatchNumMessage)
    eventListeners[appBase.Message.GS_StartMatchClient] = handler(self, self.receiveStartMatchMessage)
    eventListeners[appBase.Message.GS_MatchStatus] = handler(self, self.receiveMatchStatusMessage)
    eventListeners[appBase.Message.GS_MatchDesc] = handler(self, self.receiveMatchDescMessage)
    eventListeners[self.plazaUserManager.Message.PLAZA_UserItemAcitve] = handler(self, self.onUserItemAcitve)
    eventListeners[self.plazaUserManager.Message.PLAZA_UserItemDelete] = handler(self, self.onUserItemDelete)
    eventListeners[self.plazaUserManager.Message.PLAZA_UserItemScoreUpdate] = handler(self, self.onUserItemScoreUpdate)
    eventListeners[self.plazaUserManager.Message.PLAZA_UserItemStatusUpdate] = handler(self, self.onUserItemStatusUpdate)
    eventListeners[self.plazaUserManager.Message.PLAZA_UserItemAttribUpdate] = handler(self, self.onUserItemAttribUpdate)
    --eventListeners[appBase.Message.Ctrl_TableViewChairClicked] = handler(self, self.receiveTableChairClickedMessage)
    eventListeners[self.GameClientManager.Message.GameClientManager_ExitMatchServer] = handler(self, self.onExitMatchServerMsg)
    
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function ServerMatchItemController:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
    self.eventHandles = {}
end

function ServerMatchItemController:onDisconnectSocket()
    self.super.onDisconnectSocket(self)
    -- 下帧返回主界面,避免游戏未退出房间已经销毁
    local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    scheduler.performWithDelayGlobal(function ()
        if self.frameScene then
            self.frameScene:exitMatchAndToPlaza()
        end
    end, 0)
end

function ServerMatchItemController:initServerMatchItem()
    self.mySelfUserItem = nil
	if self.frameScene then
		self:showLoadingWidget()
        self.serviceClient:Connect(self.matchServer.szServerIP,self.matchServer.dwServerPort)
        self:updateStatusLabel("正在连接服务器，请耐心稍候片刻")
    end
end

function ServerMatchItemController:performSitDownAction(wTableID, wChairID, bEfficacyPass)
    --if self.wReqTableID ~= INVALID_TABLE and self.wReqTableID == wTableID then
    --    return false
    --end
    --if self.wReqChairID ~= INVALID_TABLE and self.wReqChairID == wChairID then
    --    return false
    --end
    -- 自己状态
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
    if (0 ~= bit._and(self.dwUserRight, UR_CANNOT_PLAY)) then
        local dataMsgBox = {
            nodeParent=self.frameScene,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="抱歉，您暂时没有加入游戏的权限！"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return false
    end
    -- 桌子校验
    if wTableID ~= INVALID_TABLE and wChairID == INVALID_CHAIR then
        if wTableID >= self.ConfigServer.wTableCount or wChairID >= self.ConfigServer.wChairCount then
            return false
        end
    end
    -- 密码判断
    if self.mySelfUserItem.cbMasterOrder == 0 and bEfficacyPass and wTableID ~= INVALID_TABLE and wChairID == INVALID_CHAIR then
        --todo
    end
    self.wReqTableID = wTableID
    self.wReqChairID = wChairID
    self.GameServerNetWork:sendSitDownPacket(wTableID,wChairID,szPassword)
    return true
end

function ServerMatchItemController:performLookonAction(wTableID, wChairID)
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

function ServerMatchItemController:enterGameApp()
    print("ServerMatchItemController:enterGameApp()")
    -- 进入游戏
    self.GameClientManager:enterGameApp(self:gameName())
    -- 发送房间信息
    self.GameClientManager:sendMatchServerInfo({wTableID=self.mySelfUserItem.wTableID,
                            wChairID=self.mySelfUserItem.wChairID,
                            dwUserID=self.mySelfUserItem.dwUserID,
                            dwUserRight=self.dwUserRight,
                            dwMasterRight=self.dwMasterRight,
                            wKindID=self.matchServer.MatchSerial.dwKindID,
                            wServerID=self.matchServer.wServerID,
                            wServerType=self.ConfigServer.wServerType,
                            dwServerRule=self.ConfigServer.dwServerRule,
                            szServerName=self.matchServer.szRemark
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
    -- 发送比赛玩家
    if self.ConfigServer.wServerType == GAME_GENRE_MATCH then
        self.plazaUserManager:UpdateUserItemMatchRank()
        if self.plazaUserManager:GetActiveUserCount() > 0 then
            local userItems = self.plazaUserManager:GetAllUserItems()
            for k,v in pairs(userItems) do
                self.GameClientManager:sendMatchUserItem(v)

                local tagUserMatchpacket = {
                    UserMatchStatus=v.cbEnlistStatus,
                    UserRank=v.dwUserRank,
                    match_score=v.lScore,
                }
                if tagUserMatchpacket.UserMatchStatus == MS_OUT 
                    or tagUserMatchpacket.UserMatchStatus == MS_LEAVE then
                    tagUserMatchpacket.UserRank = 65535
                end
                self.GameClientManager:sendMatchUserItemUpdate(v.dwUserID,tagUserMatchpacket);
            end
        end
        self.sMatchWaitStart.NeedSortUserList=1
        self.sMatchWaitStart.MeUserID = self.mySelfUserItem.dwUserID
        self:OnSocketSubMatchClientStatus()
    end
    local IPC_GF_MatchClient = {
        cbMatchStatus=self.mySelfUserItem.cbEnlistStatus
    }
    if IPC_GF_MatchClient.cbMatchStatus == MS_MATCHING or self.ClientCanSendFinish == 1 then
        -- 发送配置完成
        self.GameClientManager:sendProcessData(IPC_CMD_GF_CONFIG,IPC_SUB_GF_CONFIG_FINISH,IPC_GF_MatchClient)
        -- 发送获取比赛场景
        self:requestCommand(MDM_GR_MATCH,SUB_GR_MATCH_RECOME)
    end
end

function ServerMatchItemController:getClientVersion()
    local version = AppBaseInstanse.PLAZACENTER_APP:getClientVersion(self.gameKind.dwKindID,eGameItemType.eItemTypeMatchGame) or VERSION_GAME
    return version
end

function ServerMatchItemController:receiveConnectMessage(event)
   if event.para.bConnectSucc then
        print("bConnectSucc: 连接成功！")
        self.GameServerNetWork:sendLoginMsg(self.gameKind.dwKindID, VERSION_FRAME, self:getClientVersion())
        self:updateStatusLabel("正在验证用户登录信息")
    else
        local dataMsgBox = {
            nodeParent=self.frameScene,
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

function ServerMatchItemController:receiveGameShutDownMessage(event)
   print("ServerMatchItemController:receiveGameShutDownMessage:"..event.para.cbShutReason)

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
                    self:initServerMatchItem()
                else                    
                    self:onDisconnectSocket()
                end
            end
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    end
   
end

function ServerMatchItemController:receiveGameLoginSuccessMessage(event)
    local Params = event.para
    self.dwUserRight=Params.dwUserRight
    self.dwMasterRight=Params.dwMasterRight
    self:updateStatusLabel("正在读取房间信息")
    -- 清空用户列表
    self.plazaUserManager:removeAllUserItems()
end

function ServerMatchItemController:receiveGameLoginFailedMessage(event)
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

function ServerMatchItemController:receiveGameLoginFinishMessage(event)
    self:hideLoadingWidget()
    -- 进入游戏
    if self.mySelfUserItem and self.mySelfUserItem.wTableID ~= INVALID_TABLE then
        self:enterGameApp()
    end
    -- 发送比赛用户进入
    if (self.ConfigServer.wServerType == GAME_GENRE_MATCH) then
        self:requestCommand(MDM_GR_USER,SUB_GR_MATCHUSER_COME)
    end
end

function ServerMatchItemController:receiveUpdateNotifyMessage(event)
    local Params = event.para

    local dataMsgBox = {
        nodeParent=self.frameScene,
        msgboxType=MSGBOX_TYPE_OKCANCEL,
        msgInfo="游戏已经升级，是否进行升级？(建议在Wifi环境下升级)",
        callBack=function(ret)
            if ret == MSGBOX_RETURN_OK then
                AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
                    name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_DownLoadClient,
                    para = {wKindID=self.gameKind.dwKindID,nItemType=eGameItemType.eItemTypeMatchGame}
                })
            end
            self:hideLoadingWidget()
        end
    }
    self:onDisconnectSocket()
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function ServerMatchItemController:receiveConfigServerMessage(event)
    self.ConfigServer = event.para
    print("receiveConfigServerMessage")
    for k,v in pairs(self.ConfigServer) do
        print(k,v)
    end
end

function ServerMatchItemController:receiveConfigUserRightMessage(event)
    print("receiveConfigUserRightMessage")
    self.dwUserRight = event.para.dwUserRight
end

function ServerMatchItemController:receiveRequestFailureMessage(event)
    local Params = event.para

    -- 设置变量
    self.wReqTableID = INVALID_TABLE
    self.wReqChairID = INVALID_CHAIR

    local dataMsgBox = {
        nodeParent=self.frameScene,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString,
        callBack=function()
            self:hideLoadingWidget()
        end
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function ServerMatchItemController:onUserItemAcitve(event)
    local clientUserItem = event.para
    -- 判断自己
    if not self.mySelfUserItem then
        self.mySelfUserItem = clientUserItem
    end
end

function ServerMatchItemController:onUserItemDelete(event)
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

end

function ServerMatchItemController:onUserItemScoreUpdate(event)
    local clientUserItem = event.para.clientUserItem
    local preUserScore = event.para.preUserScore
    -- 界面通知
    if clientUserItem.dwUserID == GlobalUserInfo.dwUserID then
        print("onUserItemScoreUpdate ",clientUserItem.lScore)
        -- 是否体验场
        if (0 == bit._and(self.ConfigServer.dwServerRule, SR_IS_TRAIN_ROOM)) then
            if GAME_GENRE_GOLD == self.ConfigServer.wServerType then
                GlobalUserInfo.lUserScore = GlobalUserInfo.lUserScore+clientUserItem.lScore-preUserScore.lScore
            end
            GlobalUserInfo.lUserInsure = GlobalUserInfo.lUserInsure+clientUserItem.lInsure-preUserScore.lInsure
            GlobalUserInfo.dwUserMedal = GlobalUserInfo.dwUserMedal+clientUserItem.dwUserMedal-preUserScore.dwUserMedal
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
                                lLoveLiness = clientUserItem.lLoveLiness}
        -- 发送数据
        self.GameClientManager:sendUserScore(clientUserItem.dwUserID,UserScore);
    end
end

function ServerMatchItemController:onUserItemStatusUpdate(event)
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

function ServerMatchItemController:onUserItemAttribUpdate(event)
    -- body
end

function ServerMatchItemController:receiveUserEnterMessage(event)
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
                else
                    break
                end
            end
        end 
    else
        userInfo.szNickName = "游戏玩家"
    end
    userInfo.dwUserRank=65535

    local clientUserItem = self.plazaUserManager:SearchUserByUserID(userInfo.dwUserID)
    if clientUserItem then
        self.plazaUserManager:DeleteUserItem(userInfo.dwUserID)
    end
    self.plazaUserManager:ActiveUserItem(userInfo)
    self.GameClientManager:sendMatchUserItem(userInfo)
end

function ServerMatchItemController:receiveUserScoreMessage(event)
    local userScoreInfo = event.para
    if userScoreInfo then
        local clientUserItem = self.plazaUserManager:SearchUserByUserID(userScoreInfo.dwUserID)
        if not clientUserItem then
            return
        end
        self.plazaUserManager:UpdateUserItemScore(userScoreInfo.dwUserID,userScoreInfo.UserScore)
    end    
end

function ServerMatchItemController:receiveUserRankMessage(event)
    local userRank = event.para
    if userRank then
        local clientUserItem = self.plazaUserManager:SearchUserByUserID(userRank.dwUserID)
        if not clientUserItem then
            return
        end
        self.plazaUserManager:UpdateUserItemMatchRank()

        local tagUserMatchpacket = {
            UserMatchStatus=clientUserItem.cbEnlistStatus,
            UserRank=clientUserItem.dwUserRank,
            match_score=clientUserItem.lScore,
        }
        if tagUserMatchpacket.UserMatchStatus == MS_OUT 
            or tagUserMatchpacket.UserMatchStatus == MS_LEAVE then
            tagUserMatchpacket.UserRank = 65535
        end
        self.GameClientManager:sendMatchUserItemUpdate(clientUserItem.dwUserID,tagUserMatchpacket);
    end    
end

function ServerMatchItemController:receiveUserStatusMessage(event)
    local userStatusInfo = event.para
    if userStatusInfo then
        local clientUserItem = self.plazaUserManager:SearchUserByUserID(userStatusInfo.dwUserID)
        if not clientUserItem then
            return
        end
        if userStatusInfo.UserStatus.cbUserStatus==US_NULL then
            if self.sMatchWaitStart.dwmatchStatus~=MS_MATCHING
                and clientUserItem.cbEnlistStatus==MS_LEAVE then
                self.GameClientManager:sendMatchUserItemLeave(clientUserItem);
            end
            self.plazaUserManager:DeleteUserItem(userStatusInfo.dwUserID)
        else
            self.plazaUserManager:UpdateUserItemStatus(userStatusInfo.dwUserID,userStatusInfo.UserStatus)
        end
    end    
end

function ServerMatchItemController:receiveUserMatchStatusMessage(event)
    local userMatchStatusInfo = event.para
    if userMatchStatusInfo then
        local clientUserItem = self.plazaUserManager:SearchUserByUserID(userMatchStatusInfo.dwUserID)
        if not clientUserItem then
            return
        end
        self.plazaUserManager:UpdateUserMatchStatus(userMatchStatusInfo.dwUserID,userMatchStatusInfo.cbEnlistStatus)

        local tagUserMatchpacket = {
            UserMatchStatus=clientUserItem.cbEnlistStatus,
            UserRank=clientUserItem.dwUserRank,
            match_score=clientUserItem.lScore,
        }
        if tagUserMatchpacket.UserMatchStatus == MS_OUT 
            or tagUserMatchpacket.UserMatchStatus == MS_LEAVE then
            tagUserMatchpacket.UserRank = 65535
        end
        self.GameClientManager:sendMatchUserItemUpdate(clientUserItem.dwUserID,tagUserMatchpacket);
    end
end

function ServerMatchItemController:receiveMatchFeeMessage(event)
    self:requestCommand(MDM_GR_MATCH,SUB_GR_MATCH_FEE,event.para,"CMD_GR_Match_Fee")
end

function ServerMatchItemController:OnSocketSubMatchClientStatus()
    self.GameClientManager:sendProcessData(MDM_GF_FRAME,SUB_GR_MATCHCLIENT_STATUS,self.sMatchWaitStart)
end
function ServerMatchItemController:receiveMatchNumMessage(event)
    local matchNum = event.para
    self.sMatchWaitStart.dwTotal = matchNum.dwTotal
    self.sMatchWaitStart.dwWaitting = matchNum.dwWaitting
    self.sMatchWaitStart.MeUserID = self.mySelfUserItem.dwUserID
    self.sMatchWaitStart.NeedSortUserList = 0
    self:OnSocketSubMatchClientStatus()
end

function ServerMatchItemController:receiveStartMatchMessage(event)
    self.ClientCanSendFinish = event.para.m_ClientCanSendFinish
end

function ServerMatchItemController:receiveMatchStatusMessage(event)
    if self.sMatchWaitStart.dwmatchStatus==MS_MATCHING then
        return
    end
    self.sMatchWaitStart.dwmatchStatus=event.para.dwmatchStatus
    self.sMatchWaitStart.MeUserID = self.mySelfUserItem.dwUserID
    self.sMatchWaitStart.NeedSortUserList = 0
    self:OnSocketSubMatchClientStatus()
end

function ServerMatchItemController:receiveMatchDescMessage(event)
    self.sMatchWaitStart.d_MatchDesc = event.para
end

function ServerMatchItemController:receiveTableChairClickedMessage(event)
    local wTableID = event.para.wTableID
    local wChairID = event.para.wChairID
    local chairUserItem = event.para.chairUserItem
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
            self:performLookonAction(wTableID,wChairID)
        end
    else
        self:performSitDownAction(wTableID,wChairID,true)
    end
end

function ServerMatchItemController:onExitMatchServerMsg(event)
    local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    scheduler.performWithDelayGlobal(function ()
        self.super.onDisconnectSocket(self)
        if self.frameScene then
            self.frameScene:exitMatchAndToPlaza()
        end
        if self.matchServer.MatchSerial.dwMatchType >= 4 then -- 满人开赛 更新报名状态
            ServerMatchData:MatchWithDraw(self.matchServer.MatchSerial.dwMatchInfoID)
        end
        if event.para.bSignNextMatch then
            -- 满人开赛
            if self.matchServer.MatchSerial.dwMatchType == 4 then
                if self.matchServer.dwSignUp == NoSignUp then
                    local tagMatchID = {
                        dwClientVersion=self:getClientVersion(),
                        MatchSerial=self.matchServer.MatchSerial
                    }
                    self.frameScene.MissionMatch:requestCommand(MDM_GL_C_DATA,SUB_GL_C_MATCH_SIGNUP,tagMatchID,"tagMatchID")
                end
            else
                local newMatchInfo = ServerMatchData:GetNextatch(self.matchServer.MatchSerial.dwKindID, 
                    self.matchServer.MatchSerial.dwMatchType, ServerMatchData:GetSortID(self.matchServer))
                if newMatchInfo and newMatchInfo.dwSignUp == NoSignUp then
                    local tagMatchID = {
                        dwClientVersion=self:getClientVersion(),
                        MatchSerial=newMatchInfo.MatchSerial
                    }
                    self.frameScene.MissionMatch:requestCommand(MDM_GL_C_DATA,SUB_GL_C_MATCH_SIGNUP,tagMatchID,"tagMatchID")
                end
            end
        end
    end, 0)
end

return ServerMatchItemController