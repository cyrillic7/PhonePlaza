function newGameScene(name)
    local scene = GameBaseScene:create()
    scene:setNodeEventEnabled(true)
    scene:setAutoCleanupEnabled()
    scene.name = name or "<unknown-scene>"
    return scene
end

local BaseGameScene = class("BaseGameScene", function()
	return newGameScene('BaseGameScene')
end)

function BaseGameScene:ctor(clietType)
	-- 注册Game service client
	local manager = GameServiceClientManager:sharedInstance()

	self.m_gameName = self:gameName()

	if self.m_gameName ~= nil and string.len(self.m_gameName)>0 then
		print("gameName "..self.m_gameName)
		manager:registerServiceClient(clietType,self.m_gameName)
		manager:setCurrentServiceClientName(self.m_gameName)

		-- 获得service client
		self.serviceClient = manager:serviceClientForName(self.m_gameName)
		self:setServiceClient(self.serviceClient)

		self.scriptHandler = manager:responseHandlerForName(self.m_gameName)
	end

	self.currentRoom = nil
	self.bFirstEnter = true
end

-- 游戏名，子类覆盖
function BaseGameScene:gameName()
end

-- 移除service client
function BaseGameScene:removeServiceClient( )
	if self.m_gameName then
		GameServiceClientManager:sharedInstance():removeServiceClient(self.m_gameName)
	end
end

-- 进入到游戏房间的事件, 子类实现此方法来进入到房间
-- roomName 将要进入的房间的名称
function BaseGameScene:onEnterGameRoom( roomName )
end

function BaseGameScene:reenterRoom()
	self:onCleanGameView()
	self:onEnterGameRoom(self.currentRoom)
end

-- 退出房间的事件
-- 注意这里不要发送GA的lastView事件，因为子类的方法中，调用了exitRoom。
function BaseGameScene:onExitGameRoom( )
end

-- 子类必须继承实现清除游戏场景界面的方法
function BaseGameScene:onCleanGameView( )
	--TODO
end

function BaseGameScene:onEnter()
	-- 接收登录返回的消息
	print("BaseGameScene:onEnter")
	self.bFirstEnter = false
end

function BaseGameScene:onExit( )
	
	print("BaseGameScene:onExit")
end

function BaseGameScene:onCleanup( )
	self:getEventDispatcher():removeEventListenersForTarget(self)
	print("BaseGameScene:onCleanup")
end

function BaseGameScene:loadUI()
	print("BaseGameScene:loadUI")
end

return BaseGameScene