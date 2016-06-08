local MissionItem = require("plazacenter.controllers.MissionItem")
local MissionMatch = class("MissionMatch",MissionItem)

function MissionMatch:ctor(frameScene,MatchIp)
	self.frameScene = frameScene
	self.MatchIp = MatchIp

	MissionMatch.super.ctor(self,CLIENT_TYPE_LOBBY_SERVER,"LobbyServer")
	self.LobbyServerNetWork = require("plazacenter.controllers.LobbyServerNetWork").new(self.scriptHandler,self.serviceClient)
end

function MissionMatch:onInitServer()
    print("MissionMatch:onInitServer")

    self:registerHandlers()
    self:initLobbyServer()
end

function MissionMatch:onCleanServer( )    
    print("MissionMatch:onCleanServer")
    self:unRegisterHandlers()
    self:removeServiceClient()
    self.LobbyServerNetWork = nil
end

function MissionMatch:registerHandlers()
   self.LobbyServerNetWork:registerDataHandlers()
   self:registerEvents()
end

function MissionMatch:unRegisterHandlers()
   self.LobbyServerNetWork:unRegisterDataHandlers()
   self:unregisterEvents()
end
function MissionMatch:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[appBase.Message.LS_LinkConnect] = handler(self, self.receiveConnectMessage)
    eventListeners[appBase.Message.LS_LinkShutDown] = handler(self, self.receiveGameShutDownMessage)
    eventListeners[appBase.Message.LS_LoginFailure] = handler(self, self.receiveLoginFailureMessage)
    eventListeners[appBase.Message.LS_SignUpFailure] = handler(self, self.receiveSignUpFailureMessage)
    eventListeners[appBase.Message.LS_SystemMessage] = handler(self, self.receiveSystemMessageMessage)
    eventListeners[appBase.Message.LS_OthersMessage] = handler(self, self.receiveOthersMessageMessage)
    eventListeners[appBase.Message.LS_WithDrawFailure] = handler(self, self.receiveWithDrawFailureMessage)
    
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
    -- 前后台消息捕获
    self.backgroundHandler = appBase:addEventListener(appBase.APP_ENTER_BACKGROUND_EVENT, handler(self, self.receiveEnterBackgroundMsg))
    self.foregroundHandler = appBase:addEventListener(appBase.APP_ENTER_FOREGROUND_EVENT, handler(self, self.receiveEnterForegroundMsg))

    self.appBase = appBase
end

function MissionMatch:unregisterEvents()
    self.appBase.notificationCenter:removeAllListenerByTable(self.eventHandles) 
    self.eventHandles = {}
    -- 前后台消息捕获
    self.appBase:removeEventListener(self.backgroundHandler)
    self.appBase:removeEventListener(self.foregroundHandler)
end

function MissionMatch:initLobbyServer()
    if self.frameScene then
        self.serviceClient:Connect(self.MatchIp.szServerIP, self.MatchIp.dwServerPort)
    end
end

function MissionMatch:registerReConnect()
    if not self.reConnectCount then
        self.reConnectCount = 0
    end
    self.reConnectCount = self.reConnectCount + 1
    if self.reConnectCount > 20 then
        self.reConnectCount = 20
    end
    if self.frameScene then
        self.frameScene:performWithDelay(function ()
            self:initLobbyServer()
            print("MissionMatch:registerReConnect",self.reConnectCount)
        end, self.reConnectCount*5)
    end
end

function MissionMatch:receiveConnectMessage(event)
   if event.para.bConnectSucc then
        print("bConnectSucc: 连接成功！")
        self.LobbyServerNetWork:sendLoginMsg()
        self.reConnectCount = 0
    else
        print("MissionMatch:Connect Failed")
        self:registerReConnect()
        --[[local dataMsgBox = {
            nodeParent=self.frameScene,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo="连接大厅服务器失败,比赛等相关功能将不能正常使用"
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)]]
    end
end

function MissionMatch:receiveGameShutDownMessage(event)
   print("MissionMatch:receiveGameShutDownMessage:"..event.para.cbShutReason)

   if event.para.cbShutReason ~= 0 then
        print("MissionMatch:ShutDown Message")
        self:registerReConnect()
        --[[local dataMsgBox = {
            nodeParent=self.frameScene,
            msgboxType=MSGBOX_TYPE_OKCANCEL,
            msgInfo="与大厅服务器断开连接，是否重新连接？",
            callBack=function(ret)
                if ret == MSGBOX_RETURN_OK then
                    self:initLobbyServer()
                else                    
                    self:onDisconnectSocket()
                end
            end
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)]]
   end
   
end

function MissionMatch:receiveLoginFailureMessage(event)
   local Params = event.para

    local dataMsgBox = {
        nodeParent=self.frameScene,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function MissionMatch:receiveSignUpFailureMessage(event)
   local Params = event.para

    local dataMsgBox = {
        nodeParent=self.frameScene,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
   
end

function MissionMatch:receiveSystemMessageMessage(event)
   print("MissionMatch:receiveSystemMessageMessage")
   
end

function MissionMatch:receiveOthersMessageMessage(event)
   --print("MissionMatch:receiveOthersMessageMessage")
   
end

function MissionMatch:receiveWithDrawFailureMessage(event)
   local Params = event.para

    local dataMsgBox = {
        nodeParent=self.frameScene,
        msgboxType=MSGBOX_TYPE_OK,
        msgInfo=Params.szDescribeString
    }
    require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
end

function MissionMatch:receiveEnterBackgroundMsg(event)
    --dump("receiveEnterBackgroundMsg")
    -- 断链
    self:onDisconnectSocket()
end

function MissionMatch:receiveEnterForegroundMsg(event)
    --dump("receiveEnterForegroundMsg")
    -- 重连
    self:initLobbyServer()
end

return MissionMatch