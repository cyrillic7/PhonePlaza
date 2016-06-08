
--数据引擎
local GameclientKernel = class("GameclientKernel")

require("common.GameServerDefine")

--构造本类
function GameclientKernel:ctor(serviceClient)
    self.serviceClient = serviceClient
    self.App = AppBaseInstanse.RednineBattleApp
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
        --游戏空闲
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = RedninebattleDefine.SUB_S_GAME_FREE, 
            responseHandler = handler(self, self.OnSocketSubGameFree)
        },
		--游戏开始消息返回处理
		{

          mainCmdID= MDM_GF_GAME,
          subCmdID = RedninebattleDefine.SUB_S_GAME_START,
		  responseHandler = handler(self, self.OnSocketSubGameStart)
		},
		
        --用户下注
		{
			mainCmdID=MDM_GF_GAME, 
            subCmdID = RedninebattleDefine.SUB_S_PLACE_JETTON, 
			responseHandler = handler(self, self.OnSocketSubPlaceJetton)
		},
		--游戏结束返回处理
		{
			mainCmdID=MDM_GF_GAME, 
            subCmdID = RedninebattleDefine.SUB_S_GAME_END, 
            responseHandler = handler(self, self.OnSocketSubGameOver)
		},
		--庄家申请
		{
			mainCmdID=MDM_GF_GAME, 
            subCmdID = RedninebattleDefine.SUB_S_APPLY_BANKER, 
			responseHandler = handler(self, self.OnSocketSubApplyBanker)
		},
		--切换庄家
		{
			mainCmdID=MDM_GF_GAME, 
            subCmdID = RedninebattleDefine.SUB_S_CHANGE_BANKER, 
			responseHandler = handler(self, self.OnSocketSubChangeBanker)
		},
            --更新积分
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = RedninebattleDefine.SUB_S_SEND_RECORD, 
			responseHandler = handler(self, self.OnSocketSubSendRecord)
		},
		--下注失败
		{
			mainCmdID=MDM_GF_GAME, 
                subCmdID = RedninebattleDefine.SUB_S_PLACE_JETTON_FAIL, 
			responseHandler = handler(self, self.OnSocketPlaceJettonFall)
		},

     --取消申请
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = RedninebattleDefine.SUB_S_CANCEL_BANKER, 
            responseHandler = handler(self, self.OnSocketCancelBanker)
        },

        --发送账号
        {
            mainCmdID=MDM_GF_GAME, 
                subCmdID = RedninebattleDefine.GAME_AMDIN_COMMAND, 
            responseHandler = handler(self, self.OnSocketSubAmdinCommand)
        },
        --查询账号
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = RedninebattleDefine.SUB_S_ADMIN_CHEAK, 
            responseHandler = handler(self, self.OnSocketSubAdminCheak)
        },
        
        --强庄
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = RedninebattleDefine.SUB_S_QIANG_ZHUAN, 
            responseHandler = handler(self, self.OnSocketSubQiangZhuang)
        }, 
	} 
	self:getClientKernel():addSocketResponseHandlersByTable(self.Handlers)
end

function GameclientKernel:OnSocketSubGameScene(Params)
    print("场景消息")
    self.App.EventCenter:dispatchEvent({
            name = RedninebattleDefine.GAME_SCENCE,
            para = Params,
        }) 
    --dump(Params)
end  


--游戏开始
function GameclientKernel:OnSocketSubGameStart(Params) 
    print("游戏开始")
        self.App.EventCenter:dispatchEvent({
            name = RedninebattleDefine.GAME_START,
            para = Params,
        })  

    --dump(Params)
end

--游戏空闲
function GameclientKernel:OnSocketSubGameFree(Params)
    print("游戏空闲")
     self.App.EventCenter:dispatchEvent({
        name = RedninebattleDefine.GAME_FREE,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end

--玩家加注
function GameclientKernel:OnSocketSubPlaceJetton(Params)
    print("玩家加注")
    self.App.EventCenter:dispatchEvent({
            name = RedninebattleDefine.GAME_PLACE_JETTON,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end

--结束
function GameclientKernel:OnSocketSubGameOver(Params)
    print("结束Socket")
    self.App.EventCenter:dispatchEvent({
        name = RedninebattleDefine.GAME_END,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end  


--庄家申请
function GameclientKernel:OnSocketSubApplyBanker(Params)
    print("庄家申请")
    self.App.EventCenter:dispatchEvent({
            name = RedninebattleDefine.GAME_APPLY_BANKER,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end  

--切换庄家
function GameclientKernel:OnSocketSubChangeBanker(Params)
    print("切换庄家")
    self.App.EventCenter:dispatchEvent({
            name = RedninebattleDefine.GAME_CHANGE_BANKER,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end  


--游戏记录
function GameclientKernel:OnSocketSubSendRecord(Params)
    print("游戏记录")
    self.App.EventCenter:dispatchEvent({
            name = RedninebattleDefine.GAME_SEND_RECORD,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end   

--下注失败
function GameclientKernel:OnSocketSubSendRecord(Params)
    print("下注失败")
    self.App.EventCenter:dispatchEvent({
            name = RedninebattleDefine.GAME_SEND_RECORD,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end    

--取消申请
function GameclientKernel:OnSocketCancelBanker(Params)
    print("取消申请")
    self.App.EventCenter:dispatchEvent({
            name = RedninebattleDefine.GAME_CANCEL_BANKER,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end  

--发送账号
function GameclientKernel:OnSocketSubAmdinCommand(Params)
    print("作弊")
    self.App.EventCenter:dispatchEvent({
            name = RedninebattleDefine.GAME_SEND_ACCOUNT,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end  

function GameclientKernel:OnSocketPlaceJettonFall(Params)
    print("下注失败")
    self.App.EventCenter:dispatchEvent({
            name = RedninebattleDefine.GAME_PLACE_JETTON_FAIL,
            para = Params,
        })

    for k,v in pairs(Params) do
        print(k,v)
    end
end

--强庄
function GameclientKernel:OnSocketSubQiangZhuang(Params)
    print("强庄")
    self.App.EventCenter:dispatchEvent({
            name = RedninebattleDefine.GAME_QIANG_ZHUAN,
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