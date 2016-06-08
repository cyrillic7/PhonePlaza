ServerMatchData = class("ServerMatchData")

ServerMatchData.MatchTypeItemMap = {}
ServerMatchData.MatchKindItemMap = {}
ServerMatchData.MatchServerItemMap = {}
ServerMatchData.MatchChampionMap = {}

ServerMatchData.Message = {
	-- 比赛拉人
	MS_EntranceMatchItem = "MS_EntranceMatchItem",
	-- 比赛类型回调接口
	MS_MatchTypeInsert = "MS_MatchTypeInsert",
	MS_MatchTypeUpdate = "MS_MatchTypeUpdate",
	MS_MatchTypeDelete = "MS_MatchTypeDelete",
	-- 比赛数据房间列表回调接口
	MS_MatchInfoInsert = "MS_MatchInfoInsert",
	MS_MatchInfoUpdate = "MS_MatchInfoUpdate",
	MS_MatchInfoDelete = "MS_MatchInfoDelete",
	MS_MatchPlayerNumUpdate = "MS_MatchPlayerNumUpdate",
	-- 比赛数据游戏列表回调接口
	MS_MatchKindInsert = "MS_MatchKindInsert",
	MS_MatchKindUpdate = "MS_MatchKindUpdate",
	MS_MatchKindDelete = "MS_MatchKindDelete",
	-- 冠军榜回调接口
	MS_AwardItemInsert = "MS_AwardItemInsert",
	MS_AwardItemUpdate = "MS_AwardItemUpdate",
	MS_AwardItemDelete = "MS_AwardItemDelete",
	-- 报名接口
	MS_MatchTimeUpdate = "MS_MatchTimeUpdate",
	--MS_MatchPlayerNumUpdate = "MS_MatchPlayerNumUpdate",
	-- 重置数据
	MS_MatchDataReset = "MS_MatchDataReset",
}


function compBySortID_Match(item1,item2)
	if item1.dwSortID < item2.dwSortID then
		return true
	else
		return false
	end
end
-- 插入函数
function ServerMatchData:InsertMatchType(MatchType)
	local bExsit = false
	for k,v in pairs(ServerMatchData.MatchTypeItemMap) do
		if v.dwType == MatchType.dwType then
			v=MatchType
			bExsit = true
			break
		end
	end
	if not bExsit then
		table.insert(ServerMatchData.MatchTypeItemMap,MatchType)
	end
	table.sort(ServerMatchData.MatchTypeItemMap,compBySortID_Match)
	-- 分发消息通知
	if not bExsit then
		AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = ServerMatchData.Message.MS_MatchTypeInsert,
            para = MatchType
        })
	end	
end

function ServerMatchData:InsertMatchKind(MatchKind)
	local bExsit = false
	for k,v in pairs(ServerMatchData.MatchKindItemMap) do
		if v.dwKindID == MatchKind.dwKindID then
			v=MatchKind
			bExsit = true
			break
		end
	end
	if not bExsit then
		table.insert(ServerMatchData.MatchKindItemMap,MatchKind)
	end
	table.sort(ServerMatchData.MatchKindItemMap,compBySortID_Match)
	-- 分发消息通知
	if bExsit then
		AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = ServerMatchData.Message.MS_MatchKindUpdate,
            para = MatchKind
        })
    else
    	AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = ServerMatchData.Message.MS_MatchKindInsert,
            para = MatchKind
        })
	end
end

function ServerMatchData:InsertMatchInfo(MatchInfo)
	local bExsit = false
	for k,v in pairs(ServerMatchData.MatchServerItemMap) do
		if v.MatchSerial.dwMatchInfoID == MatchInfo.MatchSerial.dwMatchInfoID then
			v=MatchInfo
			bExsit = true
			break
		end
	end
	if not bExsit then
		table.insert(ServerMatchData.MatchServerItemMap,MatchInfo)
	end
	-- table.sort(ServerMatchData.MatchServerItemMap,compBySortID_Match)
	-- 分发消息通知
	if bExsit then
		AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = ServerMatchData.Message.MS_MatchInfoUpdate,
            para = MatchInfo
        })
    else
    	AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = ServerMatchData.Message.MS_MatchInfoInsert,
            para = MatchInfo
        })
	end
