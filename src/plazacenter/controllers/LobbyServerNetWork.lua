require("common.LobbyServerDefine")
require("plazacenter.data.ServerMatchData")

local LobbyServerNetWork = class("LobbyServerNetWork")

function LobbyServerNetWork:ctor(scriptHandler, serviceClient)
	self.scriptHandler = scriptHandler
	self.serviceClient = serviceClient
end

function LobbyServerNetWork:registerDataHandlers()
    -- network
	self.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETLINK, handler(self, self.onEventTCPSocketLink))
    self.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETSHUT, handler(self, self.onEventTCPSocketShut))
    -- login
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_LOGON_SUCCESS, handler(self, self.OnSocketSubLogonSuccess))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_LOGON_FAILURE, handler(self, self.OnSocketSubLogonFailure))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_MATCH_GAME, handler(self, self.OnSocketSubMatchGame))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_MATCH_TYPE, handler(self, self.OnSocketSubMatchType))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_MATCH_INFO, handler(self, self.OnSocketSubMatchInfo))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_MATCH_RANK, handler(self, self.OnSocketSubAwardInfo))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_MATCH_DELETE, handler(self, self.OnSocketSubMatchDelete))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_MATCH_NUM, handler(self, self.OnSocketSubMatchNum))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_MATCH_START, handler(self, self.OnSocketSubMatchStart))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_SIGNUP_SUCCESS, handler(self, self.OnSocketSubSignUpSuccess))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_SIGNUP_FAILURE, handler(self, self.OnSocketSubSignUpFailure))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_UPDATE_NOTIFY, handler(self, self.OnSocketSubUpdateNotify))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_SYSTEM_MESSAGE, handler(self, self.OnSocketSubSystemMessage))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_MESSAGE, handler(self, self.OnSocketSubMessage))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_WITHDRAW_SUCCESS, handler(self, self.OnSocketSubWithDrawSuccess))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_WITHDRAW_FAILURE, handler(self, self.OnSocketSubWithDrawFailure))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_MATCH_COUNTDOWN, handler(self, self.OnSocketSubCountDown))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_TASK_LOAD, handler(self, self.OnSocketSubTaskLoaded))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_TASK_REWARD, handler(self, self.OnSocketSubTaskReward))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_LOAD_FRIEND, handler(self, self.OnSocketSubLoadFriend))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_LEVEL_REWARD, handler(self, self.OnSocketSubFriendLvReward))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_GET_LEVEL_REWARD, handler(self, self.OnSocketSubGetLvReward))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_GET_FRIEND_COUNT, handler(self, self.OnSocketSubGetFriendCountAward))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_GET_FRIEND_REWARD, handler(self, self.OnSocketSubGetFriendReward))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_LABA, handler(self, self.OnSocketHornMessage))
    self.scriptHandler:registerResponseHandler(MDM_GL_C_DATA, SUB_GL_C_LABA_LOG, handler(self, self.OnSocketSubSendHornRes))
end

function LobbyServerNetWork:unRegisterDataHandlers()
	self.scriptHandler:unregisterResponseHandler()
end

function LobbyServerNetWork:ParseStructGroup(unResolvedData,structName)
    local group = {}
    if unResolvedData.sizeNotCut < 1 then
        return group
    end
    local item = self.serviceClient:ParseStruct(unResolvedData.dataNotCutPtr,unResolvedData.sizeNotCut, structName)
    while item ~= nil do
        table.insert(group, item)
        if item.unResolvedData ~= nil and item.unResolvedData.sizeNotCut > 0 then
            item = self.serviceClient:ParseStruct(item.unResolvedData.dataNotCutPtr,item.unResolvedData.sizeNotCut, structName)
        else
            item = nil
        end
    end
    
    return group
end

function LobbyServerNetWork:onEventTCPSocketLink( Params )
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_LinkConnect,
            para = Params,
        })
    --print("LobbyServerNetWork:onEventTCPSocketLink")
    ServerMatchData:ResetDate()
end

function LobbyServerNetWork:onEventTCPSocketShut( Params )
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_LinkShutDown,
            para = Params,
        })
    --print("LobbyServerNetWork:onEventTCPSocketShut")
end

