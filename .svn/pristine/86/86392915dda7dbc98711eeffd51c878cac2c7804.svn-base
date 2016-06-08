
--数据引擎
local GameclientKernel = class("GameclientKernel")

require("common.GameServerDefine")

--构造本类
function GameclientKernel:ctor(serviceClient)
    self.serviceClient = serviceClient
    self.App = AppBaseInstanse.OxTwoApp
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

          mainCmdID= MDM_GF_GAME,
          subCmdID = OxTwoDefine.SUB_S_GAME_START,
		  responseHandler = handler(self, self.OnSocketSubGameStart)
		},
		--游戏加注消息返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = OxTwoDefine.SUB_S_ADD_SCORE, 
			responseHandler = handler(self, self.OnSocketSubGameAddScore)
		},
		--设置强退返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = OxTwoDefine.SUB_S_PLAYER_EXIT, 
			responseHandler = handler(self, self.OnSocketSubPlayerExit)
		},
		--游戏结束返回处理
		{
			mainCmdID=MDM_GF_GAME, 
                subCmdID = OxTwoDefine.SUB_S_GAME_END, 
                responseHandler = handler(self, self.OnSocketSubGameOver)
		},
		--用户摊牌信息返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = OxTwoDefine.SUB_S_OPEN_CARD, 
			responseHandler = handler(self, self.OnSocketSubOpenCard)
		},
		--叫庄返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = OxTwoDefine.SUB_S_CALL_BANKER, 
			responseHandler = handler(self, self.OnSocketSubCallBanker)
		},
		--发送返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = OxTwoDefine.SUB_S_GAME_BASE, 
			responseHandler = handler(self, self.OnSocketSubBase)
		}, 

     --发牌
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = OxTwoDefine.SUB_S_SEND_CARD, 
            responseHandler = handler(self, self.OnSocketSendCard)
        },

        --开牌
        {
            mainCmdID=MDM_GF_GAME, 
                subCmdID = OxTwoDefine.SUB_S_CHANGE_OPEN, 
            responseHandler = handler(self, self.OnSocketSubChangeOpen)
        },
        
            --开牌
            {
                mainCmdID=MDM_GF_GAME, 
                subCmdID = OxTwoDefine.SUB_S_ALL_CARD, 
                responseHandler = handler(self, self.OnSocketSubAllCard)
            },
        --返回所有的卡牌
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = OxTwoDefine.SUB_S_USER_OPEN, 
                responseHandler = handler(self, self.OnSocketSubPlayerOpen)
        },
	} 
	self:getClientKernel():addSocketResponseHandlersByTable(self.Handlers)
end

function GameclientKernel:OnSocketSubAllCard(Params)
    self.App.EventCenter:dispatchEvent({
        name = OxTwoDefine.GAME_ALL_CARD,
        para = Params,
    })  
end  

function GameclientKernel:OnSocketSubPlayerOpen(Params)
    self.App.EventCenter:dispatchEvent({
        name = OxTwoDefine.GAME_PLAYER_OPEN,
        para = Params,
    }) 
    --dump(Params)
end  

function GameclientKernel:OnSocketSubGameScene(Params)
    self.App.EventCenter:dispatchEvent({
            name = OxTwoDefine.GAME_SCENCE,
            para = Params,
        }) 
    --dump(Params)
end  

--游戏开始
function GameclientKernel:OnSocketSubGameStart(Params) 
        self.App.EventCenter:dispatchEvent({
            name = OxTwoDefine.GAME_START,
            para = Params,
        })  

    --dump(Params)
end  
--加注
function GameclientKernel:OnSocketSubGameAddScore(Params)
     self.App.EventCenter:dispatchEvent({
            name = OxTwoDefine.GAME_ADD_SCORE,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end

--玩家强制退出
function GameclientKernel:OnSocketSubPlayerExit(Params)
    --print("玩家强制退出Socket")
    self.App.EventCenter:dispatchEvent({
            name = OxTwoDefine.GAME_PLAYER_EXIT,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end 
 
function GameclientKernel:OnSocketSubBase(Params)
    print("发送基数？")
    self.App.EventCenter:dispatchEvent({
            name = OxTwoDefine.GAME_BASE,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end
--摊牌
function GameclientKernel:OnSocketSubChangeOpen(Params)
    print("摊牌Socket")
    self.App.EventCenter:dispatchEvent({
            name = OxTwoDefine.GAME_CHANGE_OPEN,
            para = Params,
        }) 
    for k,v in pairs(Params) do
        print(k,v)
    end
end

--摊牌
function GameclientKernel:OnSocketSubOpenCard(Params)
    print("开牌Socket")
    self.App.EventCenter:dispatchEvent({
        name = OxTwoDefine.GAME_OPEN_CARD,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end


--换牌
function GameclientKernel:OnSocketSubChangeCard(Params)
    --print("换牌Socket")
    self.App.EventCenter:dispatchEvent({
            name = OxTwoDefine.GAME_CHANGE_CARD,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end 

--叫庄
function GameclientKernel:OnSocketSubCallBanker(Params)
    --print("叫庄Socket")
    self.App.EventCenter:dispatchEvent({
            name = OxTwoDefine.GAME_CALL_BANKER,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end 
-- 发牌
function GameclientKernel:OnSocketSendCard(Params)
    --print("发牌Socket")
    self.App.EventCenter:dispatchEvent({
            name = OxTwoDefine.GAME_SEND_CARD,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end
-- --结束
function GameclientKernel:OnSocketSubGameOver(Params)
    print("结束Socket")
    self.App.EventCenter:dispatchEvent({
            name = OxTwoDefine.GAME_OVER,
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
	--dump("SendReady")
end
--用户离开
function GameclientKernel:LeaveGame()
    -- body
    self:getClientKernel():standUp()
    --dump("Standup")
end

--切换椅子
function GameclientKernel:SwitchViewChairID(wChairID)
    --转换椅子
    local wChairCount=self:getClientKernel().gameAttribute.wChairCount
    local wMeChairID=self:getClientKernel().userAttribute.wChairID
    local wViewChairID=(wChairID+wChairCount*3/2-wMeChairID)%wChairCount;
   
    return wViewChairID + 1
end


return GameclientKernel