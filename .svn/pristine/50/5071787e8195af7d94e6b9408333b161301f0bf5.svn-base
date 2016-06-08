local GameClientManager = class("GameClientManager")

GameClientManager.Message={
	GameClientManager_ExitGame="GameClientManager_ExitGame",
	GameClientManager_ExitMatchServer="GameClientManager_ExitMatchServer",

	GameClientManager_GameServerInfo="GameClientManager_GameServerInfo",
	GameClientManager_GameServerUserItem="GameClientManager_GameServerUserItem",
	GameClientManager_GameServerUserScore="GameClientManager_GameServerUserScore",
	GameClientManager_GameServerUserStatus="GameClientManager_GameServerUserStatus",

	GameClientManager_MatchServerStatus="GameClientManager_MatchServerStatus",
	GameClientManager_MathchServerInfo="GameClientManager_MathchServerInfo",
	GameClientManager_MatchServerUserItem="GameClientManager_MatchServerUserItem",
	GameClientManager_MatchServerUserItemLeave="GameClientManager_MatchServerUserItemLeave",
	GameClientManager_MatchServerUserItemUpdate="GameClientManager_MatchServerUserItemUpdate",

	GameClientManager_SendProcessData="GameClientManager_SendProcessData",
}

function GameClientManager:ctor(scriptHandler, serviceClient)
	self.scriptHandler = scriptHandler
	self.serviceClient = serviceClient
	self.clientNotificationCenter = require("common.NotificationCenter").new()
	self.gameClientReady=false
end

-- add GameClientManager event Listeners
function GameClientManager:addEventListenersByTable(eventListeners)
	return self.clientNotificationCenter:addAllEventListenerByTable( eventListeners )
end

-- remove GameClientManager event Listeners
function GameClientManager:removeListenersByTable(handles)
	return self.clientNotificationCenter:removeAllListenerByTable( handles )
end

-- add GameClientManager Socket ResponseHandlers
function GameClientManager:addSocketResponseHandlersByTable(ResponseHandlers)
	if self.scriptHandler and type(ResponseHandlers) == "table" then
		for k,v in pairs(ResponseHandlers) do
			if v.mainCmdID and v.subCmdID and v.responseHandler then
				self.scriptHandler:registerResponseHandler(v.mainCmdID,v.subCmdID,v.responseHandler)
			end
		end
	end
end

-- remove GameClientManager Socket ResponseHandlers
function GameClientManager:removeSocketResponseHandlersByTable(cmdIDTable)
	if self.scriptHandler and type(cmdIDTable) == "table" then
		for k,v in pairs(cmdIDTable) do
			if v.mainCmdID and v.subCmdID then
				self.scriptHandler:unregisterResponseHandler(v.mainCmdID,v.subCmdID)
			end
		end
	end
end

-- 分发数据
function GameClientManager:dispatchEventToClient(name,para)
	if self.clientNotificationCenter then
		self.clientNotificationCenter:dispatchEvent({
            name = name,
            para = para
        })
	end
end

-- 发送请求到服务器
function GameClientManager:requestCommand(mainID,subID,request,typeName)
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

-- 解析结构
function GameClientManager:ParseStruct(dataPtr,dataSize,structName)
    return self.serviceClient:ParseStruct(dataPtr,dataSize, structName)
end

-- 解析数组
function GameClientManager:ParseStructGroup(unResolvedData,structName)
    local group = {}
    if unResolvedData.sizeNotCut < 1 then
        return group
    end
    local item = self.serviceClient:ParseStruct(unResolvedData.dataNotCutPtr,unResolvedData.sizeNotCut, structName)
    while item ~= nil do
        for k,v in pairs(item) do
            print(k,v)
        end

        table.insert(group, item)
        if item.unResolvedData ~= nil and item.unResolvedData.sizeNotCut > 0 then
            item = self.serviceClient:ParseStruct(item.unResolvedData.dataNotCutPtr,item.unResolvedData.sizeNotCut, structName)
        else
            item = nil
        end
    end
    
    return group