function LobbyServerNetWork:OnSocketSubLogonSuccess(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_LoginSuccess,
            para = Params
        })

    --print("LobbyServerNetWork:OnSocketSubLogonSuccess")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function LobbyServerNetWork:OnSocketSubLogonFailure(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_LoginFailure,
            para = Params
        })
    --print("LobbyServerNetWork:OnSocketSubLogonFailure")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function LobbyServerNetWork:OnSocketSubMatchGame(Params)
    --AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
    --        name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_LoginFinish,
    --        para = Params
    --    })
    --print("LobbyServerNetWork:OnSocketSubMatchGame")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
    ServerMatchData:InsertMatchKind(Params)
    if Params.unResolvedData ~= nil then
        local gameTypes = self:ParseStructGroup(Params.unResolvedData,"CMD_GL_MatchGame") or {}
        for k,v in pairs(gameTypes) do
            --for k,v in pairs(v) do
            --    print(k,v)
            --end
            ServerMatchData:InsertMatchKind(v)
        end
    end
end

function LobbyServerNetWork:OnSocketSubMatchType(Params)
    --AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
    --        name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_UpdateNotify,
    --        para = Params
    --    })
    --print("LobbyServerNetWork:OnSocketSubMatchType")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
    ServerMatchData:InsertMatchType(Params)
    if Params.unResolvedData ~= nil then
        local gameTypes = self:ParseStructGroup(Params.unResolvedData,"CMD_GL_MatchType") or {}
        for k,v in pairs(gameTypes) do
            --for k,v in pairs(v) do
            --    print(k,v)
            --end
            ServerMatchData:InsertMatchType(v)
        end
    end
end

function LobbyServerNetWork:OnSocketSubMatchInfo(Params)
    --print("LobbyServerNetWork:OnSocketSubMatchInfo")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end

    ServerMatchData:InsertMatchInfo(Params)
    --AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
    --        name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_ConfigServer,
    --        para = Params
    --    })
end

function LobbyServerNetWork:OnSocketSubAwardInfo(Params)
    --AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
    --       name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_ConfigFinish,
    --        para = Params
    --    })

    --print("LobbyServerNetWork:OnSocketSubAwardInfo")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
    ServerMatchData:InsertAwardInfo(Params)
end

function LobbyServerNetWork:OnSocketSubMatchDelete(Params)
    --AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
    --        name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_ConfigUserRight,
    --        para = Params
    --    })
    --print("LobbyServerNetWork:OnSocketSubMatchDelete")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
    ServerMatchData:DeleteMatchInfo(Params.MatchSerial.dwMatchInfoID)
end

function LobbyServerNetWork:OnSocketSubMatchNum(Params)
    --AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
    --        name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_UserEnter,
    --        para = Params
    --    })
    --[[print("LobbyServerNetWork:OnSocketSubMatchNum")
    for k,v in pairs(Params) do
        print(k,v)
    end]]
    ServerMatchData:UpdateSignNum(Params)
    if Params.unResolvedData ~= nil then
        local gameTypes = self:ParseStructGroup(Params.unResolvedData,"CMD_GL_MatchNum") or {}
        for k,v in pairs(gameTypes) do
            --[[for k,v in pairs(v) do
                print(k,v)
            end]]
            ServerMatchData:UpdateSignNum(v)
        end
    end
end

function LobbyServerNetWork:OnSocketSubMatchStart(Params)
    --AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
    --        name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_UserScore,
    --        para = Params
    --    })
    --print("LobbyServerNetWork:OnSocketSubMatchStart")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
    if Params.MatchSerial.dwMatchType >= 4 then -- 满人开赛、达标赛、特殊捕鱼赛
        ServerMatchData:MatchSignUp(Params.MatchSerial.dwMatchInfoID)
    end
    ServerMatchData:MatchStart(Params)
end

function LobbyServerNetWork:OnSocketSubSignUpSuccess(Params)
    --AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
    --        name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_UserStatus,
    --        para = Params
    --   })
    --print("LobbyServerNetWork:OnSocketSubSignUpSuccess")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end

    -- 更新币
    if Params.dwSignUpScore > 0 then
        GlobalUserInfo.lUserScore = GlobalUserInfo.lUserScore - Params.dwSignUpScore
        -- 刷新用户信息
        AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_UpdateUserInfo,
            para = {}
        })
    end
    ServerMatchData:MatchSignUp(Params.MatchSerial.dwMatchInfoID)
end

function LobbyServerNetWork:OnSocketSubSignUpFailure(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_SignUpFailure,
            para = Params
        })
    --print("LobbyServerNetWork:OnSocketSubSignUpFailure")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function LobbyServerNetWork:OnSocketSubUpdateNotify(Params)
    --AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
    --       name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_WaitDistribute,
    --        para = Params
    --    })
    --print("LobbyServerNetWork:OnSocketSubUpdateNotify")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

-- 系统消息
function LobbyServerNetWork:OnSocketSubSystemMessage(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_SystemMessage,
            para = Params
        })
    --print("LobbyServerNetWork:OnSocketSubSystemMessage")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

