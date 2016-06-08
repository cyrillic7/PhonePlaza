require("common.LogonServerDefine")
require("plazacenter.data.ServerListData")

local LoginNetWork = class("LoginNetWork")

LoginNetWork.ACCOUNT_LOGIN = 1
LoginNetWork.QQ_LOGIN = 2
LoginNetWork.ACCOUNT_REGISTER = 3
LoginNetWork.QUICK_LOGIN = 4
LoginNetWork.WEIXIN_LOGIN = 5

function LoginNetWork:ctor(scriptHandler, serviceClient)
	self.scriptHandler = scriptHandler
	self.serviceClient = serviceClient
    self.loginType = LoginNetWork.ACCOUNT_LOGIN
end

function LoginNetWork:registerDataHandlers()
    -- network
	self.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETLINK, handler(self, self.onEventTCPSocketLink))
    self.scriptHandler:registerResponseHandler(MDM_ALL_LINK, SUB_ALL_LINK_SOCKETSHUT, handler(self, self.onEventTCPSocketShut))
    -- login
    self.scriptHandler:registerResponseHandler(MDM_GP_LOGON, SUB_GP_LOGON_SUCCESS, handler(self, self.onSocketSubLogonSuccess))
    self.scriptHandler:registerResponseHandler(MDM_GP_LOGON, SUB_GP_LOBBY_IP, handler(self, self.onSocketSubLobbyIP))
    self.scriptHandler:registerResponseHandler(MDM_GP_LOGON, SUB_GP_THEME, handler(self, self.onSocketSubTheme))
    self.scriptHandler:registerResponseHandler(MDM_GP_LOGON, SUB_GP_LOGON_FAILURE, handler(self, self.OnSocketSubLogonFailure))
    self.scriptHandler:registerResponseHandler(MDM_GP_LOGON, SUB_GP_LOGON_FINISH, handler(self, self.OnSocketSubLogonFinish))
    self.scriptHandler:registerResponseHandler(MDM_GP_LOGON, SUB_GP_UPDATE_NOTIFY, handler(self, self.OnSocketSubUpdateNotify))
    -- list server
    self.scriptHandler:registerResponseHandler(MDM_GP_SERVER_LIST, SUB_GP_LIST_TYPE, handler(self, self.onSocketSubListType))
    self.scriptHandler:registerResponseHandler(MDM_GP_SERVER_LIST, SUB_GP_LIST_KIND, handler(self, self.onSocketSubListKind))
    self.scriptHandler:registerResponseHandler(MDM_GP_SERVER_LIST, SUB_GP_LIST_SERVER, handler(self, self.OnSocketSubListServer))
    self.scriptHandler:registerResponseHandler(MDM_GP_SERVER_LIST, SUB_GP_LIST_FINISH, handler(self, self.OnSocketSubListFinish))
    self.scriptHandler:registerResponseHandler(MDM_GP_SERVER_LIST, SUB_GP_WEB, handler(self, self.OnSocketSubWebIPs))

    self.scriptHandler:registerResponseHandler(MDM_GP_SERVER_LIST, SUB_GR_KINE_ONLINE, handler(self, self.OnSocketSubKindOnline))
    self.scriptHandler:registerResponseHandler(MDM_GP_SERVER_LIST, SUB_GR_SERVER_ONLINE, handler(self, self.OnSocketSubServerOnline))

    self.scriptHandler:registerResponseHandler(MDM_MB_LOGON, SUB_MB_QUICK_LOGIN, handler(self, self.onSocketSubQuickLogonSuccess))
    
end

function LoginNetWork:unRegisterDataHandlers()
	self.scriptHandler:unregisterResponseHandler()
end

function LoginNetWork:ParseStructGroup(unResolvedData,structName)
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

function LoginNetWork:setLoginType(loginType)
    self.loginType = loginType or self.loginType
end

function LoginNetWork:onEventTCPSocketLink( Params )
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_LinkConnect,
            para = Params,
        })
end

function LoginNetWork:onEventTCPSocketShut( Params )
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_LinkShutDown,
            para = Params,
        })
end

