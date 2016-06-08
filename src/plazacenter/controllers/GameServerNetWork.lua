require("common.GameServerDefine")

local GameServerNetWork = class("GameServerNetWork")

function GameServerNetWork:ctor(scriptHandler, serviceClient, bMatchGame)
	self.scriptHandler = scriptHandler
	self.serviceClient = serviceClient
    self.bMatchGame = bMatchGame
end

function GameServerNetWork:registerDataHandlers()
    -- network
	self.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETLINK, handler(self, self.onEventTCPSocketLink))
    self.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETSHUT, handler(self, self.onEventTCPSocketShut))
    -- login
    self.scriptHandler:registerResponseHandler(MDM_GR_LOGON, SUB_GR_LOGON_SUCCESS, handler(self, self.onSocketSubLogonSuccess))
    self.scriptHandler:registerResponseHandler(MDM_GR_LOGON, SUB_GR_LOGON_FAILURE, handler(self, self.OnSocketSubLogonFailure))
    self.scriptHandler:registerResponseHandler(MDM_GR_LOGON, SUB_GR_LOGON_FINISH, handler(self, self.OnSocketSubLogonFinish))
    self.scriptHandler:registerResponseHandler(MDM_GR_LOGON, SUB_GP_UPDATE_NOTIFY, handler(self, self.OnSocketSubUpdateNotify))
    -- config
    --self.scriptHandler:registerResponseHandler(MDM_GR_CONFIG, SUB_GR_CONFIG_COLUMN, handler(self, self.onSocketSubConfigColumn))
    self.scriptHandler:registerResponseHandler(MDM_GR_CONFIG, SUB_GR_CONFIG_SERVER, handler(self, self.OnSocketSubConfigServer))
    --self.scriptHandler:registerResponseHandler(MDM_GR_CONFIG, SUB_GR_CONFIG_PROPERTY, handler(self, self.OnSocketSubConfigProperty))
    self.scriptHandler:registerResponseHandler(MDM_GR_CONFIG, SUB_GR_CONFIG_FINISH, handler(self, self.OnSocketSubConfigFinish))
    self.scriptHandler:registerResponseHandler(MDM_GR_CONFIG, SUB_GR_CONFIG_USER_RIGHT, handler(self, self.OnSocketSubConfigUserRight))
    -- user info
    self.scriptHandler:registerResponseHandler(MDM_GR_USER, SUB_GR_USER_ENTER, handler(self, self.OnSocketSubUserEnter))
    self.scriptHandler:registerResponseHandler(MDM_GR_USER, SUB_GR_USER_SCORE, handler(self, self.OnSocketSubUserScore))
    self.scriptHandler:registerResponseHandler(MDM_GR_USER, SUB_GR_USER_STATUS, handler(self, self.OnSocketSubUserStatus))
    self.scriptHandler:registerResponseHandler(MDM_GR_USER, SUB_GR_USER_MATCH_STATUS, handler(self, self.OnSocketSubUsermatchStatus))
    self.scriptHandler:registerResponseHandler(MDM_GR_USER, SUB_GR_REQUEST_FAILURE, handler(self, self.OnSocketSubRequestFailure))
    --self.scriptHandler:registerResponseHandler(MDM_GR_USER, SUB_GR_USER_WAIT_DISTRIBUTE, handler(self, self.OnSocketSubWaitDistribute))
    self.scriptHandler:registerResponseHandler(MDM_GR_USER, SUB_GR_USER_RANK, handler(self, self.OnSocketSubUserRankStatus))
    -- status info
    self.scriptHandler:registerResponseHandler(MDM_GR_STATUS, SUB_GR_TABLE_INFO, handler(self, self.OnSocketSubTableInfo))
    self.scriptHandler:registerResponseHandler(MDM_GR_STATUS, SUB_GR_TABLE_STATUS, handler(self, self.OnSocketSubTableStatus))
    -- insure
    --self.scriptHandler:registerResponseHandler(MDM_GR_INSURE, SUB_GR_USER_STATUS, handler(self, self.OnSocketSubListServer))
    -- manage
    --self.scriptHandler:registerResponseHandler(MDM_GR_MANAGE, SUB_GR_OPTION_CURRENT, handler(self, self.OnSocketSubListFinish))
    -- system
    self.scriptHandler:registerResponseHandler(MDM_CM_SYSTEM, SUB_CM_SYSTEM_MESSAGE, handler(self, self.OnSocketSubSystemMessage))
    self.scriptHandler:registerResponseHandler(MDM_CM_SYSTEM, SUB_CM_ACTION_MESSAGE, handler(self, self.OnSocketSubActionMessage))
    -- game and frame    
    -- match
    self.scriptHandler:registerResponseHandler(MDM_GR_MATCH, SUB_GR_MATCH_FEE, handler(self, self.OnSocketSubMatchFeeMessage))
    self.scriptHandler:registerResponseHandler(MDM_GR_MATCH, SUB_GR_MATCH_NUM, handler(self, self.OnSocketSubMatchNumMessage))
    self.scriptHandler:registerResponseHandler(MDM_GR_MATCH, SUB_GR_START_MATCHCLIENT, handler(self, self.OnSocketSubStartMatchMessage))
    self.scriptHandler:registerResponseHandler(MDM_GR_MATCH, SUB_GR_MATCH_STATUS, handler(self, self.OnSocketSubMatchStatusMessage))
    self.scriptHandler:registerResponseHandler(MDM_GR_MATCH, SUB_GR_MATCH_DESC, handler(self, self.OnSocketSubMatchDescMessage))
