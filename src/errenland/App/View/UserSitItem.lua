
--[[
本类适合声明用户使用相同的元素 如 时钟，准备标志，pass标志 叫抢地主等文字提示，报警动画 以及头像
非使用json文件绘制的元素 待优化结构 使用时声明为数组
]]

local UserSitItem =class("UserSitItem", function()
	return display.newLayer()end) 
--构造
function UserSitItem:ctor()
	self.alarmBg=display.newSprite("errenland/WarningBack.png")
	self.imageAlram=display.newSprite("errenland/Warninglight.png")
	self.alarmBg:addTo(self)
	self.imageAlram:addTo(self)

	self.alarmBg:hide()
	self.imageAlram:hide()
end

function UserSitItem:Reset()

	self.alarmBg:hide()
	self.imageAlram:hide()
	self.imageAlram:stopAllActions()
end

function UserSitItem:showAlarm(isVisible)
	self.alarmBg:setVisible(isVisible)
	if isVisible then
		local blink = cc.Blink:create(3600, 4000)
    	self.imageAlram:runAction(blink)
	else
		self.imageAlram:stopAllActions()
	end
end
function UserSitItem:setWarnningPort(port)
	self.alarmBg:setPosition(port.x, port.y)
	self.imageAlram:setPosition(port.x, port.y)
end

return UserSitItem