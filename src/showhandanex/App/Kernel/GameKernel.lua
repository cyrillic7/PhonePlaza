--数据引擎
local GameclientKernel = class("GameclientKernel")

require("common.GameServerDefine")

--构造本类
function GameclientKernel:ctor(serviceClient)
    self.serviceClient = serviceClient
    self.App = AppBaseInstanse.ShowHandApp
    --注册网络事件
    self:registerPlayHandlers()
end

--網絡接收事件註冊
function GameclientKernel:registerPlayHandlers()
	self.Handlers= 
	{	
		--游戏场景消息返回处理
		{

          mainCmdID= MDM_GF_FRAME,
          subCmdID = SUB_GF_GAME_SCENE,
		  responseHandler = handler(self, self.OnSocketSubGameScene)
		},
		--游戏开始消息返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = ShowHandDefine.SUB_S_GAME_START, 
			responseHandler = handler(self, self.OnSocketSubGameStart)
		},

		--加注返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = ShowHandDefine.SUB_S_ADD_GOLD, 
			responseHandler = handler(self, self.OnSocketSubAddScore)
		},
		--放弃信息返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = ShowHandDefine.SUB_S_GIVE_UP, 
			responseHandler = handler(self, self.OnSocketSubGiveUp)
		},
		--发牌返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = ShowHandDefine.SUB_S_SEND_CARD, 
			responseHandler = handler(self, self.OnSocketSubSendCard)
		},
		--发牌返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = ShowHandDefine.SUB_S_ALL_CARD, 
			responseHandler = handler(self, self.OnSocketSubAllCard)
		},
		--一局结束返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = ShowHandDefine.SUB_S_GAME_END, 
			responseHandler = handler(self, self.OnSocketSubGameOver)
		},
	}
	self:getClientKernel():addSocketResponseHandlersByTable(self.Handlers)
end

--自己椅子号
function GameclientKernel:GetMeChairID()
    return self:getClientKernel().userAttribute.wChairID
    --userAttribute
end
--房间类型
function GameclientKernel:GetSerVerType()
    return self:getClientKernel().serverAttribute.wServerType
    --userAttribute
end


--游戏场景消息
function GameclientKernel:OnSocketSubGameScene(Params)
    self.App.EventCenter:dispatchEvent({
            name = ShowHandDefine.GAME_SCENCE,
            para = Params,
        })

    --dump(Params)
end

--游戏开始
function GameclientKernel:OnSocketSubGameStart(Params)
    --print("游戏开始OnSocketSubGameStart")
    self.App.EventCenter:dispatchEvent({
            name = ShowHandDefine.GAME_START,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end

function GameclientKernel:OnSocketSubAddScore( Params )
	self.App.EventCenter:dispatchEvent({
            name = ShowHandDefine.GAME_ADD_SCORE,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end

function GameclientKernel:OnSocketSubGiveUp( Params )
	self.App.EventCenter:dispatchEvent({
            name = ShowHandDefine.GAME_GIVE_UP,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end

function GameclientKernel:OnSocketSubSendCard( Params )
	self.App.EventCenter:dispatchEvent({
            name = ShowHandDefine.GAME_SEND_CARD,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end

function GameclientKernel:OnSocketSubAllCard( Params )
	self.App.EventCenter:dispatchEvent({
            name = ShowHandDefine.GAME_ALL_CARD,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end

function GameclientKernel:OnSocketSubGameOver( Params )
	self.App.EventCenter:dispatchEvent({
            name = ShowHandDefine.GAME_OVER,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end


--释放注册的消息
function GameclientKernel:OnFreeInterface()
	self:getClientKernel():removeSocketResponseHandlersByTable(self.Handlers)
end



--获取本类句柄
function GameclientKernel:getClientKernel()
    return self.serviceClient
    --userAttribute
end
--用户准备
function GameclientKernel:StartGame()
	-- body
	self:getClientKernel():ready()
	dump("SendReady")
end
--用户离开
function GameclientKernel:LeaveGame()
    -- body
    self:getClientKernel():standUp()
    dump("Standup")
end

--切换椅子
function GameclientKernel:SwitchViewChairID(wChairID)
    --转换椅子
    local wChairCount=self:getClientKernel().gameAttribute.wChairCount
    local wMeChairID=self:getClientKernel().userAttribute.wChairID
    local wViewChairID=(wChairID+wChairCount*3/2-wMeChairID)%wChairCount;
    return wViewChairID
end

return GameclientKernel