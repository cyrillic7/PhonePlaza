
import(".Kernel.GameDefine")

local ShowHandApp = class("ShowHandApp", cc.mvc.AppBase)

function ShowHandApp:ctor()

    ShowHandApp.super.ctor(self)
    
    --全局实例
    AppBaseInstanse.ShowHandApp = self

    -- 游戏内消息模块
    self.EventCenter = require("common.NotificationCenter").new()

--进入前台
    self:addEventListener("APP_ENTER_FOREGROUND_EVENT", handler(self, self.receiveEnterForegroundMessage))
end

function ShowHandApp:run(clientManger)
    local SceneShowhand = require("showhandanex.App.Scene.ShowHandSence")
   
    self.m_SceneShowHand=SceneShowhand.new({gameClient=clientManger})
    cc.Director:getInstance():pushScene(self.m_SceneShowHand)

end
--前台
function ShowHandApp:receiveEnterForegroundMessage(event)
end

return ShowHandApp