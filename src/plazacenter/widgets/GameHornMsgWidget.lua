--
-- Author: SuperM
-- Date: 2016-02-27 14:46:42
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local GameHornMsgWidget = class("GameHornMsgWidget", XWWidgetBase)

GameHornMsgWidget.ACCOUNTS_COLOR = cc.c3b(255, 240, 0)
GameHornMsgWidget.NORMAL_COLOR = cc.c3b(255, 255, 255)

function GameHornMsgWidget:ctor(parentNode,order)
	GameHornMsgWidget.super.ctor(self)
	
	self.hornWaitMsg = {}
	self:setLocalZOrder(order or 999)

	self:addTo(parentNode)
end

function GameHornMsgWidget:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[appBase.Message.LS_GetHornMessage] = handler(self, self.receiveHallHornMessage)
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function GameHornMsgWidget:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function GameHornMsgWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
    self:registerEvents()

	GameHornMsgWidget.super.onEnter(self)

	-- 创建喇叭背景
	local bgSize = cc.size(690,40)
	self.hornBg = display.newScale9Sprite("#pic/plazacenter/Sundry/u_horn_game_bg.png", 0, 0, bgSize)
	:align(display.BOTTOM_CENTER, display.cx, display.top)
	:addTo(self)
	-- 创建喇叭图标
	display.newSprite("#pic/plazacenter/Sundry/u_icon_horn.png")
	:align(display.CENTER, 40, bgSize.height/2)
	:addTo(self.hornBg)
	:scale(0.7)
	-- 创建喇叭显示richText
	local bgSize = self.hornBg:getContentSize()
	local hornPanel = display.newClippingRegionNode(cc.rect(0,0,bgSize.width-(60+30),bgSize.height))
	:addTo(self.hornBg)
	hornPanel:setContentSize(cc.size(bgSize.width-(60+30),bgSize.height))
	hornPanel:setPosition(60, 0)
	local richText = ccui.RichText:create()
        richText:setContentSize(cc.size(bgSize.width,bgSize.height))
        richText:setAnchorPoint(cc.p(0,0.5))
        richText:setPosition(0,bgSize.height/2)
        richText.maxWidth = bgSize.width-(60+30)
        hornPanel:addChild(richText)
    self.richText = richText
end

function GameHornMsgWidget:onExit()
	GameHornMsgWidget.super.onExit(self)
end

function GameHornMsgWidget:onCleanup()
	GameHornMsgWidget.super.onCleanup(self)

	self:unregisterEvents()
end

function GameHornMsgWidget:showHornMsgWidget(bShow)
	if self.hornBg then
		if not bShow then
			if not self.isHiding then
				self.isHiding = true
				self.hornBg:stopAllActions()
				local size = self.hornBg:getContentSize()
				self.hornBg:setPositionY(display.top-size.height)
				transition.execute(self.hornBg, cc.MoveBy:create(0.2,cc.p(0,size.height)), 
					{easing = "exponentialOut",
						onComplete = function()
						    self.isHiding = false
						end})
			end
		else
			if not self.isShowing then
				self.isShowing = true
				self.hornBg:stopAllActions()
				local size = self.hornBg:getContentSize()
				self.hornBg:setPositionY(display.top)
				transition.execute(self.hornBg, cc.MoveBy:create(0.2,cc.p(0,-size.height)), 
					{easing = "exponentialIn",
						onComplete = function()
						    self.isShowing = false
						end})
			end
		end
	end
end


function GameHornMsgWidget:insertString(szString,txtColor,fontSize)
	if self.richText then
		self.richText:pushBackElement(ccui.RichElementText:create(1, txtColor, 255, szString, "微软雅黑", fontSize or 20 ))
	end
end

function GameHornMsgWidget:insertUserAccounts(userName)
	if self.richText then
		self:insertString("【"..userName.."】", self.ACCOUNTS_COLOR)
	end
end

function GameHornMsgWidget:insertNormalString(szString)
	if self.richText then
		self:insertString(szString.."              ", self.NORMAL_COLOR)
	end
end

function GameHornMsgWidget:reRollHornMsg()
	if self.hornBg then
		if not self.isRolling then
			self.isRolling = true
			self:showHornMsgWidget(true)
		end
	end
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
				    			-- 清空数据
				    			while self.richText:getElementCount() > 0 do
				    				self.richText:removeElement(0)
				    			end
				    			-- 插入新数据
				    			for i,v in ipairs(self.hornWaitMsg) do
				    				self:insertUserAccounts(v.szNickName)
									self:insertNormalString(v.szLabaText)
				    			end
				    			self.hornWaitMsg = {}
				    			self:reRollHornMsg()
				    		else
				    			self:showHornMsgWidget(false)
				    			self.isRolling = false
				    		end
				    end)
				})
		self.richText:runAction(sequence)
	end
end

function GameHornMsgWidget:addOneRollHornMsg(hornMsg)
	if self.richText and hornMsg then
		if not self.isRolling then
			self:insertUserAccounts(hornMsg.szNickName)
			self:insertNormalString(hornMsg.szLabaText)
			self:reRollHornMsg()
		else
			table.insert(self.hornWaitMsg,hornMsg)
		end
	end
end

function GameHornMsgWidget:receiveHallHornMessage(event)
	--[[local CMD_GL_Laba = {
		dwUserID= ,
		szNickName="",
		dwKindID= ,
		dwServerID= ,
		dwPropNum= ,
		szLabaText="",
	}]]
	self:addOneRollHornMsg(event.para)
end

return GameHornMsgWidget