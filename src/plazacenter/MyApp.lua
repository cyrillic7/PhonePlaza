require("common.config")
require("cocos.init")
require("framework.init")
require("common.GlobleData")
require("common.GameUtil")
require("common.GlobleDefine")
require("common.SessionManagerEx")
require("plazacenter.GlobalPlazaCenterDef")
require("plazacenter.data.ServerListData")
require("plazacenter.data.ServerMatchData")

local MyApp = class("MyApp", cc.mvc.AppBase)

collectgarbage("setpause", 100)  
collectgarbage("setstepmul", 5000)

MyApp.lastPopWidget = nil

function MyApp:ctor(...)
    MyApp.super.ctor(self,...)
    AppBaseInstanse.PLAZACENTER_APP = self
     -- 游戏内消息模块
    self.notificationCenter = require("common.NotificationCenter").new()

    self.Message = {
    	-- 登录点相关消息
    	LP_LinkConnect = "LP_LinkConnect",
    	LP_LinkShutDown = "LP_LinkShutDown",
        LP_LoginSuccess = "LP_LoginSuccess",
        LP_LoginFailure = "LP_LoginFailure",
        LP_LoginFinish = "LP_LoginFinish",
        LP_UpdateNotify = "LP_UpdateNotify",
        LP_LobbyIP = "LP_LobbyIP",
        LP_Theme = "LP_Theme",

        LP_ListType = "LP_ListType",
        LP_ListKind = "LP_ListKind",
        LP_ListServer = "LP_ListServer",
        LP_ListFinish = "LP_ListFinish",
        
        LP_QuickLoginSuccess = "LP_QuickLoginSuccess",

        LP_KindOnline = "LP_KindOnline",
        LP_ServerOnline = "LP_ServerOnline",

        -- 游戏服务器相关消息
        GS_LinkConnect = "GS_LinkConnect",
        GS_LinkShutDown = "GS_LinkShutDown",
        GS_LoginSuccess = "GS_LoginSuccess",
        GS_LoginFailure = "GS_LoginFailure",
        GS_LoginFinish = "GS_LoginFinish",
        GS_UpdateNotify = "GS_UpdateNotify",

        GS_ConfigServer = "GS_ConfigServer",
        GS_ConfigFinish = "GS_ConfigFinish",
        GS_ConfigUserRight = "GS_ConfigUserRight",
        GS_UserEnter = "GS_UserEnter",
        GS_UserScore = "GS_UserScore",
        GS_UserStatus = "GS_UserStatus",
        GS_RequestFailure = "GS_RequestFailure",
        GS_WaitDistribute = "GS_WaitDistribute",
        GS_TableInfo = "GS_TableInfo",
        GS_TableStatus = "GS_TableStatus",
        GS_SystemMessage = "GS_SystemMessage",
        GS_ActionMessage = "GS_ActionMessage",
         -- 比赛
         GS_UserRank = "GS_UserRank",
         GS_UserMatchStatus = "GS_UserMatchStatus",
         GS_MatchFee = "GS_MatchFee",
         GS_MatchNum = "GS_MatchNum",
         GS_StartMatchClient = "GS_StartMatchClient",
         GS_MatchStatus = "GS_MatchStatus",
         GS_MatchDesc = "GS_MatchDesc",         

        -- 大厅服务器
        LS_LinkConnect = "LS_LinkConnect",
        LS_LinkShutDown = "LS_LinkShutDown",
        LS_LoginSuccess = "LS_LoginSuccess",
        LS_LoginFailure = "LS_LoginFailure",
        LS_SignUpFailure = "LS_SignUpFailure",
        LS_SystemMessage = "LS_SystemMessage",
        LS_OthersMessage = "LS_OthersMessage",
        LS_WithDrawFailure = "LS_WithDrawFailure",
        LS_TaskLoaded = "LS_TaskLoaded",
        LS_TaskReward = "LS_TaskReward",
        LS_LoadFriend = "LS_LoadFriend",
        LS_FriendLvReward = "LS_FriendLvReward",
        LS_GetLvReward = "LS_GetLvReward",
        LS_GetFriendCountAward = "LS_GetFriendCountAward",
        LS_GetFriendReward = "LS_GetFriendReward",
        LS_GetHornMessage = "LS_GetHornMessage",
        LS_GetSendHornRes = "LS_GetSendHornRes",

        -- 控件消息
        Ctrl_UpdateUserInfo = "Ctrl_UpdateUserInfo",
        Ctrl_GameTypeSelectChanged = "Ctrl_GameTypeSelectChanged",
        Ctrl_GameItemClicked = "Ctrl_GameItemClicked",
        Ctrl_GameServerItemClicked = "Ctrl_GameServerItemClicked",
        Ctrl_TableViewChairClicked = "Ctrl_TableViewChairClicked",
        Ctrl_QuickJoinBtnClicked = "Ctrl_QuickJoinBtnClicked",
        Ctrl_SetTableLockBtnClicked = "Ctrl_SetTableLockBtnClicked",
        Ctrl_ChangeSkinBg = "Ctrl_ChangeSkinBg",
        Ctrl_ShowBankWidget = "Ctrl_ShowBankWidget",
        Ctrl_OpenTopupWidget = "Ctrl_OpenTopupWidget",
        Ctrl_DownLoadClient = "Ctrl_DownLoadClient",
        Ctrl_HasFinishedTask = "Ctrl_HasFinishedTask",
	}

end

function MyApp:buttonTouchEvent(btn)
    if btn then
        btn:onButtonPressed(function ()
            btn:scaleTo(0.1,0.9)
        end)
        btn:onButtonRelease(function ()
            btn:scaleTo(0.1,1)
        end)
    end
end

function MyApp:setLastPopWidget(widget)
    if not widget then
        self.lastPopWidget = widget
        return
    end
    if self.lastPopWidget then
        if type(self.lastPopWidget) == "userdata" then
            self.lastPopWidget:removeFromParent()
            self.lastPopWidget = nil
        end
    end
    self.lastPopWidget = widget
end

function MyApp:getLastPopWidget()
    return self.lastPopWidget
end

function MyApp:getLastPopWidgetType()
    if self.lastPopWidget then
        return self.lastPopWidget.widgetType
    end
end

-- return version,strExeName
function MyApp:getClientVersion(wKindID,nItemType)
    -- 获取版本号
    local strExeName = nil
    if nItemType == eGameItemType.eItemTypeNormalGame then
        strExeName = ServerListData:GetGameExeNameByKind(wKindID)
    elseif nItemType == eGameItemType.eItemTypeMatchGame then
        strExeName = ServerMatchData:GetMatchExeNameByKind(wKindID)
    end
    if not strExeName then
        return false,false
    end
    local version = G_RequireFile(strExeName.."/version.lua")
    return version,strExeName
end

function MyApp:run()
    local writePath = cc.FileUtils:getInstance():getWritablePath()
    cc.FileUtils:getInstance():addSearchPath(writePath,true)
    cc.FileUtils:getInstance():addSearchPath(writePath.."res/",true)
    cc.FileUtils:getInstance():addSearchPath(writePath.."res/publish/",true)
    cc.FileUtils:getInstance():addSearchPath(writePath.."res/plist/",true)
    cc.FileUtils:getInstance():addSearchPath("res/")
    cc.FileUtils:getInstance():addSearchPath("res/publish/")
    cc.FileUtils:getInstance():addSearchPath("res/plist/")
    self:enterScene("LoginScene")
    --self:enterScene("CompanyLogoScene")
end

return MyApp
