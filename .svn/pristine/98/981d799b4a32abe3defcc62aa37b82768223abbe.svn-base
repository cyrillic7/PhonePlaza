

local NinePiecesResponseHandler = class("NinePiecesResponseHandler")

require("common.GameServerDefine")
require("ys9zhang.App.MsgDefine.ninePieceServerDef")

local commonMsg = require("common.GameUserManagerController").Message


local currentModule = ...

function NinePiecesResponseHandler:ctor(client)
	-- 消息模块
    --cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.client = client
end

function NinePiecesResponseHandler:registerPlayHandlers()
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
		--出牌返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = SUB_S_OUT_CARD, 
			responseHandler = handler(self, self.OnSocketSubOutCardMsg)
		},
		--不出返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = SUB_S_PASS_CARD, 
			responseHandler = handler(self, self.OnSocketSubPassMsg)
		},
		--一局结束返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = SUB_S_GAME_CONCLUDE, 
			responseHandler = handler(self, self.OnSocketSubRoundOverMsg)
		},

        --显示底分消息
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = SUB_S_SET_BASESCORE, 
            responseHandler = handler(self, self.OnSocketBaseScoreMsg)
        },
        --结束图片URL
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = SUB_S_CONCLUDE_URL, 
            responseHandler = handler(self, self.OnSocketSubConcludeUrlMsg)
        },
	}

	self.client:addSocketResponseHandlersByTable(self.Handlers)
end

function NinePiecesResponseHandler:unregisterPlayHandlers()
	self.client:removeSocketResponseHandlersByTable(self.Handlers)
end

function NinePiecesResponseHandler:OnSocketSubGameStatusMsg(Params)
    AppBaseInstanse.NinePieceApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.NinePieceApp.Message.Status,
            para = Params,
        })

    print("NinePiecesResponseHandler:OnSocketSubGameStatusMsg")
    for k,v in pairs(Params) do
        print(k,v)
    end
end

function NinePiecesResponseHandler:OnSocketSubGameSceneMsg(Params)
    AppBaseInstanse.NinePieceApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.NinePieceApp.Message.Scene,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end

function NinePiecesResponseHandler:OnSocketSubGameStartMsg(Params)
    AppBaseInstanse.NinePieceApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.NinePieceApp.Message.Start,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end

function NinePiecesResponseHandler:OnSocketSubOutCardMsg(Params)
    dump(Params)
    AppBaseInstanse.NinePieceApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.NinePieceApp.Message.OutCard,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end

function NinePiecesResponseHandler:OnSocketSubPassMsg(Params)
    AppBaseInstanse.NinePieceApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.NinePieceApp.Message.Pass,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end

function NinePiecesResponseHandler:OnSocketSubRoundOverMsg(Params)
    AppBaseInstanse.NinePieceApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.NinePieceApp.Message.RoundOver,
            para = Params,
        })
end

function NinePiecesResponseHandler:OnSocketSubConcludeUrlMsg(Params)
    AppBaseInstanse.NinePieceApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.NinePieceApp.Message.ConcludeUrl,
            para = Params,
        })
    for k,v in pairs(Params) do
        print(k,v)
    end
end

function NinePiecesResponseHandler:OnSocketBaseScoreMsg( Params )
     AppBaseInstanse.NinePieceApp.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.NinePieceApp.Message.BaseScore,
            para = Params,
        })
end

return NinePiecesResponseHandler