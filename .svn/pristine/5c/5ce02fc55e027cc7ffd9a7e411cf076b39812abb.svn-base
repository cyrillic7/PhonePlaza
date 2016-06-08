
--数据引擎
local GameclientKernel = class("GameclientKernel")

require("common.GameServerDefine")

--构造本类
function GameclientKernel:ctor(serviceClient)
    self.serviceClient = serviceClient


   -- print("初始化ID"..self.serviceClient.userAttribute.dwUserID.."yizi"..self.serviceClient.userAttribute.wChairID.."wTableID"..self.serviceClient.userAttribute.wTableID)
    self.App = AppBaseInstanse.ErRenLandApp
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
			subCmdID = ErRenLandDefine.SUB_S_GAME_START, 
			responseHandler = handler(self, self.OnSocketSubGameStart)
		},

		--叫地主返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = ErRenLandDefine.SUB_S_CALL_SCORE, 
			responseHandler = handler(self, self.OnSocketSubCallScore)
		},
		--地主信息返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = ErRenLandDefine.SUB_S_BANKER_INFO, 
			responseHandler = handler(self, self.OnSocketSubBankerInfo)
		},
		--出牌返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = ErRenLandDefine.SUB_S_OUT_CARD, 
			responseHandler = handler(self, self.OnSocketSubOutCard)
		},
		--不出返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = ErRenLandDefine.SUB_S_PASS_CARD, 
			responseHandler = handler(self, self.OnSocketSubPass)
		},
		--一局结束返回处理
		{
			mainCmdID=MDM_GF_GAME, 
			subCmdID = ErRenLandDefine.SUB_S_GAME_CONCLUDE, 
			responseHandler = handler(self, self.OnSocketSubGameOver)
		},
        --设置基数返回处理
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = ErRenLandDefine.SUB_S_SET_BASESCORE, 
            responseHandler = handler(self, self.OnSocketSubSetCell)
        },
        --设置托管
        {
            mainCmdID=MDM_GF_GAME, 
            subCmdID = ErRenLandDefine.SUB_S_SET_TUOGUAN, 
            responseHandler = handler(self, self.OnSocketSubSetTuoguan)
        },

        -------------------------------------
--比赛消息注册
        {

          mainCmdID= MDM_GF_FRAME,
          subCmdID = SUB_GR_MATCH_INFO,
          responseHandler = handler(self, self.OnSocketSubMatchInfo)
        },
        {

          mainCmdID= MDM_GF_FRAME,
          subCmdID = SUB_GR_MATCH_WAIT_TIP,
          responseHandler = handler(self, self.OnSocketSubWaitMatchTip)
        },
        {

          mainCmdID= MDM_GF_FRAME,
          subCmdID = SUB_GF_SYSTEM_MESSAGE,
          responseHandler = handler(self, self.OnSocketSubMatchMsg)
        },
        {

          mainCmdID= MDM_GF_FRAME,
          subCmdID = SUB_GR_MATCH_RESULT,
          responseHandler = handler(self, self.OnSocketSubMatchResult)
        },
        {

          mainCmdID= MDM_GF_FRAME,
          subCmdID = SUB_GF_USER_READY,
          responseHandler = handler(self, self.OnSocketSubMatchUserReady)
        },
----------------------------

	}
	self:getClientKernel():addSocketResponseHandlersByTable(self.Handlers)
end
--自己椅子号
function GameclientKernel:GetMeChairID()
    return self:getClientKernel().userAttribute.wChairID
    --userAttribute
end
function GameclientKernel:GetMeUserID()
    return self:getClientKernel().userAttribute.dwUserID
    --userAttribute
end
--房间类型
function GameclientKernel:GetSerVerType()
    return self:getClientKernel().serverAttribute.wServerType
    --userAttribute
end

--------------------比赛消息相关-------------------


--比赛消息-等待开始
--[[function GameclientKernel:OnSocketSubMatchWaitStart(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_MATCH_WAIT_SATRT,
            para = Params,
        })
    dump(Params)
end]]

--比赛消息-等待分组
function GameclientKernel:OnSocketSubMatchMsg(Params)

    --dump(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_MATCH_MSG,
            para = Params,
        })

end

--比赛消息-比赛游戏动态
function GameclientKernel:OnSocketSubMatchInfo(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_MATCH_INFO,
            para = Params,
        })
    --dump(Params)
end

--比赛消息-比赛晋级等待
function GameclientKernel:OnSocketSubWaitMatchTip(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_MATCH_TIP,
            para = Params,
        })
   -- dump(Params)

end

--比赛消息-比赛结果
function GameclientKernel:OnSocketSubMatchResult(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_MATCH_RESULT,
            para = Params,
        })
   -- dump(Params)
end
--比赛消息-比赛结果
function GameclientKernel:OnSocketSubMatchUserReady(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_MATCH_USER_READY,
            para = Params,
        })
   -- dump(Params)
end





---------------------------------------
--游戏场景消息
function GameclientKernel:OnSocketSubGameScene(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_SCENCE,
            para = Params,
        })

    --dump(Params)
end

--游戏开始
function GameclientKernel:OnSocketSubGameStart(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_START,
            para = Params,
        })

 
end

--设置基数
function GameclientKernel:OnSocketSubSetCell(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_SET_CELL_SCORE,
            para = Params,
        })


end
--设置托管
function GameclientKernel:OnSocketSubSetTuoguan(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_TUOGUAN,
            para = Params,
        })
end

--叫地主
function GameclientKernel:OnSocketSubCallScore(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_CALL_SCORE,
            para = Params,
        })


end

--地主信息
function GameclientKernel:OnSocketSubBankerInfo(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_BANKER_INFO,
            para = Params,
        })


end

--出牌
function GameclientKernel:OnSocketSubOutCard(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_OUT_CARD,
            para = Params,
        })


end

--过牌
function GameclientKernel:OnSocketSubPass(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_PASS_CARD,
            para = Params,
        })


end

--结束
function GameclientKernel:OnSocketSubGameOver(Params)
    self.App.EventCenter:dispatchEvent({
            name = ErRenLandDefine.GAME_OVER,
            para = Params,
        })


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