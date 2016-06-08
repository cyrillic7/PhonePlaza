--
-- Author: Bo Mo
-- Date: 2014-09-23 09:37:53
--

CURRENT_MODULE_NAME = ...

local TestBaseScene = require("Common.TestBaseScene")
local BJServiceTest = class("BJServiceTest", TestBaseScene)

local BJResponseHandler = import("..Command.BJResponseHandler").new()
local BJCommand = import("..Command.BJCommand").new()

function BJServiceTest:ctor( )
	BJServiceTest.super.ctor(self)
	self:addTestButton(1, "Login", handler(self, self.doLogin))
	self:addTestButton(1, "enterLevel", handler(self, self.enterLevel2))
	self:addTestButton(1, "set bet", handler(self, self.setBet))
	self:addTestButton(1, "hit", handler(self, self.doHit))
	self:addTestButton(1, "double", handler(self, self.doDouble))
	self:addTestButton(1, "stand", handler(self, self.doStand))
	self:addTestButton(2, "buyInsurance", handler(self, self.buyInsurance))
	self:addTestButton(2, "split", handler(self, self.doSplit))
end

function BJServiceTest:onEnter( )
	BJResponseHandler:registerPlayHandlers()
	local listener = cc.EventListenerCustom:create("bet", handler(self, self.receiveBetMessage))
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function BJServiceTest:receiveBetMessage( response )
	local t = response.para
	printInfo("bet: " .. t.Bets .. " playerId: " .. t.PlayerID)
end

function BJServiceTest:onExit()
	BJResponseHandler:unregisterPlayHandlers()
end

function BJServiceTest:doLogin( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		printInfo("login")
		self:login(BlackjackAppName)
	end
end

function BJServiceTest:enterLevel2( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		printInfo("EnterLevel2")
		BJCommand:enterLevel("level2")
	end
end

function BJServiceTest:setBet( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		printInfo("set bet 100")
		BJCommand:setBet(100)
	end
end

function BJServiceTest:doHit( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		printInfo("Hit")
		BJCommand:doHit()
	end
end

function BJServiceTest:doDouble( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		printInfo("Double")
		BJCommand:doDouble()
	end
end

function BJServiceTest:doStand( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		printInfo("Stand")
		BJCommand:doStand()
	end
end

function BJServiceTest:buyInsurance( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		printInfo("buy insurance")
		BJCommand:buyInsurance(1)
	end
end

function BJServiceTest:doSplit( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		printInfo("Split")
		BJCommand:doSplit()
	end
end

return BJServiceTest