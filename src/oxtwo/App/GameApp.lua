
import(".Kernel.GameDefine")

local OxTwoApp = class("OxTwoApp", cc.mvc.AppBase)

function OxTwoApp:ctor()

    OxTwoApp.super.ctor(self)
    
    --全局实例
    AppBaseInstanse.OxTwoApp = self

    -- 游戏内消息模块
    self.EventCenter = require("common.NotificationCenter").new()

--进入前台
    self:addEventListener("APP_ENTER_FOREGROUND_EVENT", handler(self, self.receiveEnterForegroundMessage))
end

function OxTwoApp:run(clientManger)
    local SceneErRenLand = require("oxtwo.App.Scene.OxTwo")
   
    self.m_SceneErRenLand=SceneErRenLand.new({gameClient=clientManger})
    cc.Director:getInstance():pushScene(self.m_SceneErRenLand)

end
--前台
function OxTwoApp:receiveEnterForegroundMessage(event)
end

return OxTwoApp