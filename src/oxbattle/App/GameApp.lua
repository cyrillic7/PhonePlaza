
import(".Kernel.GameDefine")

local oxBattleApp = class("oxBattleApp", cc.mvc.AppBase)

function oxBattleApp:ctor()

    oxBattleApp.super.ctor(self)
    
    --全局实例
    
    AppBaseInstanse.oxBattleApp = self

    -- 游戏内消息模块
    self.EventCenter = require("common.NotificationCenter").new()

--进入前台
    self:addEventListener("APP_ENTER_FOREGROUND_EVENT", handler(self, self.receiveEnterForegroundMessage))
end

function oxBattleApp:run(clientManger)
    local SceneErRenLand = require("oxbattle.App.Scene.oxBattle")
   
    self.m_SceneErRenLand=SceneErRenLand.new({gameClient=clientManger})
    cc.Director:getInstance():pushScene(self.m_SceneErRenLand)

end
--前台
function oxBattleApp:receiveEnterForegroundMessage(event)
end

return oxBattleApp