local ChatMsgController = class("ChatMsgController")

ChatMsgController.MAX_ELEMENT_COUNT = 200

ChatMsgController.ACCOUNTS_COLOR = cc.c3b(20, 139, 70)
ChatMsgController.SYSTEM_COLOR = cc.c3b(10, 10, 10)
ChatMsgController.NORMAL_COLOR = cc.c3b(83, 75, 68)
ChatMsgController.WARN_COLOR = cc.c3b(255, 128, 0)

function ChatMsgController:ctor(richText,scrollView)
	self.richText = richText
	self.scrollView = scrollView
end

function ChatMsgController:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    local plazaUserManager = require("plazacenter.controllers.PlazaUserManagerController")
    eventListeners[appBase.Message.GS_ConfigServer] = handler(self, self.receiveConfigServerMessage)
    eventListeners[appBase.Message.GS_LoginFinish] = handler(self, self.receiveLoginFinishMessage)
    eventListeners[appBase.Message.GS_SystemMessage] = handler(self, self.receiveSystemMessageMessage)
    eventListeners[plazaUserManager.Message.PLAZA_UserItemAcitve] = handler(self, self.onUserItemAcitve)
    eventListeners[plazaUserManager.Message.PLAZA_UserItemDelete] = handler(self, self.onUserItemDelete)
    eventListeners[plazaUserManager.Message.PLAZA_UserItemStatusUpdate] = handler(self, self.onUserItemStatusUpdate)
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function ChatMsgController:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function ChatMsgController:resizeRichTextPos()
	self.hasScheduler = self.hasSchedul or false
	if not self.hasScheduler then
		self.hasScheduler = true

		local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
	    scheduler.performWithDelayGlobal(function ()
	        if self.richText and self.scrollView then
				self.richText:formatText()
				local realSize = self.richText:getVirtualRendererRealSize()
				self.scrollView:setInnerContainerSize(realSize) 
		    	self.richText:setPosition(0,realSize.height)
    			self.scrollView:jumpToBottom()
			end
			self.hasScheduler = false
	    end, 0)
	end
end

function ChatMsgController:addNewLine()
	if self.richText then
		if self.richText:getElementCount() > 0 then
			self.richText:pushBackElement(ccui.RichElement:new())
		end
	end
end

function ChatMsgController:insertString(szString,txtColor,fontSize)
	if self.richText then
		self.richText:pushBackElement(ccui.RichElementText:create(1, txtColor, 255, szString, "微软雅黑", fontSize or 20 ))
	end
end

function ChatMsgController:insertUserAccounts(userName)
	if self.richText then
		self:insertString("【"..userName.."】", self.ACCOUNTS_COLOR)
	end
end

function ChatMsgController:insertUserEnter(userName)
	if self.richText then
		self:addNewLine()
		self:insertUserAccounts(userName)
		self:insertString("进来了", self.NORMAL_COLOR)
		self:resizeRichTextPos()
	end
end

function ChatMsgController:insertUserLeave(userName)
	if self.richText then
		self:addNewLine()
		self:insertUserAccounts(userName)
		self:insertString("离开了", self.NORMAL_COLOR)
		self:resizeRichTextPos()
	end
end

function ChatMsgController:insertUserOffLine(userName)
	if self.richText then
		self:addNewLine()
		self:insertUserAccounts(userName)
		self:insertString("离开了", self.WARN_COLOR)
		self:resizeRichTextPos()
	end
end

function ChatMsgController:insertSystemString(szString)
	if self.richText then
		self:addNewLine()
		self:insertString("【系统消息】"..szString, self.SYSTEM_COLOR)
		self:resizeRichTextPos()
	end
end

function ChatMsgController:receiveConfigServerMessage(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	self.ConfigServer = event.para
	if self.richText then
		local size = self.richText:getVirtualRendererRealSize()
		local count = self.richText:getElementCount()
		while count > 0 do
			self.richText:removeElement(count-1)
			count = count - 1
		end
		self:resizeRichTextPos()
	end

	self.bLoginFinish = false
end

function ChatMsgController:receiveLoginFinishMessage(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	self.bLoginFinish = true
end

function ChatMsgController:receiveSystemMessageMessage(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	local wType = event.para.wType
	if (0 ~= bit._and(wType, SMT_CHAT)) then
		self:insertSystemString(event.para.szString)
	end
end

function ChatMsgController:onUserItemAcitve(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	if not self.bLoginFinish then
		return
	end
	
	self:insertUserEnter(event.para.szNickName)
end

function ChatMsgController:onUserItemDelete(event)
	if event.caller and event.caller.bMatchGame then
		return
	end

	self:insertUserLeave(event.para.szNickName)
end

function ChatMsgController:onUserItemStatusUpdate(event)
	if event.caller and event.caller.bMatchGame then
		return
	end
	
	local clientUserItem = event.para.clientUserItem
    local preUserStatus = event.para.preUserStatus
    local cbNowStatus = clientUserItem.cbUserStatus
    local cbLastStatus = preUserStatus.cbUserStatus
    if cbNowStatus == US_OFFLINE then
    	self:insertUserOffLine(clientUserItem.szNickName)
    elseif cbNowStatus == US_PLAYING and cbLastStatus == US_OFFLINE then
    	self:insertSystemString(clientUserItem.szNickName.." 断线回来了！")
    end
end

return ChatMsgController