
local PokerCard = require("common.Widget.PokerCard")

local NPPokerCardInfoView = class("NPPokerCardInfoView", function()
	return ccui.Layout:create()
end)

local CardZOrder = 100

-- 扑克牌牌型对应的中文名称
local CardTypeChineseNames = {
	"方块",		
	"梅花", 		
	"红桃",		
	"黑桃", 		
}

local tipMsgType = 
{
	CanotTakeTwo = 1, --不能带2
	MustBeTakeThree = 2, --必须带片3
	NotCardBigger   =3,--没有牌比它大
	DownPlayerIsAlarm = 4,--下家已报警
}

--[[
isMySelf 区别自已与其他玩家的牌面
]]
function NPPokerCardInfoView:ctor(args)
	--所有的手牌数组
	self.cards = self.cards or {}
	--出牌的数组
	self.outCards = self.outCards or {}
	--上一次操作选中的牌组
	self.lastSelectCards = {}

	self.tableSide = nil
	--默認間距
	self.CardOffset = 50 
	--手牌的张数
	self.cardsCount = 0

	if args.isMySelf then
		self.isMySelf = args.isMySelf
		--添加触摸事件
		self:setTouchEnabled(true)
    	self:setContentSize(cc.size(125 + 8*self.CardOffset,160))
    	--self:setBackGroundColorType(1)
    	--self:setBackGroundColor(cc.c3b(255,0,0))
    	self.pos = cc.p(166,display.bottom + 9)
    	self:setPosition(self.pos)
    	--是否能出牌的处理器
		if args.checkCanOutCardHandler then
			self.checkCanOutCardHandler = args.checkCanOutCardHandler
		end

		--提示框
		self.tipWindow = ccui.ImageView:create():addTo(self)
		self.tipWindow:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
		self.tipWindow:setVisible(false)
		self.tipWindow:setLocalZOrder(999)
    else
    	self.labelCardNumber = cc.LabelAtlas:_create("0:","ys9zhang/u_game_num_card.png",17,24,string.byte("0")):addTo(self)
		self.labelCardNumber:setLocalZOrder(999)
		self.labelCardNumber:setVisible(false)
	end
	--选牌数组
	self.selectCards = {}
	--是否托管
	self.isTuoGuan = false
end

