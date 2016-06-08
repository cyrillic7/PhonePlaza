local GameUserManagerController = class("GameUserManagerController")

GameUserManagerController.Message={
	GAME_UserItemAcitve = "GAME_UserItemAcitve",
	GAME_UserItemDelete = "GAME_UserItemDelete",
	GAME_UserItemScoreUpdate = "GAME_UserItemScoreUpdate",
	GAME_UserItemStatusUpdate = "GAME_UserItemStatusUpdate",
	GAME_UserItemAttribUpdate = "GAME_UserItemAttribUpdate",

	GAME_MatchUserItemAcitve = "GAME_MatchUserItemAcitve",
	GAME_MatchUserItemLeave = "GAME_MatchUserItemLeave",--GAME_MatchUserItemDelete
	GAME_MatchUserItemStatusUpdate = "GAME_MatchUserItemStatusUpdate",
	GAME_MatchUserListUpdate = "GAME_MatchUserListUpdate"
}

function GameUserManagerController:ctor(notificationCenter)
	self.gameUserItems = {}
	self.matchUserItems = {}
	self.notificationCenter = notificationCenter
end

--管理接口
--删除用户
function GameUserManagerController:DeleteUserItem(dwUserID)
	if self.gameUserItems[tostring(dwUserID)] then

		self.notificationCenter:dispatchEvent({
            name = GameUserManagerController.Message.GAME_UserItemDelete,
            para = self.gameUserItems[tostring(dwUserID)],
        })

		self.gameUserItems[tostring(dwUserID)] = nil
	end
end
--增加用户
function GameUserManagerController:ActiveUserItem(userInfo)
	self.gameUserItems[tostring(userInfo.dwUserID)] = userInfo

	self.notificationCenter:dispatchEvent({
            name = GameUserManagerController.Message.GAME_UserItemAcitve,
            para = userInfo,
        })
end

--更新接口
--更新积分
function GameUserManagerController:UpdateUserItemScore(dwUserID, userScore)
	if self.gameUserItems[tostring(dwUserID)] then
		local useritem = self.gameUserItems[tostring(dwUserID)]
		local preUserScore = {lScore = useritem.lScore,
								lGrade = useritem.lGrade,
								lInsure = useritem.lInsure,
								dwWinCount = useritem.dwWinCount,
								dwLostCount = useritem.dwLostCount,
								dwDrawCount = useritem.dwDrawCount,
								dwFleeCount = useritem.dwFleeCount,
								dwUserMedal = useritem.dwUserMedal,
								dwExperience = useritem.dwExperience,
								lLoveLiness = useritem.lLoveLiness}

		useritem.lScore = userScore.lScore
		useritem.lGrade = userScore.lGrade
		useritem.lInsure = userScore.lInsure
		useritem.dwWinCount = userScore.dwWinCount
		useritem.dwLostCount = userScore.dwLostCount
		useritem.dwDrawCount = userScore.dwDrawCount
		useritem.dwFleeCount = userScore.dwFleeCount
		useritem.dwUserMedal = userScore.dwUserMedal
		useritem.dwExperience = userScore.dwExperience
		useritem.lLoveLiness = userScore.lLoveLiness
		useritem.lJifen = userScore.lCapacityScore

		self.notificationCenter:dispatchEvent({
            name = GameUserManagerController.Message.GAME_UserItemScoreUpdate,
            para = {clientUserItem=useritem,preUserScore=preUserScore}
        })
	end
end
--更新状态
function GameUserManagerController:UpdateUserItemStatus(dwUserID, userStatus)
	if self.gameUserItems[tostring(dwUserID)] then
		local useritem = self.gameUserItems[tostring(dwUserID)]
		local preUserStatus = {wTableID=useritem.wTableID,
								wChairID=useritem.wChairID,
								cbUserStatus=useritem.cbUserStatus}
								
		useritem.wTableID = userStatus.wTableID
		useritem.wChairID = userStatus.wChairID
		useritem.cbUserStatus = userStatus.cbUserStatus

		self.notificationCenter:dispatchEvent({
            name = GameUserManagerController.Message.GAME_UserItemStatusUpdate,
            para = {clientUserItem=useritem,preUserStatus=preUserStatus}
        })
	end