end

function ServerMatchData:InsertAwardInfo(AwardInfo)
	table.insert(ServerMatchData.MatchChampionMap,AwardInfo)
	-- 分发消息通知
	AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = ServerMatchData.Message.MS_AwardItemInsert,
            para = AwardInfo
        })
end

 --比赛人数
function ServerMatchData:UpdateSignNum(MatchNum)
	local bExsit = false
	local matchInfo = {}
	for k,v in pairs(ServerMatchData.MatchServerItemMap) do
		if v.MatchSerial.dwMatchInfoID == MatchNum.MatchSerial.dwMatchInfoID then
			if v.MatchSerial.dwMatchType == 4 then -- 满人开赛
				v.dwCurGroupCount = MatchNum.dwCurGroupCount
				v.dwSignUpPlayerNum = MatchNum.nSignUpNum
			else
				v.dwSignUpPlayerNum = MatchNum.nSignUpNum
			end
			matchInfo = v
			bExsit = true
			break
		end
	end
	if not bExsit then
		return
	end
	-- 分发消息通知
	AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = ServerMatchData.Message.MS_MatchPlayerNumUpdate,
            para = matchInfo
        })
end

 -- 报名
function ServerMatchData:MatchSignUp(lMatchID)
	for k,v in pairs(ServerMatchData.MatchServerItemMap) do
		if v.MatchSerial.dwMatchInfoID == lMatchID then
			-- 满人赛不更新列表状态
			if v.MatchSerial.dwMatchType ~= 4 then
				v.dwSignUp = SignUpStatus.SignUp
				-- 分发消息通知
				AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
		            name = ServerMatchData.Message.MS_MatchInfoUpdate,
		            para = v
		        })
			end
			break
		end
	end
end

 -- 退赛
function ServerMatchData:MatchWithDraw(lMatchID)
	for k,v in pairs(ServerMatchData.MatchServerItemMap) do
		if v.MatchSerial.dwMatchInfoID == lMatchID then
			v.dwSignUp = SignUpStatus.NoSignUp
			-- 分发消息通知
			AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
	            name = ServerMatchData.Message.MS_MatchInfoUpdate,
	            para = v
	        })
			break
		end
	end
end

 -- 拉人
function ServerMatchData:MatchStart(MatchServer)
	for k,v in pairs(ServerMatchData.MatchServerItemMap) do
		if v.MatchSerial.dwMatchInfoID == MatchServer.MatchSerial.dwMatchInfoID then
			v.dwServerID = MatchServer.dwServerID
			-- 分发消息通知
			AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
	            name = ServerMatchData.Message.MS_EntranceMatchItem,
	            para = {matchInfo=v,matchServer=MatchServer}
	        })
			break
		end
	end
end

-- 更新比赛时间
function ServerMatchData:UpdateMatchStartTime(MatchStartTime)
	-- 分发消息通知
	AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
	            name = ServerMatchData.Message.MS_MatchTimeUpdate,
	            para = MatchStartTime
	        })
end

-- 删除函数
function ServerMatchData:ResetDate()
	ServerMatchData.MatchTypeItemMap = {}
	ServerMatchData.MatchKindItemMap = {}
	ServerMatchData.MatchServerItemMap = {}
	ServerMatchData.MatchChampionMap = {}

	-- 分发消息通知
	AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
	            name = ServerMatchData.Message.MS_MatchDataReset,
	            para = {}
	        })
end

