--
-- Author: Your Name
-- Date: 2015-10-20 16:31:16
--
local UserListController = class("UserListController")

UserListController.MYSELF_COLOR = cc.c4b(20, 139, 70 ,255)
UserListController.MASTER_COLOR = cc.c4b(95, 86, 255 ,255)
UserListController.MEMBER_COLOR = cc.c4b(231, 78, 43 ,255)
UserListController.NORMAL_COLOR = cc.c4b(83, 75, 68 ,255)

UserListController.NICK_MAX_LEN = 6*3
UserListController.GOLD_MAX_LEN = 11
UserListController.SCORE_MAX_LEN = 8

function UserListController:ctor(listView)
	self.listView = listView
	self.items = {}

	listView:addEventListener(function (sender, eventType)
                if eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
                    self:onListViewitemClicked(sender)
                end                
                return true
            end)
end

function UserListController:onListViewitemClicked(sender)
	-- 防作弊模式不显示
	if (0 ~= bit._and(self.ConfigServer.dwServerRule, SR_ALLOW_AVERT_CHEAT_MODE)) then
		return
	end
	local index = sender:getCurSelectedIndex()
	local clickedItem = self.items[index+1]
	if not clickedItem or clickedItem.userItem.dwUserID == GlobalUserInfo.dwUserID then
		return
	end
	if not self.userInfoWidget then
		local userInfoWidget = require("plazacenter.widgets.UserInfoWidget")
		self.userInfoWidget = userInfoWidget.new(self.listView:getScene(), userInfoWidget.LIST_TYPE)
	end
	local position = clickedItem:getParent():convertToWorldSpace(cc.p(0,clickedItem:getPositionY()))
	self.userInfoWidget:updateUserInfo(clickedItem.userItem,position.x+40,position.y+30)
	self.userInfoWidget:showUserInfo(true)
end

function UserListController:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    local plazaUserManager = require("plazacenter.controllers.PlazaUserManagerController")
    eventListeners[appBase.Message.GS_ConfigServer] = handler(self, self.receiveConfigServerMessage)
    eventListeners[appBase.Message.GS_LoginFinish] = handler(self, self.receiveLoginFinishMessage)
    eventListeners[plazaUserManager.Message.PLAZA_UserItemAcitve] = handler(self, self.onUserItemAcitve)
    eventListeners[plazaUserManager.Message.PLAZA_UserItemDelete] = handler(self, self.onUserItemDelete)
    eventListeners[plazaUserManager.Message.PLAZA_UserItemScoreUpdate] = handler(self, self.onUserItemScoreUpdate)
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function UserListController:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function UserListController:createUserListItem(clientUserItem)
	local textColor = self.NORMAL_COLOR
	if clientUserItem.dwUserID == GlobalUserInfo.dwUserID then
		textColor = self.MYSELF_COLOR
	elseif clientUserItem.cbMasterOrder > 0 then
		textColor = self.MASTER_COLOR
	elseif clientUserItem.cbMemberOrder > 0 then
		textColor = self.MEMBER_COLOR
	end
    local item = ccui.Layout:create()
    item:setContentSize(265+110,45)
    item:setBackGroundColorType(LAYOUT_COLOR_SOLID)
	item:setBackGroundColor(display.COLOR_BLACK)
	item:setOpacity(0)
    item:setTouchEnabled(true)
    item:setSwallowTouches(false)
    -- 头像
    local imgFace = ccui.ImageView:create("pic/face/"..clientUserItem.wFaceID..".png",UI_TEX_TYPE_PLIST)
    imgFace:setScale(0.2)
    imgFace:setPosition(22, 21)
    item:addChild(imgFace)
    item.imgFace = imgFace
    -- 会员
    if clientUserItem.cbMemberOrder > 0 then
    	local memberOrder = clientUserItem.cbMemberOrder
    	local memIcon = nil
    	if memberOrder >= 7 then
    		memIcon =ccui.ImageView:create("pic/plazacenter/TableFrame/u_icon_jewel_red.png",UI_TEX_TYPE_PLIST)
    	elseif memberOrder > 3 then
    		memIcon =ccui.ImageView:create("pic/plazacenter/TableFrame/u_icon_jewel_yellow.png",UI_TEX_TYPE_PLIST)
    	else
    		memIcon =ccui.ImageView:create("pic/plazacenter/TableFrame/u_icon_jewel_blue.png",UI_TEX_TYPE_PLIST)
    	end
    	memIcon:setPosition(32, 12)
    	memIcon:setScale(1.2)
    	item:addChild(memIcon)
    end
    -- 昵称
    local textName = ccui.Text:create(G_TruncationString(clientUserItem.szNickName,self.NICK_MAX_LEN),"微软雅黑",18)
    textName:setPosition(113,21)
    textName:setTextColor(textColor)
    item:addChild(textName)
    item.textName = textName
    -- 金币
    local textGold = ccui.Text:create(tostring(clientUserItem.lScore),"微软雅黑",20)
    textGold:setPosition(221,21)
    textGold:setTextColor(textColor)
    item:addChild(textGold)
    item.textGold = textGold
    -- 积分
    local textScore = ccui.Text:create(tostring(checknumber(clientUserItem.lJifen)),"微软雅黑",20)
    textScore:setPosition(321,21)
    textScore:setTextColor(textColor)
    item:addChild(textScore)
    item.textScore = textScore

    item.userItem = clientUserItem

    return item
