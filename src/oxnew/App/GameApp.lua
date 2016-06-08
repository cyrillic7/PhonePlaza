
import(".Kernel.GameDefine")

local OxNewApp = class("OxNewApp", cc.mvc.AppBase)

function OxNewApp:ctor()

    OxNewApp.super.ctor(self)
    
    --全局实例
    AppBaseInstanse.OxNewApp = self

    -- 游戏内消息模块
    self.EventCenter = require("common.NotificationCenter").new()

--进入前台
    self:addEventListener("APP_ENTER_FOREGROUND_EVENT", handler(self, self.receiveEnterForegroundMessage))
end

function OxNewApp:run(clientManger)
    local SceneErRenLand = require("oxnew.App.Scene.OxNew")
   
    self.m_SceneErRenLand=SceneErRenLand.new({gameClient=clientManger})
    cc.Director:getInstance():pushScene(self.m_SceneErRenLand)

end
--前台
function OxNewApp:receiveEnterForegroundMessage(event)
end

return OxNewApp