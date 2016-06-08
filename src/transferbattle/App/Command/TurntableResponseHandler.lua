local TurntableResponseHandler = class("TurntableResponseHandler")

require("common.GameServerDefine")
require("transferbattle.App.MsgDefine.turnTableServerDef")

local commonMsg = require("common.GameUserManagerController").Message


local currentModule = ...

function TurntableResponseHandler:ctor(client)
	-- 消息模块
    --cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.client = client
end

function TurntableResponseHandler:registerPlayHandlers()
	self.Handlers= 
	{	
		--游戏状态消息返回处理
		{
			mainCmdID= MDM_GF_FRAME, 
			subCmdID = SUB_GF_GAME_STATUS, 
			responseHandler = handler(self, self.OnSocketSubGameStatusMsg)
		},
		--游戏场景消息返回处理
		{
			mainCmdID= MDM_GF_FRAME, 
			subCmdID = SUB_GF_GAME_SCENE, 
			responseHandler = handler(self, self.OnSocketSubGameSceneMsg)
		},
		--游戏开始消息返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = SUB_S_GAME_START, 
			responseHandler = handler(self, self.OnSocketSubGameStartMsg)
		},
        --游戏空闲
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = SUB_S_GAME_FREE, 
            responseHandler = handler(self, self.OnSocketSubGameFreeMsg)
        },
		--用户下注消息
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = SUB_S_PLACE_JETTON, 
			responseHandler = handler(self, self.OnSocketSubUserBetMsg)
		},
		--申请做庄消息
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = SUB_S_APPLY_BANKER, 
			responseHandler = handler(self, self.OnSocketSubApplyBankerMsg)
		},
		--取消做庄消息
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = SUB_S_CANCEL_BANKER, 
			responseHandler = handler(self, self.OnSocketSubCancelBankerMsg)
		},

        --抢庄消息返回
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = SUB_S_QIANG_ZHUAN, 
            responseHandler = handler(self, self.OnSocketSubQiangZhuanMsg)
        },
        --切换庄家消息
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = SUB_S_CHANGE_BANKER, 
            responseHandler = handler(self, self.OnSocketSubChangeBankerMsg)
        },

          --游戏结束
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = SUB_S_GAME_END, 
            responseHandler = handler(self, self.OnSocketSubGameRoundOverMsg)
        },

          --游戏记录
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = SUB_S_SEND_RECORD, 
            responseHandler = handler(self, self.OnSocketSubGameRecordMsg)
        },
        --下注失败消息返回处理
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = SUB_S_PLACE_JETTON_FAIL, 
            responseHandler = handler(self, self.OnSocketSubUserBetFailedMsg)
        },
        --等待上庄
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = SUB_S_WAIT_BANKER, 
            responseHandler = handler(self, self.OnSocketSubWaitBankerMsg)
        },
        --银行消息返回
        {
            mainCmdID=MDM_GR_INSURE, 
            subCmdID = SUB_GR_USER_INSURE_INFO, 
            responseHandler = handler(self, self.OnSocketSubInsureInfoMsg)
        },
        --银行操作成功
        {
            mainCmdID=MDM_GR_INSURE, 
            subCmdID = SUB_GR_USER_INSURE_SUCCESS, 
            responseHandler = handler(self, self.OnSocketSubInsureSuccessMsg)
        },
        --银行操作失败
        {
            mainCmdID=MDM_GR_INSURE, 
            subCmdID = SUB_GR_USER_INSURE_FAILURE, 
            responseHandler = handler(self, self.OnSocketSubInsureFailureMsg)
        },
	}

	self.client:addSocketResponseHandlersByTable(self.Handlers)
end

function TurntableResponseHandler:unregisterPlayHandlers()
	self.client:removeSocketResponseHandlersByTable(self.Handlers)
end

function TurntableResponseHandler:OnSocketSubGameStatusMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.Status,
            para = Params,
        })
end

function TurntableResponseHandler:OnSocketSubGameSceneMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.Scene,
            para = Params,
        })

end

function TurntableResponseHandler:OnSocketSubGameStartMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.Start,
            para = Params,
        })
end

function TurntableResponseHandler:OnSocketSubGameFreeMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.Free,
            para = Params,
        })
end

function TurntableResponseHandler:OnSocketSubUserBetMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.Bet,
            para = Params,
        })

  
end


function TurntableResponseHandler:OnSocketSubApplyBankerMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.ApplyBanker,
            para = Params,
        })

   
end

function TurntableResponseHandler:OnSocketSubCancelBankerMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.CancelBanker,
            para = Params,
        })

    
end

function TurntableResponseHandler:OnSocketSubQiangZhuanMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.QiangBanker,
            para = Params,
        })
end

function TurntableResponseHandler:OnSocketSubChangeBankerMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.ChangeBanker,
            para = Params,
        })

   
end

function TurntableResponseHandler:OnSocketSubGameRoundOverMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.RoundOver,
            para = Params,
        })

   
end

function TurntableResponseHandler:OnSocketSubGameRecordMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.GameRecord,
            para = Params,
        })
end


function TurntableResponseHandler:OnSocketSubUserBetFailedMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.BetFail,
            para = Params,
        })
end

function TurntableResponseHandler:OnSocketSubWaitBankerMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.WaitBanker,
            para = Params,
        })
end

function TurntableResponseHandler:OnSocketSubInsureInfoMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.InsureInfo,
            para = Params,
        })
end

function TurntableResponseHandler:OnSocketSubInsureSuccessMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.InsureSuccess,
            para = Params,
        })
end

function TurntableResponseHandler:OnSocketSubInsureFailureMsg(Params)
    AppBaseInstanse.TurntableApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.TurntableApp.Message.InsureFailure,
            para = Params,
        })
end

return TurntableResponseHandler