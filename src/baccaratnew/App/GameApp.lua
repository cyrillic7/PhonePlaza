
CURRENT_MODULE_NAME = ...

local  BaccaratApp = class("BaccaratApp", cc.mvc.AppBase)

function BaccaratApp:ctor()
    BaccaratApp.super.ctor(self)

    AppBaseInstanse.BaccaratApp = self
    -- 游戏内消息模块
    self.notificationCenter = require("common.NotificationCenter").new()

    -- 消息定义
    self.Message = {
    	-- 游戏进入房间后的初期化消息
    	Status = "BACCARAT_STATUSMESSAGE",
        -- 场景恢复的消息
        Scene = "BACCARAT_SCENEMESSAGE",
        -- 游戏开始
        Start = "BACCARAT_STARTMESSAGE",
        --游戏空闲
        Free  = "BACCARAT_FREEMESSAGE",
        -- 下注
        Bet = "BACCARAT_BETMESSAGE",
        --下注失败
        BetFail = "BACCARAT_BETFAILMESSAGE",
        --申请做坐
        ApplyBanker    = "BACCARAT_APPLYBANKERMESSAGE",
        --取消做坐
        CancelBanker = "BACCARAT_CancelBANKERMESSAGE",
        --抢庄消息
        QiangBanker = "BACCARAT_QIANGBANKERMESSAGE",
        --等待上庄
        WaitBanker = "BACCARAT_WAITBANKERMESSAGE",
        --刷新记录
        UpdateRecord = "BACCARAT_UPDATERECORDMESSAGE",
        --刷新玩家列表
        UpdatePlayerList = "BACCARAT_UPDATEPLAYERLISTMESSAGE",
        --刷新玩家列表项
        UpdatePlayerListItem = "BACCARAT_UPDATEPLAYERLISTITEMMESSAGE",
        --移除玩家项
        DeletePlayerItem   = "BACCARAT_DELETEPLAYERITEMMESSAGE",
        --游戏结束
        RoundOver  =  "BACCARAT_ROUNDOVERMESSAGE",
        --游戏记录
        GameRecord     = "BACCARAT_GAMERECORDMESSAGE",
        --切换庄家
        ChangeBanker = "BACCARAT_CHANGEBANKERMESSAGE",
        --银行信息
        InsureInfo   = "BACCARAT_INSUREINFOMESSAGE",
        --银行操作成功
        InsureSuccess = "BACCARAT_INSURESUCCESSMESSAGE",
        --银行操作失败
        InsureFailure = "BACCARAT_INSUREFAILUREMESSAGE",
	}

    self:addEventListener("APP_ENTER_FOREGROUND_EVENT", handler(self, self.receiveEnterForegroundMessage))
end

function BaccaratApp:run(clientManger)
    local scene = require("baccaratnew.App.Scene.baccaratScene").new{gameClient = clientManger}
    cc.Director:getInstance():pushScene(scene)
end

function BaccaratApp:receiveEnterForegroundMessage(event)
end

return BaccaratApp