end

function GameClientManager:clearPackageLoad(appMainPath)
	local count = 0
	for k, v in pairs(package.loaded) do
		local subStr = string.split(k,".")
        if #subStr > 0 and subStr[1]== appMainPath then
        	package.preload[k] = nil
        	package.loaded[k] = nil
        	print(k)
        	count = count + 1
        end
    end
end

-- 进入游戏
function GameClientManager:enterGameApp(appMainPath)
	if not appMainPath then
		return
	end
	if not self.gameClientReady then
		-- 清空游戏源码
		self:clearPackageLoad(appMainPath)
		cc.LuaLoadChunksFromZIP("res/lib/"..appMainPath..".zip")
		require(appMainPath..".App.GameApp").new():run(self)
		--package.loaded[appMainPath] = nil
		
		self.gameClientReady = true
	end
end

-- 退出游戏
function GameClientManager:exitGameApp()
	self:dispatchEventToClient(GameClientManager.Message.GameClientManager_ExitGame,{})
	self.gameClientReady = false
end

-- 发送关闭比赛房间
function GameClientManager:exitMatchServer(bSignNextMatch)
	AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = GameClientManager.Message.GameClientManager_ExitMatchServer,
            para = {bSignNextMatch=bSignNextMatch}
        })
end

-- 是否已进入游戏
function GameClientManager:isGameClientReady()
	return self.gameClientReady
end

-- 游戏房间信息
function GameClientManager:sendGameServerInfo(serverInfo)
	self:dispatchEventToClient(GameClientManager.Message.GameClientManager_GameServerInfo,serverInfo)
end

-- 比赛状态
function GameClientManager:sendMatchServerStatus(matchStatus)
	self:dispatchEventToClient(GameClientManager.Message.GameClientManager_MatchServerStatus,matchStatus)
end

-- 比赛房间信息
function GameClientManager:sendMatchServerInfo(serverInfo)
	self:dispatchEventToClient(GameClientManager.Message.GameClientManager_MathchServerInfo,serverInfo)
end

-- 用户进入
function GameClientManager:sendUserItem(userItem)
	self:dispatchEventToClient(GameClientManager.Message.GameClientManager_GameServerUserItem,userItem)
end

-- 用户积分
function GameClientManager:sendUserScore(dwUserID, userScoreInfo)
	self:dispatchEventToClient(GameClientManager.Message.GameClientManager_GameServerUserScore
		,{dwUserID=dwUserID,UserScore=userScoreInfo})
end

-- 用户状态
function GameClientManager:sendUserStatus(dwUserID, userStatusInfo)
	self:dispatchEventToClient(GameClientManager.Message.GameClientManager_GameServerUserStatus
		,{dwUserID=dwUserID,UserStatus=userStatusInfo})
end

-- 比赛用户进入
function GameClientManager:sendMatchUserItem(userItem)
	self:dispatchEventToClient(GameClientManager.Message.GameClientManager_MatchServerUserItem,userItem)
end

-- 比赛用户离开
function GameClientManager:sendMatchUserItemLeave(userItem)
	self:dispatchEventToClient(GameClientManager.Message.GameClientManager_MatchServerUserItemLeave,userItem.dwUserID)
end

-- 用户比赛状态
function GameClientManager:sendMatchUserItemUpdate(dwUserID, matchPacket)
	self:dispatchEventToClient(GameClientManager.Message.GameClientManager_MatchServerUserItemUpdate
		,{dwUserID=dwUserID,matchPacket=matchPacket})
end

-- 发送指定命令
function GameClientManager:sendProcessData(wMainCmdID,wSubCmdID,data)
	self:dispatchEventToClient(GameClientManager.Message.GameClientManager_SendProcessData
		,{wMainCmdID=wMainCmdID,wSubCmdID=wSubCmdID,data=data})
end

return GameClientManager