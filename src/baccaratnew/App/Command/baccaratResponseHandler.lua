local baccaratResponseHandler = class("baccaratResponseHandler")

require("common.GameServerDefine")
require("baccaratnew.App.MsgDefine.baccaratServerDef")

local commonMsg = require("common.GameUserManagerController").Message


local currentModule = ...

function baccaratResponseHandler:ctor(client)
	-- 消息模块
    --cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.client = client
end

function baccaratResponseHandler:registerPlayHandlers()
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

function baccaratResponseHandler:unregisterPlayHandlers()
	self.client:removeSocketResponseHandlersByTable(self.Handlers)
end

function baccaratResponseHandler:OnSocketSubGameStatusMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.Status,
            para = Params,
        })
end

function baccaratResponseHandler:OnSocketSubGameSceneMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.Scene,
            para = Params,
        })

end

function baccaratResponseHandler:OnSocketSubGameStartMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.Start,
            para = Params,
        })
end

function baccaratResponseHandler:OnSocketSubGameFreeMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.Free,
            para = Params,
        })
end

function baccaratResponseHandler:OnSocketSubUserBetMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.Bet,
            para = Params,
        })

  
end


function baccaratResponseHandler:OnSocketSubApplyBankerMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.ApplyBanker,
            para = Params,
        })

   
end

function baccaratResponseHandler:OnSocketSubCancelBankerMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.CancelBanker,
            para = Params,
        })

    
end

function baccaratResponseHandler:OnSocketSubQiangZhuanMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.QiangBanker,
            para = Params,
        })
end

function baccaratResponseHandler:OnSocketSubChangeBankerMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.ChangeBanker,
            para = Params,
        })

   
end

function baccaratResponseHandler:OnSocketSubGameRoundOverMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.RoundOver,
            para = Params,
        })  
end

function baccaratResponseHandler:OnSocketSubGameRecordMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.GameRecord,
            para = Params,
        })
end


function baccaratResponseHandler:OnSocketSubUserBetFailedMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.BetFail,
            para = Params,
        })
end

function baccaratResponseHandler:OnSocketSubWaitBankerMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.WaitBanker,
            para = Params,
        })
end

function baccaratResponseHandler:OnSocketSubInsureInfoMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.InsureInfo,
            para = Params,
        })
end

function baccaratResponseHandler:OnSocketSubInsureSuccessMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.InsureSuccess,
            para = Params,
        })
end

function baccaratResponseHandler:OnSocketSubInsureFailureMsg(Params)
    AppBaseInstanse.BaccaratApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.BaccaratApp.Message.InsureFailure,
            para = Params,
        })
end

return baccaratResponseHandler