
CURRENT_MODULE_NAME = ...

local NinePieceApp = class("NinePieceApp", cc.mvc.AppBase)

function NinePieceApp:ctor()
    NinePieceApp.super.ctor(self)

    AppBaseInstanse.NinePieceApp = self
    -- 游戏内消息模块
    self.notificationCenter = require("common.NotificationCenter").new()

    -- 消息定义
    self.Message = {
    	-- 游戏进入房间后的初期化消息
    	Status = "NINE_STATUSMESSAGE",
        -- 下注的消息
        Scene = "NINE_SCENEMESSAGE",
        -- 游戏开始
        Start = "NINE_STARTMESSAGE",
        -- 出牌
        OutCard = "NINE_OUTCARDMESSAGE",
        --过牌
        Pass    = "NINE_PASSMESSAGE",
        --一局结束
        RoundOver = "NINE_ROUNDOVERMESSAGE",
        --url
        ConcludeUrl = "NINE_CONCLUDEURLMESSAGE",
        --BaseScore
        BaseScore  = "NINE_BASESCOREMESSAGE",
	}

    self:addEventListener("APP_ENTER_FOREGROUND_EVENT", handler(self, self.receiveEnterForegroundMessage))
end

function NinePieceApp:run(clientManger)
    local SceneNinePieces = require("ys9zhang.App.Scene.ninePieceScene").new{gameClient = clientManger}
    cc.Director:getInstance():pushScene(SceneNinePieces)
end

function NinePieceApp:receiveEnterForegroundMessage(event)
end

return NinePieceApp