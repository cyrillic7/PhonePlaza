ServerListData = class("ServerListData")

ServerListData.GameTypeItemMap = {}
ServerListData.GameKindItemMap = {}
ServerListData.GameServerItemMap = {}


function compBySortID_Game(item1,item2)
	if item1.wSortID < item2.wSortID then
		return true
	else
		return false
	end
end
-- 插入函数
function ServerListData:InsertGameType(GameType)
	local bExsit = false
	for k,v in pairs(ServerListData.GameTypeItemMap) do
		if v.wTypeID == GameType.wTypeID then
			ServerListData.GameTypeItemMap[k]=GameType
			bExsit = true
			break
		end
	end
	if not bExsit then
		table.insert(ServerListData.GameTypeItemMap,GameType)
	end
	table.sort(ServerListData.GameTypeItemMap,compBySortID_Game)
end

function ServerListData:InsertGameKind(GameKind)
	local bExsit = false
	for k,v in pairs(ServerListData.GameKindItemMap) do
		if v.wKindID == GameKind.wKindID then
			ServerListData.GameKindItemMap[k]=GameKind
			bExsit = true
			break
		end
	end
	if not bExsit then
		table.insert(ServerListData.GameKindItemMap,GameKind)
	end
	table.sort(ServerListData.GameKindItemMap,compBySortID_Game)
end

function ServerListData:InsertGameServer(GameServer)
	local bExsit = false
	for k,v in pairs(ServerListData.GameServerItemMap) do
		if v.wServerID == GameServer.wServerID then
			ServerListData.GameServerItemMap[k]=GameServer
			bExsit = true
			break
		end
	end
	if not bExsit then
		table.insert(ServerListData.GameServerItemMap,GameServer)
	end
	table.sort(ServerListData.GameServerItemMap,compBySortID_Game)
end

-- 删除函数
function ServerListData:ResetDate()
	ServerListData.GameTypeItemMap = {}
	ServerListData.GameKindItemMap = {}
	ServerListData.GameServerItemMap = {}
end

function ServerListData:DeleteGameType(typeID)
	for k,v in pairs(ServerListData.GameTypeItemMap) do
		if v.wTypeID == typeID then
			table.remove(ServerListData.GameTypeItemMap,k)
			break
		end
	end
end

function ServerListData:DeleteGameKind(kindID)
	for k,v in pairs(ServerListData.GameKindItemMap) do
		if v.wKindID == kindID then
			table.remove(ServerListData.GameKindItemMap,k)
			break
		end
	end
end

function ServerListData:DeleteGameServer(serverID)
	for k,v in pairs(ServerListData.GameServerItemMap) do
		if v.wServerID == serverID then
			table.remove(ServerListData.GameServerItemMap,k)
			break
		end
	end
end

-- 数目函数
function ServerListData:GetGameTypeCount()
	return #ServerListData.GameTypeItemMap
end

function ServerListData:GetGameKindCount()
	return #ServerListData.GameKindItemMap
end

function ServerListData:GetGameServerCount()
	return #ServerListData.GameServerItemMap
end

-- 获取函数
function ServerListData:GetGameKindByGameType(wTypeID)
	if wTypeID == -1 then
		return ServerListData.GameKindItemMap
	end
	local gameKinds = {}
	for k,v in pairs(ServerListData.GameKindItemMap) do
		if v.wTypeID == wTypeID then
			table.insert(gameKinds,v)
		end
	end
	
	return gameKinds
end

function ServerListData:GetGameServerByGameKind(wKindID)
	local gameServers = {}
	for k,v in pairs(ServerListData.GameServerItemMap) do
		if v.wKindID == wKindID then
			table.insert(gameServers,v)
		end
	end
	
	return gameServers
end

function ServerListData:GetGameKindByKind(wKindID)
	for k,v in pairs(ServerListData.GameKindItemMap) do
		if v.wKindID == wKindID then
			return v
		end
	end
end

function ServerListData:GetGameExeNameByKind(wKindID)
	local gameKind = self:GetGameKindByKind(wKindID)
	if gameKind then
		local strExeName = string.lower(gameKind.szProcessName)
	    local index,_ = string.find(strExeName,".exe")
	    if index then
	        strExeName = string.sub(strExeName,1,index-1)
	    end
	    return strExeName
	end
end

function ServerListData:GetGameNameByKind(wKindID)
	local gameKind = self:GetGameKindByKind(wKindID)
	if gameKind then
		return gameKind.szKindName
	end
end