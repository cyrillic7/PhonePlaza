--
-- Author: Hj
-- Date: 2014-09-22 15:27:12
--

local TestBaseScene = require("Common.TestBaseScene")
local BJTestLogic = class("BJTestLogic", TestBaseScene)
local BJCommand = import("..Command.BJCommand").new()

local CURRENT_MODULE_NAME = ...

-- 假定进入的房间名称
local RoomName = "level3"

function BJTestLogic:ctor( )
	BJTestLogic.super.ctor(self)

	-- 登录
	self:addTestButton(1, "Login", handler(self, self.doLogin))

	-- 登出
	self:addTestButton(1, "Logout", handler(self, self.doLogout))

	-- 进入房间
	self:addTestButton(1, "Enter Room", handler(self, self.enterLevel2))

	self:addTestButton(1, "Exit Room", handler(self, self.exitRoom))

	-- 去除监听
	self:addTestButton(1, "unregisterEvent", handler(self, self.unregistreEvent))

	-- 机器人策略
	self:addTestButton(2, "rebot_1", handler(self, self.goRobot1))

	-- 游戏逻辑
	-- self.workflow = import("..Controller.BJWorkflow", CURRENT_MODULE_NAME).new(self)
	-- 不要操作UI
	-- self.workflow.playerOperatingUI = false
end

function BJTestLogic:registerEvent()
end

function BJTestLogic:unregistreEvent()
end

function BJTestLogic:onEnter( )
end

function BJTestLogic:onExit()
	self:unregistreEvent()
end

function BJTestLogic:doLogin( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		self:login(BlackjackAppName)
	end
end

function BJTestLogic:doLogout( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		self:serviceClientForName(BlackjackAppName):logout()
	end
end

function BJTestLogic:enterLevel2( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		BJCommand:enterLevel(RoomName)
	end
end

function BJTestLogic:exitRoom( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		--退出房间
    	self:serviceClientForName(BlackjackAppName):exitRoom(RoomName)
	end
end

function BJTestLogic:goRobot1( )
	
end

function BJTestLogic:initPlayers(players)
end

function BJTestLogic:getMySelfBet( ... )
	return 100
end

function BJTestLogic:playerStatusChanged(player, event)
	if self.workflow.myId == tonumber(player.playerData.playerId) then
		if event.to == "deciding" then
			self.workflow:doStand()
		end
	end
end


return BJTestLogic