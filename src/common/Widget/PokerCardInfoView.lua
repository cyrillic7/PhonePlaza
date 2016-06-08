-- 桌子上一个玩家所有牌组成的view
-- Author: bo.mo
-- Date: 2014-10-14 16:19:27
--

local PokerCardInfoView = class("PokerCardInfoView", function()
	return ccui.Layout:create()
end)

local CardOffset = 20
local CardZOrder = 100

function PokerCardInfoView:ctor( )
	--所有的牌数组
	self.cardsRow = self.cardsRow or {}

	--第二行的牌,分牌情况下才用到
	self.cardsRow2 = self.cardsRow2 or {}

	self.tableSide = nil
end

-- 设置在桌子哪一边
function PokerCardInfoView:setTableSide( side )
	self.tableSide = side
	self:resetCardPostion()
end

function PokerCardInfoView:resetCardPostion()
	local cards = self.cardsRow
	local posY = 20
	for k,card in pairs(cards) do
		card:stopAllActions()
		card:setVisible(true)
		if self.tableSide and self.tableSide == PokerTableSide.right then
			card:setLocalZOrder(CardZOrder * 2 - k)
			card:setPosition(cc.p(-card:getContentSize().width / 2 - CardOffset * (k - 1), posY))
		else
			card:setPosition(cc.p(card:getContentSize().width / 2 + CardOffset * (k - 1), posY))
			card:setLocalZOrder(CardZOrder * 2 + k)
		end
	end
	cards = self.cardsRow2
	posY = 50
	for k,card in pairs(cards) do
		card:stopAllActions()
		card:setVisible(true)
		if self.tableSide and self.tableSide == PokerTableSide.right then
			card:setLocalZOrder(CardZOrder - k)
			card:setPosition(cc.p(-card:getContentSize().width / 2 - CardOffset * (k - 1), posY))
		else
			card:setPosition(cc.p(ard:getContentSize().width / 2 + CardOffset * (k - 1), posY))
			card:setLocalZOrder(CardZOrder + k)
		end
	end
end

-- args :
-- {card :			牌的实例
--  isRow2 :		是不是第二排(可选)
--  isDeal :		是否播放发牌动画(可选)
--  delay :			延迟时间(可选)
-- }
-- 发一张牌 
function PokerCardInfoView:giveCard(args)
	local card = args.card

	if card then
		local posY = 20
		local cardsCount = #self.cardsRow

		if self.tableSide ~= PokerTableSide.middle then
			if cardsCount > 0 then
				local lastCard = self.cardsRow[cardsCount]
				if self.tableSide and self.tableSide == PokerTableSide.right  then
					card:setLocalZOrder(lastCard:getLocalZOrder() - 1)
					card:setPosition(cc.p(-args.card:getContentSize().width / 2 - CardOffset * (cardsCount), posY))
				else
					card:setPosition(cc.p(args.card:getContentSize().width / 2 + CardOffset * (cardsCount), posY))
				end
			else
				if self.tableSide and self.tableSide == PokerTableSide.right  then
					card:setPosition(cc.p(-args.card:getContentSize().width / 2, posY))
				else
					card:setPosition(cc.p(args.card:getContentSize().width / 2, posY))
				end
			end
		else
			if cardsCount == 0 then
				card:setPosition(cc.p(-20, 20))
				card:setRotation3D({x =0, y=0, z=-15})
			else
				card:setPosition(cc.p(40, 15))
				card:setRotation3D({x =0, y=0, z=15})
			end
		end

		table.insert(self.cardsRow, card)
		self:addChild(card)

		--播放发牌动画
		if args.isDeal then
			local pos = cc.p(card:getPositionX(), card:getPositionY())
			args.card:dealCard{startPos = self.startPos or pos, endPos = pos, delay = args.delay}
		end
	end
end

-- 清除所有的牌
function PokerCardInfoView:clearAllCards(  )
	for i = 1, #self.cardsRow do
		if self.cardsRow[i] then
			self.cardsRow[i]:removeFromParent()
			self.cardsRow[i] = nil
		end
	end

	for i = 1, #self.cardsRow2 do
		if self.cardsRow2[i] then
			self.cardsRow2[i]:removeFromParent()
			self.cardsRow2[i] = nil
		end
	end
end

-- 牌都变黑
function PokerCardInfoView:playGiveUpEffect()
	for i, card in ipairs(self.cardsRow) do
		card:setColor(cc.c3b(100, 100, 100))
	end
end

-- 牌都变亮
function PokerCardInfoView:playReloadedEffect()
	for i, card in ipairs(self.cardsRow) do
		card:setColor(cc.c3b(255, 255, 255))
	end
end

-- 分牌
function PokerCardInfoView:splitCards(row1Table,row2Table)
	self:clearAllCards()

	for k, v in pairs(row1Table) do
		self:giveCard{card = v, isRow2 = false}
	end

	if nil ~= row2Table then
		for k, v in pairs(row2Table) do
			self:giveCard{card = v, isRow2 = true}
		end
	end

end

function PokerCardInfoView:setGiveCardStartPos(pos)
	self.startPos = pos
end

function PokerCardInfoView:resetGiveCardStartPos()
	local dealPosY = 160
	if self:getParent() then
		--计算屏幕中心的相对坐标
		local middlePosX = display.cx - self:getParent():getPositionX() - self:getPositionX()
		local middlePosY = display.cy - self:getParent():getPositionY() - self:getPositionY()
		--设置发牌起始坐标
		local cardStartPos = cc.p(middlePosX, middlePosY + dealPosY)
		self.startPos = cardStartPos
	end
end

-- args :
-- {cards :			牌的数值
--  isRow2 :		是不是第二排
--  delay :			延迟时间
-- }
-- 翻开已有的盖牌(含赋值)
function PokerCardInfoView:turnOnCoverCards(args)
	local delay = args.delay or 0
	local cardsRow = self.cardsRow
	if args.isRow2 then
		cardsRow = self.cardsRow2
	end
	for i=1,#args.cards do
		if i <= #cardsRow then
			local card = cardsRow[i]
			if card:isCover() then
				card:modify(GameUtil:GetCard(tonumber(args.cards[i])))
				local pos = cc.p(card:getPositionX(), card:getPositionY())
				-- card:open()
				card:turnOverCard{startPos = pos, endPos = pos, delay = delay, isTurnOpen = true}
				delay = delay + 0.18
			end
		end
	end
end

--
function PokerCardInfoView:foldCard()
		--计算屏幕中心的相对坐标
	if self:getParent() then
		local middlePosX = display.cx - self:getParent():getPositionX() - self:getPositionX() + self:getContentSize().width*2
		local middlePosY = display.cy*2 - self:getParent():getPositionY() - self:getPositionY()
		--设置牌到达的终点
		local endPos = cc.p(middlePosX, middlePosY)

		for i = 1, #self.cardsRow do
			local  card = self.cardsRow[i]
			if card then
				local  mt = cc.MoveTo:create(1,endPos)
				local  remove = cc.CallFunc:create(handler(self, self.removeCardFromCardRow1))
				card:runAction(cc.Sequence:create({mt,remove}))
			end
		end
	end
end

function PokerCardInfoView:removeCardFromCardRow1(sender)
	if sender then
		sender:removeFromParent()
		local index = table.indexof(self.cardsRow, sender)
		if index then
			table.remove(self.cardsRow, index)
		end
	end	
end

return PokerCardInfoView