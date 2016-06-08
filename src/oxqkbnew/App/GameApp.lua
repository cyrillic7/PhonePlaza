
import(".Kernel.GameDefine")

local OxqkbnewApp = class("OxqkbnewApp", cc.mvc.AppBase)

function OxqkbnewApp:ctor()

    OxqkbnewApp.super.ctor(self)
    
    --全局实例
    AppBaseInstanse.OxqkbnewApp = self

    -- 游戏内消息模块
    self.EventCenter = require("common.NotificationCenter").new()

--进入前台
    self:addEventListener("APP_ENTER_FOREGROUND_EVENT", handler(self, self.receiveEnterForegroundMessage))
end

function OxqkbnewApp:run(clientManger)
    local SceneErRenLand = require("oxqkbnew.App.Scene.Oxqkbnew")
   
    self.m_SceneErRenLand=SceneErRenLand.new({gameClient=clientManger})
    cc.Director:getInstance():pushScene(self.m_SceneErRenLand)

end
--前台
function OxqkbnewApp:receiveEnterForegroundMessage(event)
end

return OxqkbnewApp