end

function GameServerNetWork:unRegisterDataHandlers()
	self.scriptHandler:unregisterResponseHandler()
end

function GameServerNetWork:ParseStructGroup(unResolvedData,structName)
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

function GameServerNetWork:onEventTCPSocketLink( Params )
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_LinkConnect,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:onEventTCPSocketLink")
end

function GameServerNetWork:onEventTCPSocketShut( Params )
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_LinkShutDown,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:onEventTCPSocketShut")
end

function GameServerNetWork:onSocketSubLogonSuccess(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_LoginSuccess,
            para = Params,
            caller = self
        })

    --print("GameServerNetWork:onSocketSubLogonSuccess")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubLogonFailure(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_LoginFailure,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubLogonFailure")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubLogonFinish(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_LoginFinish,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubLogonFinish")
    self:sendTerminal()
end

function GameServerNetWork:OnSocketSubUpdateNotify(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_UpdateNotify,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubUpdateNotify")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubConfigServer(Params)
    --print("GameServerNetWork:OnSocketSubConfigServer")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end

    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_ConfigServer,
            para = Params,
            caller = self
        })
end

function GameServerNetWork:OnSocketSubConfigFinish(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_ConfigFinish,
            para = Params,
            caller = self
        })

    --print("GameServerNetWork:OnSocketSubConfigFinish")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubConfigUserRight(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_ConfigUserRight,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubConfigUserRight")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubUserEnter(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_UserEnter,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubUserEnter")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubUserScore(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_UserScore,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubUserScore")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubUserStatus(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_UserStatus,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubUserStatus")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubUsermatchStatus(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_UserMatchStatus,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubUsermatchStatus")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubRequestFailure(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_RequestFailure,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubRequestFailure")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubWaitDistribute(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_WaitDistribute,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubWaitDistribute")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubUserRankStatus(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_UserRank,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubUserRankStatus")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubTableInfo(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_TableInfo,
            para = {tableInfo=Params,netWork=self}
        })
    --print("GameServerNetWork:OnSocketSubTableInfo")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubTableStatus(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_TableStatus,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubTableStatus")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubSystemMessage(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_SystemMessage,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubSystemMessage")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubActionMessage(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_ActionMessage,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubActionMessage")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubMatchFeeMessage(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_MatchFee,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubMatchFeeMessage")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubMatchNumMessage(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_MatchNum,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubMatchNumMessage")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubStartMatchMessage(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_StartMatchClient,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubStartMatchMessage")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubMatchStatusMessage(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_MatchStatus,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubMatchStatusMessage")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:OnSocketSubMatchDescMessage(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.GS_MatchDesc,
            para = Params,
            caller = self
        })
    --print("GameServerNetWork:OnSocketSubMatchDescMessage")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function GameServerNetWork:sendLoginMsg(wKindID, dwFrameVersion,dwProcessVersion)
	-- 发送登录包
        local request = {
        dwPlazaVersion=1,
        dwFrameVersion=dwFrameVersion or 0,
        dwProcessVersion=dwProcessVersion or 0,
        dwUserID=GlobalUserInfo.dwUserID,
        szPassword=GlobalUserInfo.szPassword,
        szMachineID=GlobalPlatInfo.szMachineID,
        wKindID=wKindID,
        szPassPortID="",
        szPhoneVerifyID=""
        }
    --    for k,v in pairs(request) do
    --        print(k,v)
    --    end
        self.serviceClient:requestCommand(MDM_GR_LOGON,SUB_GR_LOGON_USERID,request)
end

function GameServerNetWork:sendSitDownPacket(wTableID,wChairID,szPassword)
    local CMD_GR_UserSitDown = {
    wTableID=wTableID,
    wChairID=wChairID,
    szPassword=szPassword or ""
    }
    self.serviceClient:requestCommand(MDM_GR_USER,SUB_GR_USER_SITDOWN,CMD_GR_UserSitDown)
    --print("GameServerNetWork:sendSitDownPacket",wTableID,wChairID)
end

function GameServerNetWork:sendLookonPacket(wTableID,wChairID)
    local CMD_GR_UserLookon = {
        wTableID=wTableID,
        wChairID=wChairID
    }
    self.serviceClient:requestCommand(MDM_GR_USER,SUB_GR_USER_LOOKON,CMD_GR_UserLookon)
    --print("GameServerNetWork:sendLookonPacket",wTableID,wChairID)
end

function GameServerNetWork:sendUserRulePacket(szPassword)
    local CMD_GR_UserRule = {
                    cbRuleMask=0,
                    wMinWinRate=0,
                    wMaxFleeRate=0,
                    lMaxGameScore=0,
                    lMinGameScore=0,
                    szPassword=szPassword or ""
                    }
    self.serviceClient:requestCommand(MDM_GR_USER,SUB_GR_USER_RULE,CMD_GR_UserRule)
    --print("GameServerNetWork:sendUserRulePacket",szPassword)
end

function GameServerNetWork:sendTerminal()
    local CMD_GR_Terminal = {
        dwTerminal=GlobalPlatInfo.dwTerminal,
    }
    self.serviceClient:requestCommand(MDM_GR_USER,SUB_GR_TERMINAL,CMD_GR_Terminal,"CMD_GR_Terminal")
    --print("GameServerNetWork:sendTerminal",GlobalPlatInfo.dwTerminal)
end

return GameServerNetWork