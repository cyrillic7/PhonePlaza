-- 桌子上一个玩家所有牌组成的view
-- Author: jielingtan
-- Date: 2016-4-14 10:19:27
--

local baccaratCardInfoView = class("baccaratCardInfoView", function()
	return ccui.Layout:create()
end)

-- 游戏桌子的左边, 右边, 中间方向表
PokerTableSide = {left = -1, middle = 0, right = 1}

baccaratCardInfoView.CardOffset = 40

local CardZOrder = 100

function baccaratCardInfoView:ctor()
	--所有的牌数组
	self.cards = self.cards or {}

	self.tableSide = nil
end

-- args :
-- {card :			牌的实例
--  isDeal :		是否播放发牌动画(可选)
--  delay :			延迟时间(可选)
--  moveEndHandler: 移动结束回调
--isTurnOpen:是否翻转
-- }
-- 发一张牌 
function baccaratCardInfoView:giveCard( args )
	if args.card then
		local cards = self.cards

		local posY = args.card:getContentSize().height/2

		local cardsCount = #cards
		if cardsCount > 0 then
			local lastCard = cards[cardsCount]
			if self.tableSide and self.tableSide == PokerTableSide.right  then
				args.card:setLocalZOrder(lastCard:getLocalZOrder() - 1)
				args.card:setPosition(cc.p(-args.card:getContentSize().width / 2 - self.CardOffset*cardsCount, posY))
			else
				args.card:setPosition(cc.p(args.card:getContentSize().width / 2 + self.CardOffset*cardsCount, posY))
				args.card:setLocalZOrder(CardZOrder+cardsCount)   
			end
			
		else
			if self.tableSide and self.tableSide == PokerTableSide.right  then
				args.card:setPosition(cc.p(-args.card:getContentSize().width / 2, posY))
			else
				args.card:setPosition(cc.p(args.card:getContentSize().width / 2, posY))
			end
			args.card:setLocalZOrder(CardZOrder+cardsCount)   
		end

		table.insert(cards, args.card)
		self:addChild(args.card)
		
		--播放发牌动画
		if args.isDeal then
			local pos = cc.p(args.card:getPositionX(),args.card:getPositionY())
			if args.moveEndHandler then
				--args.card:dealBaccaratCard{startPos = self.startPos or pos, endPos = pos, delay = args.delay,moveEndHandler = args.moveEndHandler,isTurnOpen = args.isTurnOpen,isBanker = args.isBanker}
				args.card:dealBaccaratCard{startPos = self.startPos or pos, endPos = pos, delay = args.delay,moveEndHandler = args.moveEndHandler,isTurnOpen = args.isTurnOpen,isBanker = args.isBanker}
			else
				args.card:dealBaccaratCard{startPos = self.startPos or pos, endPos = pos, delay = args.delay,isTurnOpen = args.isTurnOpen,isBanker = args.isBanker}
			end
		else --恢复牌面
			--TODO
		end
	end
end

function baccaratCardInfoView:clearAllCards()
	for i = 1, #self.cards do
		self.cards[i]:removeFromParent()
		self.cards[i] = nil
	end
end

-- 设置在桌子哪一边
function baccaratCardInfoView:setTableSide( side )
	self.tableSide = side
end


function baccaratCardInfoView:resetGiveCardStartPos()
	if self:getParent() then
		--计算屏幕中心的相对坐标
		--local middlePosX = display.cx - self:getParent():getPositionX() - self:getPositionX()
		--local middlePosY = display.cy - self:getParent():getPositionY() - self:getPositionY()
		--计算发牌点相当牌区域的相对坐标
		local middlePosX = display.width - 200 - self:getParent():getPositionX() - self:getPositionX()
		local middlePosY = display.height - 100 - self:getParent():getPositionY() - self:getPositionY()
		--设置发牌起始坐标
		local cardStartPos = cc.p(middlePosX, middlePosY)
		self.startPos = cardStartPos
	end
end


return baccaratCardInfoView
