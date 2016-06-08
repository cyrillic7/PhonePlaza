
import(".Kernel.GameDefine")

local ErRenLandApp = class("ErRenLandApp", cc.mvc.AppBase)

function ErRenLandApp:ctor()

    ErRenLandApp.super.ctor(self)
    
    --全局实例
    AppBaseInstanse.ErRenLandApp = self

    -- 游戏内消息模块
    self.EventCenter = require("common.NotificationCenter").new()

--进入前台
    self:addEventListener("APP_ENTER_FOREGROUND_EVENT", handler(self, self.receiveEnterForegroundMessage))
end

function ErRenLandApp:run(clientManger)
    local SceneErRenLand = require("errenlandmatch.App.Scene.ErRenLandScene")
   
    self.m_SceneErRenLand=SceneErRenLand.new({gameClient=clientManger})
    cc.Director:getInstance():pushScene(self.m_SceneErRenLand)

end
--前台
function ErRenLandApp:receiveEnterForegroundMessage(event)
end

return ErRenLandApp