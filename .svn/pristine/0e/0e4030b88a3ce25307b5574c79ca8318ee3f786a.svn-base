
import(".Kernel.GameDefine")

local OxtbNewApp = class("OxtbNewApp", cc.mvc.AppBase)

function OxtbNewApp:ctor()

    OxtbNewApp.super.ctor(self)
    
    --全局实例
    
    AppBaseInstanse.OxtbNewApp = self

    -- 游戏内消息模块
    self.EventCenter = require("common.NotificationCenter").new()

--进入前台
    self:addEventListener("APP_ENTER_FOREGROUND_EVENT", handler(self, self.receiveEnterForegroundMessage))
end

function OxtbNewApp:run(clientManger)
    local SceneErRenLand = require("oxtbnew.App.Scene.OxtbNew")
   
    self.m_SceneErRenLand=SceneErRenLand.new({gameClient=clientManger})
    cc.Director:getInstance():pushScene(self.m_SceneErRenLand)

end
--前台
function OxtbNewApp:receiveEnterForegroundMessage(event)
end

return OxtbNewApp