function ServerMatchData:DeleteMatchInfo(dwMatchInfoID)
	for k,v in pairs(ServerMatchData.MatchServerItemMap) do
		if v.MatchSerial.dwMatchInfoID == dwMatchInfoID then
			-- 分发消息通知
			AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
	            name = ServerMatchData.Message.MS_MatchInfoDelete,
	            para = v
	        })

			table.remove(ServerMatchData.MatchServerItemMap,k)
			break
		end
	end
end

-- 获取函数
function ServerMatchData:GetMatchTypeItem()
	return ServerMatchData.MatchTypeItemMap
end

function ServerMatchData:GetMatchKindItem()
	return ServerMatchData.MatchKindItemMap
end

function ServerMatchData:GetMatchServerItemByKindID(dwKindID)
	local matchServers = {}
	for k,v in pairs(ServerMatchData.MatchServerItemMap) do
		if v.MatchSerial.dwKindID == dwKindID then
			table.insert(matchServers,v)
		end
	end
	
	return matchServers
end

function ServerMatchData:GetMatchServerItemByKindIDAndType(dwKindID,dwMatchType)
	local matchServers = {}
	local kindServers = self:GetMatchServerItemByKindID(dwKindID)

	for k,v in pairs(kindServers) do
		if v.MatchSerial.dwMatchType == dwMatchType then
			table.insert(matchServers,v)
		end
	end
	
	return matchServers
end

function ServerMatchData:GetMatchChampion(count)
	count = count or 5
	if count < 1 then
		count = 5
	end

	local champions = {}
	if #ServerMatchData.MatchChampionMap < count then
		count = #ServerMatchData.MatchChampionMap
	end
	while count > 0 do
		table.insert(champions,ServerMatchData.MatchChampionMap[count])
		count = count - 1
	end
	return champions
end

-- 查找函数
function ServerMatchData:SearchMatchKind(dwKindID)
	for k,v in pairs(ServerMatchData.MatchKindItemMap) do
		if v.dwKindID == dwKindID then
			return v
		end
	end
end

function ServerMatchData:SearchMatchType(dwType)
	for k,v in pairs(ServerMatchData.MatchTypeItemMap) do
		if v.dwType == dwType then
			return v
		end
	end
end

function ServerMatchData:SearchMatchServer(lMatchID)
	for k,v in pairs(ServerMatchData.MatchServerItemMap) do
		if v.MatchSerial.dwMatchInfoID == lMatchID then
			return v
		end
	end
end

function ServerMatchData:GetMatchExeNameByKind(wKindID)
	local gameKind = self:SearchMatchKind(wKindID)
	if gameKind then
		local strExeName = string.lower(gameKind.szClientEXEName)
	    local index,_ = string.find(strExeName,".exe")
	    if index then
	        strExeName = string.sub(strExeName,1,index-1)
	    end
	    return strExeName
	end
end


function ServerMatchData:GetMatchNameByKind(wKindID)
	local gameKind = self:SearchMatchKind(wKindID)
	if gameKind then
		return gameKind.szGameName
	end
end

function ServerMatchData:GetSortID(matchInfo)
	if matchInfo.MatchSerial.dwMatchType == 4 then
		return matchInfo.MatchSerial.dwFullPlayerNum
	elseif matchInfo.MatchSerial.dwMatchType >= 6 then
		local strSortID = tostring(v.MatchSerial.dwMatchInfoID)
		strSortID = string.sub(strSortID,1,2)
		return tonumber(strSortID)
	else
		return matchInfo.tMatchTime
	end
end

function ServerMatchData:GetNextatch(wKindID,wType,lSortID)
	for k,v in pairs(ServerMatchData.MatchServerItemMap) do
		if v.MatchSerial.dwMatchType == wType and v.MatchSerial.dwKindID == wKindID then
			if v.MatchSerial.dwMatchInfoID < 6 then
				return v
			else
				if self:GetSortID(v) == lSortID then
					return v
				end
			end
		end
	end
end
