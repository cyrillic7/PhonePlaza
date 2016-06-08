--
-- Author: SuperM
-- Date: 2016-02-22 17:30:09
--
local HallHornController = class("HallHornController")

HallHornController.MAX_HORN_COUNT = 5

HallHornController.ACCOUNTS_COLOR = cc.c3b(255, 240, 0)
HallHornController.NORMAL_COLOR = cc.c3b(255, 255, 255)

function HallHornController:ctor(richText,missionMatch)
	self.richText = richText
	self.missionMatch = missionMatch
	self.hornMsgs = {}
	self.hornWaitMsg = {}

	self.isRolling = false
	self.rollCount = 0
end

function HallHornController:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[appBase.Message.LS_LinkConnect] = handler(self, self.receiveConnectServerMessage)
    eventListeners[appBase.Message.LS_GetHornMessage] = handler(self, self.receiveHallHornMessage)
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function HallHornController:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function HallHornController:onTouchHornAreaEvent(event)
	if event.name == "began" then
		if not self.hornMsgWidget then
			self.hornMsgWidget = require("plazacenter.widgets.HallHornMsgWidget").new(display.getRunningScene(),self.hornMsgs,self.missionMatch)
		end
		self.hornMsgWidget:showHornMsgWidget()
	end
	return true
end

function HallHornController:insertString(szString,txtColor,fontSize)
	if self.richText then
		self.richText:pushBackElement(ccui.RichElementText:create(1, txtColor, 255, szString, "微软雅黑", fontSize or 20 ))
	end
end

function HallHornController:insertUserAccounts(userName)
	if self.richText then
		self:insertString("【"..userName.."】", self.ACCOUNTS_COLOR)
	end
end

function HallHornController:insertNormalString(szString)
	if self.richText then
		self:insertString(szString.."              ", self.NORMAL_COLOR)
	end
end

function HallHornController:reRollHornMsg()
	if self.richText then
		self.richText:stopAllActions()
		self.richText:formatText()
		self.richText:setPositionX(self.richText.maxWidth)
		local realSize = self.richText:getVirtualRendererRealSize()
		local moveWidth = realSize.width + self.richText.maxWidth
		local sequence = transition.sequence({
					cc.MoveBy:create(0.015*moveWidth,cc.p(-moveWidth,0)),
				    cc.CallFunc:create(function ()
				    		if #self.hornWaitMsg > 0 then
				    			-- 判断是否超过最大条数
				    			if self.richText:getElementCount() >= self.MAX_HORN_COUNT*2 then
				    				self.richText:removeElement(0)
				    				self.richText:removeElement(0)
				    			end
				    			-- 插入新数据
				    			for i,v in ipairs(self.hornWaitMsg) do
				    				self:insertUserAccounts(v.szNickName)
									self:insertNormalString(v.szLabaText)
				    			end
				    			self.hornWaitMsg = {}
				    		end
				    		self:reRollHornMsg()
				    end)
				})
		self.richText:runAction(sequence)
	end
end

function HallHornController:addOneRollHornMsg(hornMsg)
	if self.richText and hornMsg then
		if not self.isRolling then
			self.isRolling = true
			self:insertUserAccounts(hornMsg.szNickName)
			self:insertNormalString(hornMsg.szLabaText)
			self:reRollHornMsg()
		else
			table.insert(self.hornWaitMsg,hornMsg)
		end
	end
end

function HallHornController:receiveConnectServerMessage(event)
	if event.para.bConnectSucc then
        self.hornMsgs = {}
        self.hornWaitMsg = {}
    end
end

function HallHornController:receiveHallHornMessage(event)
	--[[local CMD_GL_Laba = {
		dwUserID= ,
		szNickName="",
		dwKindID= ,
		dwServerID= ,
		dwPropNum= ,
		szLabaText="",
	}]]
	table.insert(self.hornMsgs,event.para)
	self:addOneRollHornMsg(event.para)
end

return HallHornController