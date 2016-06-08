local MissionItem = class("MissionItem")

function MissionItem:ctor(clietType,gameName)
	-- 注册Game service client
	local manager = GameServiceClientManager:sharedInstance()

	self.m_gameName = self:gameName() or gameName

	if self.m_gameName ~= nil and string.len(self.m_gameName)>0 then
		print("gameName "..self.m_gameName)
		manager:registerServiceClient(clietType,self.m_gameName)
		manager:setCurrentServiceClientName(self.m_gameName)

		-- 获得service client
		self.serviceClient = manager:serviceClientForName(self.m_gameName)

		self.scriptHandler = manager:responseHandlerForName(self.m_gameName)
	end

	self.currentRoom = nil
end

-- 游戏名，子类覆盖
function MissionItem:gameName()
end

-- 移除service client
function MissionItem:removeServiceClient( )
	if self.m_gameName then
		GameServiceClientManager:sharedInstance():removeServiceClient(self.m_gameName)
	end
end

function MissionItem:onDisconnectSocket()
	if self.serviceClient then
		print("MissionItem:onDisconnectSocket")
		self.serviceClient:closeSoket()
	end
end

function MissionItem:requestCommand(mainID,subID,request,typeName)
	if typeName then
		self.serviceClient:requestCommand(mainID,subID,request,typeName)
	else
		if request then
			self.serviceClient:requestCommand(mainID,subID,request)
		else
			self.serviceClient:requestCommand(mainID,subID)
		end
	end
end

function MissionItem:ParseStructGroup(unResolvedData,structName)
    local group = {}
    if unResolvedData.sizeNotCut < 1 then
        return group
    end
    local item = self.serviceClient:ParseStruct(unResolvedData.dataNotCutPtr,unResolvedData.sizeNotCut, structName)
    while item ~= nil do
        --for k,v in pairs(item) do
        --    print(k,v)
        --end

        table.insert(group, item)
        if item.unResolvedData ~= nil and item.unResolvedData.sizeNotCut > 0 then
            item = self.serviceClient:ParseStruct(item.unResolvedData.dataNotCutPtr,item.unResolvedData.sizeNotCut, structName)
        else
            item = nil
        end
    end
    
    return group
end

return MissionItem