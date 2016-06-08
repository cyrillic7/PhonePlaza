--
-- Author: tjl
-- Date: 2016-02-27 16:37:08
--
local TransferBattleBankerItemView = class("TransferBattleBankerItemView", function( )
	return ccui.Layout:create()
end)

--[[
{
	id :   序号
	nick:  昵称
	socre: 金币数
	chairId:椅子ID
}
--]]
function TransferBattleBankerItemView:ctor( info )
	if info then
		self.chairId = info.chairId
		local background = ccui.ImageView:create()
		if info.id % 2 ~= 0 then
			background:loadTexture("transferbattle/image_bank_itembg.png")
		else
			background:loadTexture("transferbattle/image_bank_itembg1.png")
		end
		self:addChild(background)
		self:setContentSize(background:getContentSize())
		background:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2 ))

	
		--nick
		local nickLabel = ccui.Text:create()
		nickLabel:setFontSize(14)
		nickLabel:setString(tostring(info.nick))
		nickLabel:setAnchorPoint(cc.p(0,0.5))
		nickLabel:setPosition(cc.p(5, background:getContentSize().height/2))
		background:addChild(nickLabel)
		
		-- score
		self.scoreLabel = ccui.Text:create()
		self.scoreLabel:setFontSize(14)
		self.scoreLabel:setColor(cc.c3b(255, 255, 0))
		self.scoreLabel:setAnchorPoint(cc.p(0,0.5))
		self.scoreLabel:setString(string.formatnumberthousands(info.score))
		self.scoreLabel:setPosition(cc.p(20+background:getContentSize().width/2, background:getContentSize().height/2))
		background:addChild(self.scoreLabel)
	end
end

function TransferBattleBankerItemView:getMyChairID()
	return self.chairId
end

function TransferBattleBankerItemView:refreshData(userInfo)
	print("BankerItemView refreshData"..userInfo.lScore)
	self.scoreLabel:setString(string.formatnumberthousands(userInfo.lScore))
end

return TransferBattleBankerItemView