end

function UserListController:getInsertIndex(userItem)
	if userItem.dwUserID == GlobalUserInfo.dwUserID then
		return 0
	end
	local masterOrder = userItem.cbMasterOrder
	local memberOrder = userItem.cbMemberOrder
	local lScore = userItem.lScore
	if #self.items > 1 then
		for i=2,#self.items do
			local v = self.items[i]
			if masterOrder > v.userItem.cbMasterOrder then
				return i-1
			elseif masterOrder == v.userItem.cbMasterOrder then
				if memberOrder > v.userItem.cbMemberOrder then
					return i-1
				elseif memberOrder == v.userItem.cbMemberOrder then
					if lScore > v.userItem.lScore then
						return i-1
					end
				end
			end
		end
	end

	return #self.items
end

function UserListController:updateListItemsBg()
	if not self.listView then
		return
	end
	for i,v in ipairs(self.items ) do
		if i%2 == 0 then
			v:setOpacity(25)
		else			
			v:setOpacity(0)
		end
	end
end

function UserListController:insertDataItem(userItem)
	if not self.listView then
		return
	end
	
	local nInsertIndex = self:getInsertIndex(userItem)
	local item = self:createUserListItem(userItem)
	table.insert(self.items,nInsertIndex+1,item)
	self.listView:insertCustomItem(item,nInsertIndex)
	self:updateListItemsBg()
end

function UserListController:updateDataItem(userItem)
	if not self.listView then
		return
	end

	for i,v in ipairs(self.items) do
		if v.userItem.dwUserID == userItem.dwUserID then
			if v.imgFace then
				v.imgFace:loadTexture("pic/face/"..userItem.wFaceID..".png",UI_TEX_TYPE_PLIST)
			end
			if v.textName then
				v.textName:setString(G_TruncationString(userItem.szNickName,self.NICK_MAX_LEN))
			end
			if v.textGold then
				v.textGold:setString(tostring(userItem.lScore))
			end
			--if v.textScore then
			--	v.textScore:setString(tostring(userItem.lScore))
			--end
			v.userItem = userItem

			self:updateListItemsBg()
			return
		end
	end
end

function UserListController:deleteDataItem(userItem)
	if not self.listView then
		return
	end
	for i,v in ipairs(self.items) do
		if v.userItem.dwUserID == userItem.dwUserID then
			self.listView:removeItem(i-1)
			table.remove(self.items,i)
			self:updateListItemsBg()
			return
		end
	end	
end

function UserListController:receiveConfigServerMessage(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	self.ConfigServer = event.para
	if self.listView then
		self.listView:removeAllItems()
		self.items = {}
		self.listView.parentScrollBg:jumpToTopLeft()
		self.listView:jumpToTop()
	end

	self.bLoginFinish = false
	self.nUserCount = 0
end

function UserListController:receiveLoginFinishMessage(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	self.bLoginFinish = true
end

function UserListController:onUserItemAcitve(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	if self.bLoginFinish then
		self:insertDataItem(event.para)
	else
		if self.listView then
			self.nUserCount = self.nUserCount + 1
			self.listView:performWithDelay(function ()
				self:insertDataItem(event.para)
			end, self.nUserCount/60)
		end
	end
end

function UserListController:onUserItemDelete(event)
	if event.caller and event.caller.bMatchGame then
		return
	end

	self:deleteDataItem(event.para)
end

function UserListController:onUserItemScoreUpdate(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	
	self:updateDataItem(event.para.clientUserItem)
end

return UserListController