end
--更新属性
function GameUserManagerController:UpdateUserItemAttrib(dwUserID, userAttrib)
	if self.gameUserItems[tostring(dwUserID)] then
		self.gameUserItems[tostring(dwUserID)].cbCompanion = userAttrib.cbCompanion
	end
end
--更新头像
--bool UpdateUserCustomFace(IClientUserItem * pIClientUserItem, DWORD dwCustomID, tagCustomFaceInfo & CustomFaceInfo)=NULL;
--更新比赛状态
--bool UpdateUserMatchStatus(IClientUserItem * pIClientUserItem, BYTE MatchUserStatus)=NULL;

--查找接口
--查找用户
function GameUserManagerController:SearchUserByUserID(dwUserID)
	return self.gameUserItems[tostring(dwUserID)]
end
--查找用户
function GameUserManagerController:SearchUserByGameID(dwGameID)
	for k,v in pairs(self.gameUserItems) do
		if v.dwGameID == dwGameID then
			return v
		end
	end
end
--查找用户
function GameUserManagerController:SearchUserByNickName(pszNickName)
	for k,v in pairs(self.gameUserItems) do
		if v.szNickName == pszNickName then
			return v
		end
	end
end
--查找用户
function GameUserManagerController:SearchUserByChairID(wChairID)
	for k,v in pairs(self.gameUserItems) do
		if v.wChairID == wChairID then
			return v
		end
	end
end
--获得人数
function GameUserManagerController:GetActiveUserCount()
	local total = 0
	for k,v in pairs(self.gameUserItems) do
		total = total + 1
	end
	return total
end

function GameUserManagerController:ResetUserItem()
	self.gameUserItems = {}
end

-- 比赛相关
	-- 查找用户
function GameUserManagerController:SearchMatchUserByUserID(dwUserID)
	return self.matchUserItems[tostring(dwUserID)]
end
	-- 增加用户
function GameUserManagerController:ActiveMatchUserItem(userInfo)
	self.matchUserItems[tostring(userInfo.dwUserID)] = userInfo

	self.notificationCenter:dispatchEvent({
            name = GameUserManagerController.Message.GAME_MatchUserItemAcitve,
            para = userInfo,
        })
end
	-- 删除用户
function GameUserManagerController:DeleteMatchUserItem(userInfo)
	if self.matchUserItems[tostring(dwUserID)] then

		self.notificationCenter:dispatchEvent({
            name = GameUserManagerController.Message.GAME_MatchUserItemLeave,
            para = self.matchUserItems[tostring(dwUserID)],
        })

		self.matchUserItems[tostring(dwUserID)] = nil
	end
end
	-- 更新状态
function GameUserManagerController:UpdateMatchUserItemStatus(userInfo,Matchpacket)
	userInfo.cbEnlistStatus = Matchpacket.UserMatchStatus
	userInfo.dwUserRank = Matchpacket.UserRank
	userInfo.lScore = Matchpacket.match_score

	self.notificationCenter:dispatchEvent({
            name = GameUserManagerController.Message.GAME_MatchUserItemStatusUpdate,
            para = userInfo,
        })

	self:UpdateMatchUserList()
end
	-- 更新状态
function GameUserManagerController:UpdateMatchUserList()
	local useCount = 0
	for k,v in pairs(self.matchUserItems) do
		if v.cbEnlistStatus ~= MS_OUT and v.cbEnlistStatus ~= MS_LEAVE
		    and v.cbEnlistStatus ~= MS_OFFLINE then
			useCount = useCount + 1
		end
	end
	self.notificationCenter:dispatchEvent({
            name = GameUserManagerController.Message.GAME_MatchUserListUpdate,
            para = useCount
        })
end

return GameUserManagerController