function NPPokerCardInfoView:onClickCard(sender,touchType)
	--托管状态下不处理选牌操作
	if self.isTuoGuan == true then
		return
	end
	local card = sender:getParent()
	local winPos = sender:getTouchMovePosition()
	local pos = cc.p(card:getPositionX(),card:getPositionY())
	--print(string.format("pos.x = %d,pos.y = %d",pos.x,pos.y))
	local wordPos = card:getParent():convertToWorldSpace(pos)
	--print(string.format("wordPos.x = %d,wordPos.y = %d",wordPos.x,wordPos.y))
	if touchType == TOUCH_EVENT_BEGAN  then
		if  not self:hasInSelectCards(card) then
			table.insert(self.selectCards,card)
		end
		self.beganPos = sender:getTouchBeganPosition()
		--print(string.format("self.beganPos.x = %d,self.beganPos.y = %d",self.beganPos.x,self.beganPos.y))
	elseif touchType ==  TOUCH_EVENT_MOVED then
		
		local  curSelectNumber = #self.selectCards
		--保存上一次所选择的牌数组
		self.lastSelectCards = self.selectCards 
		self:checkCardIsSelct(card,winPos)
		--移动引起选牌的数量变化，才认为是真的移动
		if  #self.selectCards ~= curSelectNumber then
			self.isMove  = true
		end
	elseif touchType ==  TOUCH_EVENT_ENDED then
		SoundManager:playMusicEffect("ys9zhang/audio/selectCard.mp3", false)
		if self.isMove and #self.selectCards >=2 then
			self:clickEndedPro()
		else
			card:setSelect()
			if card:getStatus() == 0 then
				--从选中牌组中移除
				local  index = table.indexof(self.selectCards,card)
				if index then
					table.remove(self.selectCards,index)
				end
			end
		end
		self.isMove = false
	elseif touchType == TOUCH_EVENT_CANCELED then
		SoundManager:playMusicEffect("ys9zhang/audio/selectCard.mp3", false)
		self.isMove = false
		self:clickEndedPro() 
	end
	--print("self.selectCards1111 cnt = "..#self.selectCards)
	if  touchType ~= TOUCH_EVENT_MOVED and touchType ~= TOUCH_EVENT_BEGAN  then
		--清除状态为0且尚在选择牌数组中的牌
		for k,card in pairs(self.selectCards) do
			if  card:getStatus() == 0 then
				--从选中牌组中移除
				local  index = table.indexof(self.selectCards,card)
				if index then
					table.remove(self.selectCards,index)
				end
			end
		end
		--判断出牌按钮是否能亮
		if  self.checkCanOutCardHandler then
			self.checkCanOutCardHandler(self:getOutCards())
		end
	elseif touchType == TOUCH_EVENT_MOVED then
		--上次所选的牌不在这一次中，取掉选中状态
		for k,card in pairs(self.lastSelectCards) do
			local  index  = table.indexof(self.selectCards,card)
			if  not index then
				card:unPressed()
			end
		end
	end
end

function NPPokerCardInfoView:checkCardIsSelct( selectCard,winPos)

	self.selectCards = {}
	--把当前的卡加入数组中
	table.insert(self.selectCards,selectCard)

	for k ,card in pairs(self.cards) do
		--当前选中的牌除外
		if not selectCard:sameAs(card) then
			local movDistance = cc.pSub(winPos,self.beganPos)
			--从左往右选牌
			local curCardWinPos = card:getParent():convertToWorldSpace(cc.p(card:getPositionX(),card:getPositionY()))
			if movDistance.x > 0 then
				if curCardWinPos.x > self.beganPos.x then
					if winPos.x + card:getContentSize().width/2 >= curCardWinPos.x  then
						if  not self:hasInSelectCards(card) then
							table.insert(self.selectCards,card)
						end

						--如果选中的牌大于2张
						if #self.selectCards >= 2 then
							for k, v in pairs(self.selectCards) do
								v:Pressed()
							end
						end
					else
						local  index  = table.indexof(self.selectCards,card)
						if index then
							table.remove(self.selectCards,index)
						end
					end
				end
			else --从右往左选牌
				if  curCardWinPos.x < self.beganPos.x  then
					--if curCardWinPos.x + card:getContentSize().width/2 >=  winPos.x
					if curCardWinPos.x >=  winPos.x   then
						if  not self:hasInSelectCards(card) then
							table.insert(self.selectCards,card)
						end

						--如果选中的牌大于2张
						if #self.selectCards >= 2 then
							for k, v in pairs(self.selectCards) do
								v:Pressed()
							end
						end
					else
						local  index  = table.indexof(self.selectCards,card)
						if index then
							table.remove(self.selectCards,index)
						end
					end
				end
			end
		end
	end
end

function NPPokerCardInfoView:checkClickCard( winPos )
	--玩家所有选中的牌
	for k ,card in pairs(self.cards) do
		if card:hitTest(winPos) then
			print("hitTest")
			if  not self:hasInSelectCards(card) then
				table.insert(self.selectCards,card)
			end
		end
	end	
end

function NPPokerCardInfoView:hasInSelectCards(card)
	local ret = false
	if #self.selectCards > 0 then
		for k, v in pairs(self.selectCards) do
			if card:sameAs(v) then
				return true
			end
		end
	end
	return ret
end

function NPPokerCardInfoView:clickEndedPro()
	for k,card in pairs(self.selectCards) do
		card:setSelect()
	end

	--清除状态为0且尚在选择牌数组中的牌
	for k,card in pairs(self.selectCards) do
		if  card:getStatus() == 0 then
			--从选中牌组中移除
			local  index = table.indexof(self.selectCards,card)
			if index then
				table.remove(self.selectCards,index)
			end
		end
	end
end

function NPPokerCardInfoView:resetCardPostion()
	--[[local cards = self.cards
	local posY = 50
	local valueCards = {}
	for k,card in pairs(cards) do
		card:stopAllActions()
		card:setVisible(true)
		if card.moveEndHandler then
			card.moveEndHandler()
		end
		
		if self.tableSide and self.tableSide == PokerTableSide.right then
			card:setLocalZOrder(CardZOrder  - k)
			card:setPosition(cc.p(-card:getContentSize().width / 2 - self.CardOffset * (k - 1), posY))
		else
			card:setPosition(cc.p(card:getContentSize().width / 2 + self.CardOffset * (k - 1), posY))
			card:setLocalZOrder(CardZOrder  + k)
		end
		table.insert(valueCards,{type = card.ctype, number = card.number})
	end

	local cardsCount = #cards
	local lastCard = cards[cardsCount]
	local canShake = false
	if cardsCount >0 then

		if self.pointValueView then
			if self.isDealer == false then
				if self.pointValueView.isShake == true then
					canShake = true
					self.pointValueView:stop()
				end
				self.pointValueView:removeFromParent()
			end
		end

		self.pointValueView = PointValueView.new(valueCards, self.tableSide,self.isDealer):addTo(self)

		if self.tableSide and self.tableSide == PokerTableSide.right  then
			--發牌是BALCK JACK 右邊玩家的牌被擋住了
			if self.pointValueView.isBlackJack == true then
				self.pointValueView:setPosition(cc.p(-lastCard:getContentSize().width - self.CardOffset*cardsCount, posY +20))
			else
				self.pointValueView:setPosition(cc.p(-lastCard:getContentSize().width - self.CardOffset*cardsCount +20, posY +20))
			end
		else
			self.pointValueView:setPosition(cc.p(lastCard:getContentSize().width + self.CardOffset*cardsCount -15 , posY + 20))
		end
		self.pointValueView:setLocalZOrder(CardZOrder + cardsCount)
		
		if canShake == true then
			self.pointValueView:shake()
		end
	end
	
	cards = self.cardsRow2
	posY = 20
	valueCards = {}
	for k,card in pairs(cards) do
		card:stopAllActions()
		card:setVisible(true)
		if card.moveEndHandler then
			card.moveEndHandler()
		end
		if self.tableSide and self.tableSide == PokerTableSide.right then
			card:setLocalZOrder(CardZOrder*2 - k)
			card:setPosition(cc.p(-card:getContentSize().width / 2 - self.CardOffset * (k - 1), posY))
		else
			card:setPosition(cc.p(card:getContentSize().width / 2 + self.CardOffset * (k - 1), posY))
			card:setLocalZOrder(CardZOrder*2 + k)
		end
		table.insert(valueCards,{type = card.ctype, number = card.number})
	end
	
	cardsCount = #cards
	lastCard = cards[cardsCount]

	if cardsCount > 0 then
		if self.pointValueView2 then
			canShake = false
			if self.pointValueView2.isShake == true then
				canShake = true
				self.pointValueView2:stop()
			end
			self.pointValueView2:removeFromParent()
		end

		self.pointValueView2 = PointValueView.new(valueCards,self.tableSide,self.isDealer):addTo(self)
		if self.tableSide and self.tableSide == PokerTableSide.right  then
			if self.pointValueView2.isBlackJack == true then
				self.pointValueView2:setPosition(cc.p(-lastCard:getContentSize().width - self.CardOffset*cardsCount, posY +20))
			else
				self.pointValueView2:setPosition(cc.p(-lastCard:getContentSize().width - self.CardOffset*cardsCount + 20, posY + 20))
			end
		else
			self.pointValueView2:setPosition(cc.p(lastCard:getContentSize().width + self.CardOffset*cardsCount -15 ,posY + 20))
		end
		self.pointValueView2:setLocalZOrder(CardZOrder*2 + cardsCount)
		if canShake == true then
			self.pointValueView2:shake()
		end
	end]]
end

-- 设置在桌子哪一边
function NPPokerCardInfoView:setTableSide( side )
	self.tableSide = side
	self:resetCardPostion()
end


-- args :
-- {card :			牌的实例
--  isDeal :		是否播放发牌动画(可选)
--  delay :			延迟时间(可选)
--  moveEndHandler: 移动结束回调
--isMySelf:自己
-- }
-- 发一张牌 
function NPPokerCardInfoView:giveCard( args )
	if args.card then
		local cards = self.cards

		local posY = args.card:getContentSize().height/2

		-- add for blackjack 让自己牌永远在最上面
		if args.isMySelf then
		 	CardZOrder = 200
		end 

		local cardsCount = #cards
		if cardsCount > 0 then
			local lastCard = cards[cardsCount]
			if self.tableSide and self.tableSide == PokerTableSide.right  then
				--args.card:setLocalZOrder(lastCard:getLocalZOrder() - 1)
				args.card:setPosition(cc.p(-args.card:getContentSize().width / 2 - self.CardOffset*cardsCount, posY))
			else
				args.card:setPosition(cc.p(args.card:getContentSize().width / 2 + self.CardOffset*cardsCount, posY))
				--args.card:setLocalZOrder(CardZOrder+cardsCount)   
			end

			if args.isMySelf then
				args.card:setLocalZOrder(CardZOrder+cardsCount) 
			else
				args.card:setLocalZOrder(lastCard:getLocalZOrder() - 1) 
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
			local  pos = nil
			if args.isMySelf then
				pos = cc.p(args.card:getPositionX(),args.card:getPositionY())
			else
				if self.tableSide then 
					if self.tableSide == PokerTableSide.right then
						pos = cc.p(100 ,-80)
					end
					if self.tableSide == PokerTableSide.left then
						pos = cc.p(-100 ,-80)
					end
					if self.tableSide == PokerTableSide.middle then
						pos = cc.p( 170 ,0)
					end
				end
			end
			if args.moveEndHandler then
				args.card:dealCard{startPos = self.startPos, endPos = pos, delay = args.delay,moveEndHandler = args.moveEndHandler,isTurnOpen = args.isMySelf}
			else
				args.card:dealCard{startPos = self.startPos, endPos = pos, delay = args.delay,isTurnOpen = args.isMySelf}
			end
		else --恢复牌面
			if not args.isMySelf then
				if self.tableSide then 
					if self.tableSide == PokerTableSide.right then
						pos = cc.p(100 ,-80)
					end
					if self.tableSide == PokerTableSide.left then
						pos = cc.p(-100 ,-80)
					end
					if self.tableSide == PokerTableSide.middle then
						pos = cc.p( 170 ,0)
					end
				end
				args.card:setPosition(pos)
			end
		end
	end
end


--每次从手牌中移除一张
function NPPokerCardInfoView:removeOutCard(outCard)
	--从手牌中移除
 	for k ,v in pairs(self.cards) do
		if v:sameAs(outCard) then
			--print(string.format(" romove cardType %d cardValue %d",v.ctype,v.number))
			table.remove(self.cards, k)
			v:removeFromParent()
		end
	end
	self.selectCards = {}
	self.lastSelectCards = {}
	
	local distance = self.CardOffset/2
	--随着牌变少，牌往中靠扰
	self:setPosition(cc.p(self:getPositionX()+distance,self:getPositionY()))
	--重新排列牌的顺序
	for i ,card in pairs(self.cards) do
		card:setPosition(cc.p(card:getContentSize().width / 2 + self.CardOffset*(i-1), card:getPositionY()))
	end
end

function NPPokerCardInfoView:showOutCard( args )
	print("NPPokerCardInfoView:showOutCard")
	if args.card then
		local cards = self.outCards

		local posY = -80
		
		local CardOffset= self.CardOffset/2
		--让自己牌永远在最上面
		if args.isMySelf then
		 	CardZOrder = 200
		 	posY = 180
		end 

		local cardsCount = #cards
		if cardsCount > 0 then
			local lastCard = cards[cardsCount]
			if self.tableSide and self.tableSide == PokerTableSide.right  then
				args.card:setLocalZOrder(lastCard:getLocalZOrder() - 1)
				args.card:setPosition(cc.p(-args.card:getContentSize().width / 2 - CardOffset*cardsCount, posY))
			else
				args.card:setPosition(cc.p(args.card:getContentSize().width / 2 + CardOffset*cardsCount, posY))
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
		
		if args.isMySelf then
			--从手牌中移除
		 	for k ,v in pairs(self.cards) do
				if v:sameAs(args.card) then
					--print(string.format(" romove cardType %d cardValue %d",v.ctype,v.number))
					table.remove(self.cards, k)
					v:removeFromParent()
				end
			end
			self.selectCards = {}
			self.lastSelectCards = {}
			
			--随着牌变少，触摸区域也随着变小
			--self:setContentSize(cc.size(self:getContentSize().width - self.CardOffset,self:getContentSize().height))
			self:setPosition(cc.p(self:getPositionX()+self.CardOffset/2,self:getPositionY()))
			--重新排列牌的顺序
			for i ,card in pairs(self.cards) do
				card:setPosition(cc.p(card:getContentSize().width / 2 + self.CardOffset*(i-1), card:getPositionY()))
			end
		else
			--删除最后一张牌
			--table.remove(self.cards)
		end 
	end
end

--清除上一轮出的牌
function NPPokerCardInfoView:clearOutCards()
	print("NPPokerCardInfoView:clearOutCards")
	for k ,v in pairs(self.outCards) do
		v:removeFromParent()
		self.outCards[k] = nil
	end
end

-- 清除所有的牌
function NPPokerCardInfoView:clearAllCards()
	print("NPPokerCardInfoView:clearAllCards")
	for i = 1, #self.cards do
		self.cards[i]:removeFromParent()
		self.cards[i] = nil
	end
end

--一把结束
function NPPokerCardInfoView:roundOver()
	print("roundOver")
	for i = 1, #self.cards do
		self.cards[i]:removeFromParent()
		self.cards[i] = nil
	end
	self.cardsCount = 0
	--复位
	if self.isMySelf then
		self:setPosition(self.pos)
	else
		self.labelCardNumber:setVisible(false)
		self.labelCardNumber:setString(tonumber(0))	
	end	

	self.selectCards = {}
	self.lastSelectCards = {}
end


--設置牌間距 （for dealer）
function NPPokerCardInfoView:setCardOffset( offset )
	self.CardOffset = offset
end


function NPPokerCardInfoView:setGiveCardStartPos(pos)
	self.startPos = pos
end

function NPPokerCardInfoView:resetGiveCardStartPos()
	if self:getParent() then
		--计算屏幕中心的相对坐标
		local middlePosX = display.cx - self:getParent():getPositionX() - self:getPositionX()
		local middlePosY = display.cy - self:getParent():getPositionY() - self:getPositionY()
		--设置发牌起始坐标
		local cardStartPos = cc.p(middlePosX, middlePosY)
		self.startPos = cardStartPos
	end
end

function NPPokerCardInfoView:getTableSide( )
	return self.tableSide
end

function NPPokerCardInfoView:setCardCount(cnt)
	--print("setCardNumber"..cnt)
	self.cardsCount = cnt
	if  self.labelCardNumber then
		if  not self.labelCardNumber:isVisible() then
			self.labelCardNumber:setVisible(true)
			local pos = nil
			if self.tableSide then 
				if self.tableSide == PokerTableSide.right then
					pos = cc.p(92 ,-93)
				end
				if self.tableSide == PokerTableSide.left then
					pos = cc.p(-109 ,-93)
				end
				if self.tableSide == PokerTableSide.middle then
					pos = cc.p( 161 ,-13)
				end
			end
			self.labelCardNumber:setPosition(pos)
		end
		self.labelCardNumber:setString(tostring(self.cardsCount))
	end
end

function NPPokerCardInfoView:getCardCount()
	if self.isMySelf then
		return #self.cards
	else
		return self.cardsCount
	end
end

--获取选中牌
function NPPokerCardInfoView:getOutCards()
	local outCards = {}
	--遍历牌中所有站起的牌
	for k , card in pairs(self.cards) do
		if card:getStatus() == 1 then
			table.insert(outCards,{ctype = card.ctype, number = card.number})
		end
	end
	return outCards
end

--获取当前剩余手牌
function NPPokerCardInfoView:getHandCards()
	local handCards = {}
	--遍历所有牌
	for k , card in pairs(self.cards) do
		table.insert(handCards,{ctype = card.ctype, number = card.number})
	end
	dump(handCards)
	return handCards
end

--获取当前牌组中最小的牌
function NPPokerCardInfoView:getMinCard()
	return self.cards[#self.cards]
end

--获取当前牌组中最大的牌
function NPPokerCardInfoView:getMaxCard()
	return self.cards[1]
end

--判断该牌是不是牌组最大的
function NPPokerCardInfoView:checkCardIsBiggest(curCard)
	for k ,v in pairs(self.cards) do 
		local tempNumber = v.number
		local tempNumber2= curCard.number
		if tempNumber == 1 or tempNumber == 2 then
			tempNumber = tempNumber + 9
		end

		if tempNumber2 == 1 or tempNumber2 == 2 then
			tempNumber2 = tempNumber2 + 9
		end

		if tempNumber > tempNumber2 then
			return false
		else
			if tempNumber ==tempNumber2 then
				if v.ctype > curCard.ctype then
					return false
				end
			end
		end
	end
	return true
end



function NPPokerCardInfoView:showPromptCard(cards)
	for k , card in pairs(self.cards) do
		if card:getStatus() == 1 then
			card:setSelect()
		end
	end
	--根据提示牌的信息，找到对应的牌
	for k ,v in pairs(self.cards) do
		for m,prompCard in pairs(cards) do
			if v.ctype == prompCard.ctype and v.number == prompCard.number then
				v:setSelect()
			end 
		end
	end
end

--不能出相关提示
function NPPokerCardInfoView:showCanotOutCardTip(tipType)
	print("showCanotOutCardTip"..tipType)
	local distance = (9-#self.cards)*self.CardOffset/2
	--牌数没有变动，则位置不需改变
	if not self.distance then
		self.distance = distance
		self.tipWindow:setPosition(cc.p(self.tipWindow:getPositionX()-self.distance,self.tipWindow:getPositionY()))
	else 
		if self.distance ~= distance then
			local interval = distance - self.distance
			self.tipWindow:setPosition(cc.p(self.tipWindow:getPositionX()- interval,self.tipWindow:getPositionY()))
			self.distance = distance
		end
	end
	
	self.tipWindow:stopAllActions()
	if tipType == tipMsgType.CanotTakeTwo then
		self.tipWindow:loadTexture("ys9zhang/u_game_text_prompt2.png",0)
	elseif tipType == tipMsgType.MustBeTakeThree then
		self.tipWindow:loadTexture("ys9zhang/u_game_text_prompt5.png",0)
	elseif tipType == tipMsgType.NotCardBigger then
		self.tipWindow:loadTexture("ys9zhang/u_game_text_prompt7.png",0)
	elseif tipType == tipMsgType.DownPlayerIsAlarm then
		self.tipWindow:loadTexture("ys9zhang/u_game_text_prompt1.png",0)
	end
	self.tipWindow:setVisible(true)

	local actionArray = {}
	self.tipWindow:setScale(0)
	local _scale = cc.ScaleTo:create(0.3, 1)
	table.insert(actionArray,_scale)
	--1.5秒后自动隐藏
	local _dt = cc.DelayTime:create(1.5)
	table.insert(actionArray,_dt)
	local _scaleSmall = cc.ScaleTo:create(0.3, 0)
	table.insert(actionArray,_scaleSmall)
	local _callHide = cc.CallFunc:create(handler(self, self.hideTip))
	table.insert(actionArray,_callHide)
	local _seq = cc.Sequence:create(actionArray)
	self.tipWindow:runAction(_seq)
end

function NPPokerCardInfoView:hideTip()
	self.tipWindow:setVisible(false)
end

function NPPokerCardInfoView:tuoGuanPro(isTuoGuan)
	self.isTuoGuan = isTuoGuan
	if not self.isTuoGuan  then
		for k ,v in pairs(self.cards) do
			v:removeGray()
		end
	else
		for k ,v in pairs(self.cards) do
			v:addGray()
		end
	end
end

--添加点击结点
function NPPokerCardInfoView:addClickNode()
	for k ,v in pairs(self.cards) do
		v:addTouchListener()
	end
end

return NPPokerCardInfoView