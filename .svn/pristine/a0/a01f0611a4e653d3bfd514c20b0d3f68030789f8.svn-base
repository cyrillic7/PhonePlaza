local MissionItem = require("plazacenter.controllers.MissionItem")
local MissionList = class("MissionList",MissionItem)

function MissionList:ctor(frameScene,ServerIpInfo)
	self.frameScene = frameScene
	self.ServerIpInfo = ServerIpInfo

	MissionList.super.ctor(self,CLIENT_TYPE_LOGIN_POINT,"LoginServer_GetOnlines")
	self.LoginNetWork = require("plazacenter.controllers.LoginNetWork").new(self.scriptHandler,self.serviceClient)
end

function MissionList:onInitServer()
    print("MissionList:onInitServer")

    self:registerHandlers()
    self:initLoginServer()
end

function MissionList:onCleanServer( )    
    print("MissionList:onCleanServer")
    self:unRegisterHandlers()
    self:removeServiceClient()
    self.LoginNetWork = nil
end

function MissionList:registerHandlers()
   self.LoginNetWork:registerDataHandlers()
   self:registerEvents()
end

function MissionList:unRegisterHandlers()
   self.LoginNetWork:unRegisterDataHandlers()
   self:unregisterEvents()
end
function MissionList:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[appBase.Message.LP_LinkConnect] = handler(self, self.receiveConnectMessage)
    eventListeners[appBase.Message.LP_KindOnline] = handler(self, self.receiveKindOnlineMessage)
    eventListeners[appBase.Message.LP_ServerOnline] = handler(self, self.receiveServerOnlineMessage)
    
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function MissionList:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
    self.eventHandles = {}
end

function MissionList:initLoginServer()
    if self.frameScene then
        self.serviceClient:Connect(self.ServerIpInfo.szServerIP, self.ServerIpInfo.dwServerPort)
    end
end

function MissionList:receiveConnectMessage(event)
   if event.para.bConnectSucc then
        print("MissionList bConnectSucc: 连接成功！")
        --self.LoginNetWork:sendLoginMsg()
    else
        print("MissionList bConnectSucc: 连接失败！")
    end
end

function MissionList:receiveKindOnlineMessage(event)
   print("MissionList:receiveKindOnlineMessage")
   
end

function MissionList:receiveServerOnlineMessage(event)
   print("MissionList:receiveServerOnlineMessage")
   
end

return MissionList