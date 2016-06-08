
import(".Kernel.GameDefine")

local RednineBattleApp = class("RednineBattleApp", cc.mvc.AppBase)

function RednineBattleApp:ctor()

    RednineBattleApp.super.ctor(self)
    
    --全局实例
    AppBaseInstanse.RednineBattleApp = self

    -- 游戏内消息模块
    self.EventCenter = require("common.NotificationCenter").new()

--进入前台
    self:addEventListener("APP_ENTER_FOREGROUND_EVENT", handler(self, self.receiveEnterForegroundMessage))
end

function RednineBattleApp:run(clientManger)
    local SceneErRenLand = require("redninebattle.App.Scene.RednineBattle")
   
    self.m_SceneErRenLand=SceneErRenLand.new({gameClient=clientManger})
    cc.Director:getInstance():pushScene(self.m_SceneErRenLand)

end
--前台
function RednineBattleApp:receiveEnterForegroundMessage(event)
end

return RednineBattleApp