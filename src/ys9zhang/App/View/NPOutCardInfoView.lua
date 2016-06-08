
local PokerCard = require("common.Widget.PokerCard")

local NPOutCardInfoView = class("NPOutCardInfoView", function()
	return ccui.Layout:create()
end)

function NPOutCardInfoView:ctor(args)
	--出牌的数组
	self.outCards = self.outCards or {}

	self.isMySelf = args.isMySelf
	--默認間距
	self.CardOffset = 25 

	self:setContentSize(cc.size(225,96))

	self.promptImage = ccui.ImageView:create()
	if self.isMySelf then
		self.promptImage:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
	else
		self.promptImage:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
	end
	self.promptImage:setVisible(false)
	self:addChild(self.promptImage)
end

function NPOutCardInfoView:showOutCard(outCards,outCardCnt)
	print("NPOutCardInfoView:showOutCard")
	if self.isMySelf then
		self:setPosition(self.pos)
	end
	local pos = self:calStartPos(outCardCnt)
	for i=1,outCardCnt do
		local cardType, cardNumber = GameUtil:GetCardForPc(outCards[i])
		local  card =  PokerCard.new{ctype = cardType, number = cardNumber}
		card:setScale(0.57)
		card:setPosition(cc.p(pos+(i-1)*self.CardOffset+card:getContentSize().width/2,self:getContentSize().height/2))
		table.insert(self.outCards,card)
		self:addChild(card)
	end
end

function NPOutCardInfoView:calStartPos(outCardCnt)
	local  width = self:getContentSize().width
	return (5-outCardCnt)*self.CardOffset/2
end

function NPOutCardInfoView:setTableSide(setTableSide)
	self.tableSide = setTableSide
	if self.isMySelf then
		self.pos = cc.p(310,180)
		self:setPosition(self.pos)
	else
		if self.tableSide == PokerTableSide.right then
			pos = cc.p(-150 ,-145)
		end
		if self.tableSide == PokerTableSide.left then
			pos = cc.p(-50 ,-145)
		end
		if self.tableSide == PokerTableSide.middle then
			pos = cc.p(-115 ,-155)
		end
		self:setPosition(pos)
	end
end

function NPOutCardInfoView:clearOutCards()
	print("NPOutCardInfoView:clearOutCards")
	dump(self.outCards)
	for k ,v in pairs(self.outCards) do
		v:removeFromParent()
	end
	self.outCards = {}

	if self.promptImage:isVisible() then
		self.promptImage:setVisible(false)
	end
end

function NPOutCardInfoView:showPromptImage(status)
	--从新设置提示的位置
	if self.isMySelf then
		self:setPosition(cc.p(310,155))
	end
	print("showPromptImage"..status)
	local imageName = nil
	if status == "pass" then
		imageName = "u_game_text_bechu.png"
	elseif status == "ready" then
		if self.isMySelf then
			self:setPosition(cc.p(310,70))
		end
		imageName = "u_game_text_ready.png"
		for k ,v in pairs(self.outCards) do
			v:removeFromParent()
		end
		self.outCards = {}
	elseif status == "feipai" then
		imageName = "u_game_text_prompt3.png"
	elseif status == "dazhushang" then
		imageName = "u_game_text_prompt4.png"
	end
	self.promptImage:loadTexture(string.format("ys9zhang/%s",imageName),0)
	if not self.promptImage:isVisible() then
		self.promptImage:setVisible(true)
	end
end




return NPOutCardInfoView