function LoginNetWork:onSocketSubLogonSuccess(Params)
    GlobalUserInfo.wFaceID=Params.wFaceID or 0
    GlobalUserInfo.cbGender=Params.cbGender or 0
    GlobalUserInfo.dwGameID=Params.dwGameID or 0
    GlobalUserInfo.dwUserID=Params.dwUserID or 0
    GlobalUserInfo.dwCustomID=Params.dwCustomID or 0
    GlobalUserInfo.dwUserMedal=Params.dwUserMedal or 0
    GlobalUserInfo.dwExperience=Params.dwExperience or 0
    GlobalUserInfo.lLoveLiness=Params.lLoveLiness or 0
    GlobalUserInfo.cbMoorMachine=Params.cbMoorMachine or 0
    GlobalUserInfo.lUserIngot = Params.lIngot or 0
    GlobalUserInfo.lIngotScore = Params.lIngotScore or 0
    GlobalUserInfo.dwVipLevel = Params.dwVipLevel or 0
    GlobalUserInfo.lUserScore=Params.lUserScore or 0
    GlobalUserInfo.lUserInsure=Params.lUserInsure or 0
    GlobalUserInfo.szAccounts=Params.szAccounts or ""
    GlobalUserInfo.szNickName=Params.szNickName or ""

    GlobalUserInfo.cbMoorPassPortID=Params.cbMoorPassPortID or 0
    GlobalUserInfo.cbMoorPhone=Params.cbMoorPhone or 0
    GlobalUserInfo.szPassPortID=Params.szPassPortID or ""
    GlobalUserInfo.szMobilePhone=Params.szPhone or ""

    if Params.unResolvedData ~= nil then
        local  unResolvedData = Params.unResolvedData
        local DataDes = self.serviceClient:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"tagDataDescribe")
        while DataDes ~= nil do
            --for k,v in pairs(DataDes) do
            --    print(k,v)
            --end
            unResolvedData = DataDes.unResolvedData
            -- vipinfo
            if DataDes.wDataDescribe == DTP_GP_MEMBER_INFO then
                local MemberInfo = self.serviceClient:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"DTP_GP_MemberInfo")
                if MemberInfo ~= nil then
                    GlobalUserInfo.cbMemberOrder=MemberInfo.cbMemberOrder or 0;
                    GlobalUserInfo.MemberOverDate=MemberInfo.MemberOverDate or 0;
                    if MemberInfo.unResolvedData ~= nil then
                        DataDes = self.serviceClient:ParseStruct(MemberInfo.unResolvedData.dataPtr,MemberInfo.unResolvedData.size,"tagDataDescribe")
                    else
                        DataDes = nil
                    end
                else
                    break
                end
            -- under_write
            elseif DataDes.wDataDescribe == DTP_GP_UNDER_WRITE then
                local underWrite = self.serviceClient:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"DTP_GP_UnderWrite")
                if underWrite ~= nil then
                    GlobalUserInfo.szUnderWrite=underWrite.szUnderWrite or "";
                    if underWrite.unResolvedData ~= nil then
                        DataDes = self.serviceClient:ParseStruct(underWrite.unResolvedData.dataPtr,underWrite.unResolvedData.size,"tagDataDescribe")
                    else
                        DataDes = nil
                    end
                else
                    break
                end
            -- set insure password
            elseif DataDes.wDataDescribe == DTP_GP_SET_INSURE_PWD then
                local setInsurePwd = self.serviceClient:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"DTP_GP_SetInsurePwd")
                if setInsurePwd ~= nil then
                    GlobalUserInfo.cbInsurePwd=setInsurePwd.cbInsurePwd or 0;
                    if setInsurePwd.unResolvedData ~= nil then
                        DataDes = self.serviceClient:ParseStruct(setInsurePwd.unResolvedData.dataPtr,setInsurePwd.unResolvedData.size,"tagDataDescribe")
                    else
                        DataDes = nil
                    end
                else
                    break
                end
            -- 充值金额
            elseif DataDes.wDataDescribe == DTP_GP_GET_MONEY then
                local money = self.serviceClient:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"DTP_GP_GetMoney")
                if money ~= nil then
                    GlobalUserInfo.dwPayMoney=money.dwMoney or 0;
                    if money.unResolvedData ~= nil then
                        DataDes = self.serviceClient:ParseStruct(money.unResolvedData.dataPtr,money.unResolvedData.size,"tagDataDescribe")
                    else
                        DataDes = nil
                    end
                else
                    break
                end
            -- 完成任务 未读信息
            elseif DataDes.wDataDescribe == DTP_GP_GET_NOTIFY_COUNT then
                local notify = self.serviceClient:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"DTP_GP_NotifyCount")
                if notify ~= nil then
                    GlobalUserInfo.szUnderWrite=notify.szUnderWrite or "";
                    if notify.unResolvedData ~= nil then
                        DataDes = self.serviceClient:ParseStruct(notify.unResolvedData.dataPtr,notify.unResolvedData.size,"tagDataDescribe")
                    else
                        DataDes = nil
                    end
                else
                    break
                end
            -- 喇叭数
            elseif DataDes.wDataDescribe == DTP_GP_GET_LABA_COUNT then
                local laba = self.serviceClient:ParseStruct(unResolvedData.dataPtr,unResolvedData.size,"DTP_GP_GetLabaCount")
                if laba ~= nil then
                    GlobalUserInfo.dwHornNum=laba.dwLabaCount or 0;
                    if laba.unResolvedData ~= nil then
                        DataDes = self.serviceClient:ParseStruct(laba.unResolvedData.dataPtr,laba.unResolvedData.size,"tagDataDescribe")
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

    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_LoginSuccess,
            para = Params
        })

    -- 保存最近帐号
    if self.loginType ~= LoginNetWork.QQ_LOGIN then
        SessionManager:sharedManager():setLastAcount({acount=GlobalUserInfo.szAccounts,password=GlobalUserInfo.szPassword})
    end
