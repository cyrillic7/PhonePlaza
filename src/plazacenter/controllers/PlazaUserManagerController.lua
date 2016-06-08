local PlazaUserManagerController = class("PlazaUserManagerController")

PlazaUserManagerController.Message={
	PLAZA_UserItemAcitve = "PLAZA_UserItemAcitve",
	PLAZA_UserItemDelete = "PLAZA_UserItemDelete",
	PLAZA_UserItemScoreUpdate = "PLAZA_UserItemScoreUpdate",
	PLAZA_UserItemStatusUpdate = "PLAZA_UserItemStatusUpdate",
	PLAZA_UserItemAttribUpdate = "PLAZA_UserItemAttribUpdate"
}

function PlazaUserManagerController:ctor(bMatchGame)
	self.plazaUserItems = {}
    self.bMatchGame = bMatchGame
end

--管理接口
--删除用户
function PlazaUserManagerController:DeleteUserItem(dwUserID)
	if self.plazaUserItems[tostring(dwUserID)] then

		AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = PlazaUserManagerController.Message.PLAZA_UserItemDelete,
            para = self.plazaUserItems[tostring(dwUserID)],
            caller = self
        })

		self.plazaUserItems[tostring(dwUserID)] = nil
	end
end
--增加用户
function PlazaUserManagerController:ActiveUserItem(userInfo)
	self.plazaUserItems[tostring(userInfo.dwUserID)] = userInfo

	AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = PlazaUserManagerController.Message.PLAZA_UserItemAcitve,
            para = userInfo,
            caller = self
        })
end

--更新接口
--更新积分
function PlazaUserManagerController:UpdateUserItemScore(dwUserID, userScore)
	if self.plazaUserItems[tostring(dwUserID)] then
		local useritem = self.plazaUserItems[tostring(dwUserID)]
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

		AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = PlazaUserManagerController.Message.PLAZA_UserItemScoreUpdate,
            para = {clientUserItem=useritem,preUserScore=preUserScore},
            caller = self
        })
	end
end
--更新状态
function PlazaUserManagerController:UpdateUserItemStatus(dwUserID, userStatus)
	if self.plazaUserItems[tostring(dwUserID)] then
		local useritem = self.plazaUserItems[tostring(dwUserID)]
		local preUserStatus = {wTableID=useritem.wTableID,
								wChairID=useritem.wChairID,
								cbUserStatus=useritem.cbUserStatus}
								
		useritem.wTableID = userStatus.wTableID
		useritem.wChairID = userStatus.wChairID
		useritem.cbUserStatus = userStatus.cbUserStatus

		AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = PlazaUserManagerController.Message.PLAZA_UserItemStatusUpdate,
            para = {clientUserItem=useritem,preUserStatus=preUserStatus},
            caller = self
        })
	end
end
--更新属性
function PlazaUserManagerController:UpdateUserItemAttrib(dwUserID, userAttrib)
	if self.plazaUserItems[tostring(dwUserID)] then
		self.plazaUserItems[tostring(dwUserID)].cbCompanion = userAttrib.cbCompanion
	end
end
--更新头像
--bool UpdateUserCustomFace(IClientUserItem * pIClientUserItem, DWORD dwCustomID, tagCustomFaceInfo & CustomFaceInfo)=NULL;
--更新比赛状态
function PlazaUserManagerController:UpdateUserMatchStatus(dwUserID, cbEnlistStatus)
	if self.plazaUserItems[tostring(dwUserID)] then
		local useritem = self.plazaUserItems[tostring(dwUserID)]
		useritem.cbEnlistStatus = cbEnlistStatus
	end
end
--更新比赛排名
function PlazaUserManagerController:UpdateUserItemMatchRank()
	local userItemsTemp = {}
	for k,v in pairs(self.plazaUserItems) do
		if v.cbEnlistStatus ~= MS_OUT and v.cbEnlistStatus ~= MS_LEAVE then
			table.insert(userItemsTemp,v)
		end
	end
	local rankSortFunc = function(item1,item2)
		-- 1 按分数
		local llCompare1 = item1.lScore
		local llCompare2 = item2.lScore
		if llCompare1==llCompare2 then
			llCompare1 = item1.dwExperience
			llCompare2 = item2.dwExperience
		end
		return llCompare1 > llCompare2
	end
	if #userItemsTemp > 0 then
		table.sort(userItemsTemp,rankSortFunc)
		for i,v in ipairs(userItemsTemp) do
			v.dwUserRank = i
		end
	end
end

--查找接口
--查找用户
function PlazaUserManagerController:SearchUserByUserID(dwUserID)
	return self.plazaUserItems[tostring(dwUserID)]
end
--查找用户
function PlazaUserManagerController:SearchUserByGameID(dwGameID)
	for k,v in pairs(self.plazaUserItems) do
		if v.dwGameID == dwGameID then
			return v
		end
	end
end
--查找用户
function PlazaUserManagerController:SearchUserByNickName(pszNickName)
	for k,v in pairs(self.plazaUserItems) do
		if v.szNickName == pszNickName then
			return v
		end
	end
end
--获得人数
function PlazaUserManagerController:GetActiveUserCount()
	local total = 0
	for k,v in pairs(self.plazaUserItems) do
		total = total + 1
	end
	return total
end
--获取用户数组
function PlazaUserManagerController:GetUserItemsByTable(wTableID)
	local items = {}
	for k,v in pairs(self.plazaUserItems) do
		if v.wTableID == wTableID then
			table.insert(items,v)
		end
	end
	return #items,items
end
-- 获取全部用户
function PlazaUserManagerController:GetAllUserItems()
	return self.plazaUserItems
end
-- 清空用户列表
function PlazaUserManagerController:removeAllUserItems()
	self.plazaUserItems = {}
end

return PlazaUserManagerController