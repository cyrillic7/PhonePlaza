
CURRENT_MODULE_NAME = ...

local  TurntableApp = class("TurntableApp", cc.mvc.AppBase)

function TurntableApp:ctor()
    TurntableApp.super.ctor(self)

    AppBaseInstanse.TurntableApp = self
    -- 游戏内消息模块
    self.notificationCenter = require("common.NotificationCenter").new()

    -- 消息定义
    self.Message = {
    	-- 游戏进入房间后的初期化消息
    	Status = "TURNTABLE_STATUSMESSAGE",
        -- 场景恢复的消息
        Scene = "TURNTABLE_SCENEMESSAGE",
        -- 游戏开始
        Start = "TURNTABLE_STARTMESSAGE",
        --游戏空闲
        Free  = "TURNTABLE_FREEMESSAGE",
        -- 下注
        Bet = "TURNTABLE_BETMESSAGE",
        --下注失败
        BetFail = "TURNTABLE_BETFAILMESSAGE",
        --申请做坐
        ApplyBanker    = "TURNTABLE_APPLYBANKERMESSAGE",
        --取消做坐
        CancelBanker = "TURNTABLE_CancelBANKERMESSAGE",
        --抢庄消息
        QiangBanker = "TURNTABLE_QIANGBANKERMESSAGE",
        --等待上庄
        WaitBanker = "TURNTABLE_WAITBANKERMESSAGE",
        --刷新记录
        UpdateRecord = "TURNTABLE_UPDATERECORDMESSAGE",
        --刷新玩家列表
        UpdatePlayerList = "TURNTABLE_UPDATEPLAYERLISTMESSAGE",
        --刷新玩家列表项
        UpdatePlayerListItem = "TURNTABLE_UPDATEPLAYERLISTITEMMESSAGE",
        --移除玩家项
        DeletePlayerItem   = "TURNTABLE_DELETEPLAYERITEMMESSAGE",
        --游戏结束
        RoundOver  =  "TURNTABLE_ROUNDOVERMESSAGE",
        --游戏记录
        GameRecord     = "TURNTABLE_GAMERECORDMESSAGE",
        --切换庄家
        ChangeBanker = "TURNTABLE_CHANGEBANKERMESSAGE",
        --银行信息
        InsureInfo   = "TURNTABLE_INSUREINFOMESSAGE",
        --银行操作成功
        InsureSuccess = "TURNTABLE_INSURESUCCESSMESSAGE",
        --银行操作失败
        InsureFailure = "TURNTABLE_INSUREFAILUREMESSAGE",
	}

    self:addEventListener("APP_ENTER_FOREGROUND_EVENT", handler(self, self.receiveEnterForegroundMessage))
end

function TurntableApp:run(clientManger)
    local scene = require("transferbattle.App.Scene.turntableScene").new{gameClient = clientManger}
    cc.Director:getInstance():pushScene(scene)
end

function TurntableApp:receiveEnterForegroundMessage(event)
end

return TurntableApp