-- 弹窗、消息、公告
function LobbyServerNetWork:OnSocketSubMessage(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_OthersMessage,
            para = Params
        })
    local CMD_GL_MsgNode = Params
    if CMD_GL_MsgNode.dwPositionType == MsgPositionType.Position_Top then
        -- 显示系统轮播消息
    elseif CMD_GL_MsgNode.dwPositionType == MsgPositionType.Position_Right then
        -- 显示平台公告    
    elseif CMD_GL_MsgNode.dwPositionType == MsgPositionType.Position_Under then
        if CMD_GL_MsgNode.dwMsgType == MsgType.Msg_Delta then
            -- 充值
            -- szMsgcontent = "恭喜，您已经成功充值1000元宝。#888#10000#"
            local szSplits = string.split(CMD_GL_MsgNode.szMsgcontent,"#")
            local curBank = szSplits[2]
            local totalBank = szSplits[3]
            if curBank and totalBank and tonumber(curBank) and tonumber(totalBank) then
                GlobalUserInfo.lUserInsure = tonumber(totalBank)
                AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
                    name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_UpdateUserInfo,
                    para = {}
                })
            end
        elseif CMD_GL_MsgNode.dwMsgType == MsgType.Msg_Rewards then
            -- 任务完成
            AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
                    name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_HasFinishedTask,
                    para = {bShow=true}
                })
        elseif CMD_GL_MsgNode.dwMsgType == MsgType.Msg_Vip then
            -- vip
            AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
                    name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_UpdateUserInfo,
                    para = {}
                })
        elseif CMD_GL_MsgNode.dwMsgType == MsgType.Msg_Sell_Success then
            -- 拍卖成功
        end
    end
end

function LobbyServerNetWork:OnSocketSubWithDrawSuccess(Params)
    --AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
    --        name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_SystemMessage,
    --        para = Params
    --    })
    --print("LobbyServerNetWork:OnSocketSubWithDrawSuccess")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end

    -- 更新币
    if Params.dwSignUpScore > 0 then
        GlobalUserInfo.lUserScore = GlobalUserInfo.lUserScore + Params.dwSignUpScore
        -- 刷新用户信息
        AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_UpdateUserInfo,
            para = {}
        })
    end
    ServerMatchData:MatchWithDraw(Params.MatchSerial.dwMatchInfoID)
end

function LobbyServerNetWork:OnSocketSubWithDrawFailure(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_WithDrawFailure,
            para = Params
        })
    --print("LobbyServerNetWork:OnSocketSubWithDrawFailure")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function LobbyServerNetWork:OnSocketSubCountDown(Params)
    --AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
    --        name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_WithDrawFailure,
    --        para = Params
    --    })
    --print("LobbyServerNetWork:OnSocketSubCountDown")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end

    ServerMatchData:UpdateMatchStartTime(Params)
end

function LobbyServerNetWork:OnSocketSubTaskLoaded(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_TaskLoaded,
            para = Params
        })
end

function LobbyServerNetWork:OnSocketSubTaskReward(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_TaskReward,
            para = Params
        })
end

function LobbyServerNetWork:OnSocketSubLoadFriend(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_LoadFriend,
            para = Params
        })
end

function LobbyServerNetWork:OnSocketSubFriendLvReward(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_FriendLvReward,
            para = Params
        })
end

function LobbyServerNetWork:OnSocketSubGetLvReward(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_GetLvReward,
            para = Params
        })
end

function LobbyServerNetWork:OnSocketSubGetFriendCountAward(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_GetFriendCountAward,
            para = Params
        })
end

function LobbyServerNetWork:OnSocketSubGetFriendReward(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_GetFriendReward,
            para = Params
        })
end

function LobbyServerNetWork:OnSocketHornMessage(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_GetHornMessage,
            para = Params
        })
end

function LobbyServerNetWork:OnSocketSubSendHornRes(Params)
    if Params.lResultCode == 0 then
        GlobalUserInfo.dwHornNum = Params.dwPropNum
    end
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LS_GetSendHornRes,
            para = Params
        })
end

function LobbyServerNetWork:sendLoginMsg()
	-- 发送登录包
    local CMD_GL_LogonAccounts = {
        szMachineID=GlobalPlatInfo.szMachineID,
        szPassword=GlobalUserInfo.szPassword,
        szAccounts=GlobalUserInfo.szAccounts,
    }

    self.serviceClient:requestCommand(MDM_GL_C_DATA,SUB_GL_MB_LOGON_ACCOUNTS,CMD_GL_LogonAccounts,"CMD_GL_LogonAccounts")
end

return LobbyServerNetWork