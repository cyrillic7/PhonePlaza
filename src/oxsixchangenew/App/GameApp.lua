
import(".Kernel.GameDefine")

local OxsixChangeNewApp = class("OxsixChangeNewApp", cc.mvc.AppBase)

function OxsixChangeNewApp:ctor()

    OxsixChangeNewApp.super.ctor(self)
    
    --全局实例
    AppBaseInstanse.OxsixChangeNewApp = self

    -- 游戏内消息模块
    self.EventCenter = require("common.NotificationCenter").new()

--进入前台
    self:addEventListener("APP_ENTER_FOREGROUND_EVENT", handler(self, self.receiveEnterForegroundMessage))
end

function OxsixChangeNewApp:run(clientManger)
    local SceneErRenLand = require("oxsixchangenew.App.Scene.OxsixChangeNew")
   
    self.m_SceneErRenLand=SceneErRenLand.new({gameClient=clientManger})
    cc.Director:getInstance():pushScene(self.m_SceneErRenLand)

end
--前台
function OxsixChangeNewApp:receiveEnterForegroundMessage(event)
end

return OxsixChangeNewApp