end

function LoginNetWork:onSocketSubLobbyIP(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_LobbyIP,
            para = Params
        })

    --print("LoginNetWork:onSocketSubLobbyIP")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end

    GlobalLobbyServerInfo = Params
end

function LoginNetWork:onSocketSubTheme(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_Theme,
            para = Params
        })
    --print("LoginNetWork:onSocketSubTheme")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function LoginNetWork:OnSocketSubLogonFailure(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_LoginFailure,
            para = Params
        })
    --print("LoginNetWork:OnSocketSubLogonFailure")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function LoginNetWork:OnSocketSubLogonFinish(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_LoginFinish,
            para = Params
        })
    --print("LoginNetWork:OnSocketSubLogonFinish")
end

function LoginNetWork:OnSocketSubUpdateNotify(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_UpdateNotify,
            para = Params
        })
    --print("LoginNetWork:OnSocketSubUpdateNotify")
    --for k,v in pairs(Params) do
    --    print(k,v)
    --end
end

function LoginNetWork:onSocketSubListType(Params)
    --print("LoginNetWork:onSocketSubListType")
    ServerListData:InsertGameType(Params)
    if Params.unResolvedData ~= nil then
        local gameTypes = self:ParseStructGroup(Params.unResolvedData,"tagGameType") or {}
        for k,v in pairs(gameTypes) do
            ServerListData:InsertGameType(v)
        end
    end

    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_ListType,
            para = Params
        })
end

function LoginNetWork:onSocketSubListKind(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_ListKind,
            para = Params
        })
    --print("LoginNetWork:onSocketSubListKind")
    ServerListData:InsertGameKind(Params)
    if Params.unResolvedData ~= nil then
        local gameKind = self:ParseStructGroup(Params.unResolvedData,"tagGameKind") or {}
        for k,v in pairs(gameKind) do
            ServerListData:InsertGameKind(v)
        end
    end
end

function LoginNetWork:OnSocketSubListServer(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_ListServer,
            para = Params
        })
    --print("LoginNetWork:OnSocketSubListServer")
    ServerListData:InsertGameServer(Params)
    if Params.unResolvedData ~= nil then
        local gameServers = self:ParseStructGroup(Params.unResolvedData,"tagGameServer") or {}
        for k,v in pairs(gameServers) do
            ServerListData:InsertGameServer(v)
        end
    end
end

function LoginNetWork:OnSocketSubListFinish(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_ListFinish,
            para = Params
        })
    --print("LoginNetWork:OnSocketSubListFinish")
end

function LoginNetWork:OnSocketSubWebIPs(Params)
    GlobalWebIPs = {
        szHomeWebIP=Params.szHomeWebIP or "",
        szActiveWebIP=Params.szActiveWebIP or "",
        szMallWebIP=Params.szMallWebIP or "http://121.41.116.223:8090",
        szPayWebIP=Params.szPayWebIP or "",
        szDownLoadWebIP=Params.szDownLoadWebIP or "",
    }
end

function LoginNetWork:OnSocketSubKindOnline(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_KindOnline,
            para = Params
        })
    --print("LoginNetWork:OnSocketSubKindOnline")
end

function LoginNetWork:OnSocketSubServerOnline(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_ServerOnline,
            para = Params
        })
    --print("LoginNetWork:OnSocketSubServerOnline")
end

function LoginNetWork:onSocketSubQuickLogonSuccess(Params)
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.LP_QuickLoginSuccess,
            para = Params
        })
    --print("LoginNetWork:onSocketSubQuickLogonSuccess")
end

function LoginNetWork:sendLoginMsg(acount,pwd,pwdIsMD5,szPassPortID)
        if not pwdIsMD5 then
            GlobalUserInfo.szPassword=cc.Crypto:MD5(pwd,false)
        else
            GlobalUserInfo.szPassword=pwd
        end
    -- 发送登录包
        local request = {
        dwPlazaVersion=GlobalPlatInfo.dwPlazaVersion,
        szMachineID=GlobalPlatInfo.szMachineID,
        szPassPortID=szPassPortID or "",
        szPhoneVerifyID="",
        szPassword=GlobalUserInfo.szPassword,
        szAccounts=acount,
        cbValidateFlags=0
        }

        self.serviceClient:requestCommand(MDM_GP_LOGON,SUB_GP_LOGON_ACCOUNTS,request)
end

function LoginNetWork:sendRegisterMsg(CMD_GP_RegisterAccounts)
    --dump(CMD_GP_RegisterAccounts)
    GlobalUserInfo.szPassword=CMD_GP_RegisterAccounts.szLogonPass
    self.serviceClient:requestCommand(MDM_GP_LOGON,SUB_GP_REGISTER_ACCOUNTS,CMD_GP_RegisterAccounts,"CMD_GP_RegisterAccounts")
end

return LoginNetWork