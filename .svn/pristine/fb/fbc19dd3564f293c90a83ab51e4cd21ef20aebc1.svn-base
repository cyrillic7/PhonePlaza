--
-- Author: wudb
-- Date: 2014-09-22 15:27:12
--

local TestBaseScene = require("Common.TestBaseScene")
local BJTestMainMenu = class("BJTestMainMenu", TestBaseScene)

function BJTestMainMenu:ctor( )
	BJTestMainMenu.super.ctor(self)

	self:addTestButton(1, "Normal", handler(self, self.enterNormalFlow))

	-- 游戏逻辑测试
	self:addTestButton(1, "logic", handler(self, self.testLogic))

	-- smartfox相关接口测试
	self:addTestButton(1, "service test", handler(self, self.enterServiceTest))

	-- loading界面
	self:addTestButton(1, "LoadingView", handler(self, self.showLoadingView))

	self:addTestButton(1, "Login", handler(self, self.loginGame))

	-- 测试, 假设进入房间level2
	GameServiceClientManager:sharedInstance():setCurrentRoom("level2")
end

function BJTestMainMenu:onEnter( )
	-- 临时方案，清空
	for k, v in pairs(package.loaded) do
		package.loaded[k] = nil
	end
	--loading界面显示的帧事件
	self.isShowLoadingView = false
	-- self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(elapsedTime)
	-- 	self:update(elapsedTime)
	-- end)
	printInfo("BJTestMainMenu:onEnter")
	-- self:scheduleUpdate()
end

function BJTestMainMenu:onExit()
	-- self:removeNodeEventListener(cc.NODE_ENTER_FRAME_EVENT)
	-- self:unscheduleUpdate()
	printInfo("BJTestMainMenu:onExit")
end

function BJTestMainMenu:enterNormalFlow( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		GameUtil:pushScene("BlackjackScene")
	end
end

function BJTestMainMenu:testLogic( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		GameUtil:pushTestScene("BJTestLogic")
	end
end

function BJTestMainMenu:enterServiceTest( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		GameUtil:pushTestScene("BJServiceTest")
	end
end

function BJTestMainMenu:showLoadingView( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		local args = { name = "blackjack" }
		self.loadingView = require("Common.Widget.LoadingView").new(args)
		self:addChild(self.loadingView)
		self.delayTime = 0
		self.isShowLoadingView = true
	end
end

function BJTestMainMenu:update(elapsedTime)
	if self.isShowLoadingView then
		self.delayTime = self.delayTime + elapsedTime
		if self.delayTime >= 3 then
			self.delayTime = 0
			self.loadingView:removeFromParent()
			self.isShowLoadingView = false
		end
	end
end

function BJTestMainMenu:loginGame( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		self:login(BlackjackAppName)
	end
end

function BJTestMainMenu:showChipViewTest( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		GameUtil:pushTestScene("ChipViewTest")
	end
end

function BJTestMainMenu:showPokerTableViewTest( sender, touchType )
	if touchType == TOUCH_EVENT_ENDED then
		GameUtil:pushTestScene("PokerTableViewTest")
	end
end

return BJTestMainMenu