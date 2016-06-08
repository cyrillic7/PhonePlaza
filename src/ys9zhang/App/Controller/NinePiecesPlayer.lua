CURRENT_MODULE_NAME = ...

local NinePiecesPlayer = class("NinePiecesPlayer")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

NinePiecesPlayer.MaxCardCount = 9
-- 牌组view 
local CardLineView = import("..View.NPPokerCardInfoView")
--出牌牌组组view
local OutCardLineView = import("..View.NPOutCardInfoView")
-- 牌
local PokerCard = require("common.Widget.PokerCard")

local outCardScale = 0.57
--結果類型
local resultType ={
	win = "win",
	lose ="lose" ,
}

--9张所有牌型 
local CardType = 
{
	ValidType       = 0,--不能出的牌型  
	SingleCard 		= 1,
	Onepair 		= 2,
	ThreeCard	  	= 3,
	Straight   		= 4,--顺子
	Flush      		= 5,--同花
	FullHouse  		= 6,--葫芦
	FourOfKind 		= 7,--四皇后
	StraightFlush 	= 8,--同花顺
	Twopair         = 9,
	    
}

-- args = {
-- 	  statusChangedHandler : 状态发生变化时的句柄
-- 	  cardGroupStatusChangedHandler : 牌组状态发生的句柄
--    workflow = workflow對象
-- }
function NinePiecesPlayer:ctor(args)
	
	-- 外部回调处理
	self.statusChangedHandler = args.statusChangedHandler
	self.cardGroupStatusChangedHandler = args.cardGroupStatusChangedHandler
	self.workflow = args.workflow
	-- 加入状态机
	self:addStateMachine()

	-- 牌组，正常的话1组，
	self:initCardGroup()

	-- 网络命令发送
	self.command = import("..Command.NinePiecesCommand", CURRENT_MODULE_NAME).new(self.workflow.delegate:getCurClientKernel())

	-- 为了方便测试，player分两种模式，操作界面和不操作界面
	-- 默认操作界面
	self.operatingUI = true

	--玩家手中的牌记数器
	self.handCardCount = 0


	self.isGameStart = false 

	--超时计数
	self.countDownCount = 0

	--上一手牌
	self.lastOutCards = {}

	--不能过牌标记
	self.canNotPass = false

	self.isTuoGuan = false
end

function NinePiecesPlayer:initCardGroup()
	-- 具体牌的信息
	self.cardGroup = {}
	
	self.isGameStart = false
end

function NinePiecesPlayer:addStateMachine()
	self.fsm = {}
	cc.GameObject.extend(self.fsm):addComponent("components.behavior.StateMachine"):exportMethods()

	self.fsm:setupState({
		initial = "idle",
		events = {
			-- 轮到玩家操作 -> 等待发牌状态
			{name = "decide", from = "idle", to = "deciding"},

			-- 决定完成，进入空闲状态
			{name = "end", from = "*", to = "idle"},
		},

		callbacks = {

			onchangestate = function(event)
				if event and event.from ~= "none" then
					self.statusChangedHandler(self, event)
					if event.name == "end" then
						self.playerView:stop()
					elseif event.name == "decide" then
						if self.playerData.dwUserID == self.workflow:getMyUserID() then
							--检查所选中的牌型是否可出
							self:checkCanOutCardHandler(self.playerView:getCardView():getOutCards())
						end
					end
				end
			end,

			-- 进入等待决定
			onenterdeciding = function( event )
				-- 操作界面，开始方形的倒计时条
				print(string.format("uid = %d 玩家进入等待决定状态",self.playerData.dwUserID))
				if self.operatingUI then
					--为不在倒记时的玩家，加上倒计时，已在进行中，不重新较正
					self.playerView:stop()
					self.playerView:start()
					
				end
			end,

			-- 离开等待决定
			leavedeciding = function ( event )
				print(string.format("uid = %d 玩家进入空闲状态",self.playerData.dwUserID))
				-- 停止倒计时条
				if self.operatingUI then
					print("离开等待决定")
					self.playerView:stop()
				end
			end
		}
	})
end

function NinePiecesPlayer:countdown( dt )
	print("NinePiecesPlayer:countdown")
	if self.operatingUI then
		self.playerView:countdown(dt)
	end
end


-- 设置player数据	
function NinePiecesPlayer:setPlayerData( player )
	self.playerData = player
end

--获取玩家数据
function NinePiecesPlayer:getPlayerData()
	return self.playerData
end

-- 设置玩家的视图
function NinePiecesPlayer:setPlayerView(playerView,isMySelf)
	self.playerView = playerView
	self.playerView.delegate = self
	if self.playerView then
		local args = {}
		args.isMySelf = isMySelf
		if isMySelf then
			args.checkCanOutCardHandler = handler(self, self.checkCanOutCardHandler)
		end
        self.playerView:addCardInfoView(CardLineView.new(args))
		self.playerView:getCardView():resetGiveCardStartPos()
		--添加出牌视图
		self.playerView:addOutCardView(OutCardLineView.new(args))
	end
end

--是否能出牌
function NinePiecesPlayer:checkCanOutCardHandler(cards)
	local  isCanPass = false --是否可过牌
	local  isCanPlay = false
	--不是自已操作的时候
	if self.fsm:getState() ~= "deciding" then
		return false
	end
	dump(cards)
	--分析选中的牌型 
	local curType,MaxCardValue = self:analyzeCardType(cards)
	print("curType"..curType)
	print("self.lastOutCards"..#self.lastOutCards)
	if #self.lastOutCards >0 then
		local lastCardType,outMaxCardValue = self:analyzeCardType(self.lastOutCards)
		print("lastCardType"..lastCardType)
		isCanPass = true
		if curType ~= CardType.ValidType then
			if curType == lastCardType and curType <= CardType.ThreeCard then
				if curType == CardType.SingleCard  then
					isCanPlay = self:checkIsBigger(cards,curType,false)
				elseif curType == CardType.Onepair  then
					isCanPlay = self:checkIsBigger(cards,curType,false)
				elseif curType == CardType.ThreeCard  then
					isCanPlay = self:checkIsBigger(cards,curType,false)
					--[[if MaxCardValue > outMaxCardValue then
						isCanPlay = true
					else
						isCanPlay = false					
					end]]
				end
			--5张单独比
			elseif  lastCardType > CardType.ThreeCard  and curType > CardType.ThreeCard then
				--牌型一样比大小
				if  curType == lastCardType then
					if curType == CardType.FourOfKind or curType == CardType.FullHouse then
						if MaxCardValue > outMaxCardValue then
							isCanPlay = true
						else
							isCanPlay = false					
						end
					else 
						isCanPlay = self:checkIsBigger(cards,curType,false)
					end
				elseif curType > lastCardType then
					isCanPlay = true
				end
			else --少于3 大于0 不相等 的 情况下
				isCanPlay = false
			end
		end
	else
		if  curType ~= CardType.ValidType then
			isCanPlay = true
		end
	end
	
	if isCanPlay then
		print("isCanPlay true")
	else
		print("isCanPlay false")
	end
	--local args = {isCanPass = isCanPass,isCanPlay = isCanPlay }
	local args = {isCanPlay = isCanPlay }
	--修改出牌按钮状态
	self.workflow:modifyOprateStatus(args)
end

--牌型是否带有2
function NinePiecesPlayer:cardshasCardTwo(cards)
	for k , v in pairs(cards) do
		if v.number == 2 then
			return true
		end
	end
	return false
end
--牌型是否带有片3
function NinePiecesPlayer:cardshasDiamond3(cards)
	for k , v in pairs(cards) do
		if v.ctype == 0 and v.number == 3 then
			return true
		end
	end
	return false
end

--比较牌型的值
function NinePiecesPlayer:checkIsBigger(cards,curType ,isPrompt)
	local isBigger = false
	--从小到大排序
	table.sort( cards, handler(self,self.cardCompare))
	table.sort( self.lastOutCards, handler(self,self.cardCompare))
	local cnt = #cards
	if curType == CardType.SingleCard or curType == CardType.Onepair or curType == CardType.Straight or curType == CardType.ThreeCard then
		--取最后一张牌比大小，大小相同比花色 A 2特殊处理
		local number1 = cards[cnt].number
		local number2 = self.lastOutCards[cnt].number
		if curType ~= CardType.Straight then
			if cards[cnt].number == 1 or cards[cnt].number == 2 then
				number1 = cards[cnt].number + 9
			end

			if self.lastOutCards[cnt].number == 1 or self.lastOutCards[cnt].number == 2 then
				number2 = self.lastOutCards[cnt].number + 9
			end
		end

		if number1 > number2 then
			isBigger = true
		elseif number1 == number2 then
			if cards[cnt].ctype > self.lastOutCards[cnt].ctype then
				isBigger = true
			end
		end
	elseif curType == CardType.Flush or curType == CardType.StraightFlush then
		if cards[1].ctype > self.lastOutCards[1].ctype then
			isBigger = true
		end
	end

	--带2的情况下，且是首次出牌，则不能提示
	if isPrompt then
		local curCardCnt = self.playerView:getCardView():getCardCount() 
		if self:cardshasCardTwo(cards) and curCardCnt == 9 then
			isBigger = false
		end
	end

	return isBigger
end

--获取玩家的视图
function NinePiecesPlayer:getPlayerView()
	return self.playerView
end

-- 发牌
-- args :{
-- 	index : 牌的序列数，具体对应关系看PokerCard
--  isRow2 : 是否是第二行的牌
--  isDeal :是否要播放動畫
--  delay  :延遲時間
--  isGameStart :是否是游戏刚开始的发牌（可选）
-- }
function NinePiecesPlayer:giveCard(args)
	local cardType, cardNumber = GameUtil:GetCardForPc(args.index)
	-- 界面上加入一张牌
	if self.playerView then
		if args.isGameStart then
			self.isGameStart = args.isGameStart
		end
		local card = PokerCard.new{ctype = cardType, number = cardNumber ,clickHandler = handler(self, self.clickCardHandler)}
		card:setScale(0.9)
		self.playerView:getCardView():giveCard{card = card, isDeal = args.isDeal, delay = args.delay, moveEndHandler = handler(self, self.cardMoveEnd),isMySelf = true}
	end
	
	--保存牌的信息
	table.insert(self.cardGroup, {type = cardType, number = cardNumber})
	

	--播放发牌音效
	--SoundManager:playMusicEffect("Blackjack/Audios/deal.mp3", false, false)
end


function NinePiecesPlayer:clickCardHandler(card, touchType)
	self.playerView:getCardView():onClickCard(card,touchType)
end
-- 发一张盖牌
function NinePiecesPlayer:giveCoverCard(args)
	if self.playerView then
		if args.isGameStart then
			self.isGameStart = args.isGameStart
		end
		local cardType, cardNumber = GameUtil:GetCardForPc(tonumber(3))
		local card = PokerCard.new{ctype = cardType, number = cardNumber}
		card:cover()
		self.playerView:getCardView():giveCard{card = card, isDeal = args.isDeal, delay = args.delay,moveEndHandler = handler(self, self.cardMoveEnd),isMySelf = false}
		--播放发牌音效
		--SoundManager:playMusicEffect("Texas/Audios/deal.mp3", false, false)
	end
end

--牌移动结束处理事件
function NinePiecesPlayer:cardMoveEnd(card)
	--开始发的牌
	if self.isGameStart == true then
		self.handCardCount = self.handCardCount + 1
		--九张牌都发到手
		if self.handCardCount == NinePiecesPlayer.MaxCardCount then
			print("当前玩家 chair id = "..self.playerData.wChairID)
			print("首次出牌玩家chair id = "..self.workflow:getOperatePlayeId())
			--自已第一个出牌
			self.playerView:setCountDownTimeInterval(20)
			--只对自已有用
			if self.workflow:getOperatePlayeId() == self.workflow:getMyChairID() then
				self.canNotPass = true
			end
			self:handleNextPlayer{nextPlayerId = tonumber(self.workflow:getOperatePlayeId()),autoPass = 0}
			
			--发完牌之后才能选牌
			if self.playerData.dwUserID == self.workflow:getMyUserID() then
				self.playerView:getCardView():addClickNode()
			end
		end
		--设置手牌数
		self.playerView:getCardView():setCardCount(self.handCardCount)
		
	end
end


--收到游戲結束消息0.3 秒清空手牌
function NinePiecesPlayer:clearCards()
	self.playerView:getCardView():clearAllCards()
	-- 重置玩家的牌
	self:initCardGroup()
end


-- start开始后的一般性消息处理
function NinePiecesPlayer:handleMessage(event)
	if tonumber(event.para.playerId) == tonumber(self.playerData.playerId) then

	end
	
	--先切换状态
	self.fsm:doEvent("end")
	
	-- 处理下一个操作的玩家
	self:handleNextPlayer{nextPlayerId = tonumber(event.para.nextPlayerId)}
end

-- args = {
-- 		cardGroupStatus : 组牌的状况, number类型
--      cardGroupIndex : 牌组的序列号, number类型
--      showBlueBtn    : 显示黄色按扭标记
-- }
function NinePiecesPlayer:updateCardGroupStatus(args)
	-- 保存状态
	--[[self.cardGroupStatus[args.cardGroupIndex] = args.cardGroupStatus

	if args.cardGroupStatus == CardGroupStatus.Blackjack then
	elseif args.cardGroupStatus == CardGroupStatus.CanHit then

	elseif args.cardGroupStatus == CardGroupStatus.CanSplit then

	elseif args.cardGroupStatus == CardGroupStatus.Bust then

	end

	self.cardGroupStatusChangedHandler(self, args.cardGroupIndex, args.cardGroupStatus,args.showBlueBtn)

	self:printCurrentCards()]]
end

-- args = {
		-- nextPlayerId : 下一个操作玩家的Id
		-- isGameStart  :  是否是游戏开始消息
		-- nextPlayerCardGroupIndex : 下一个操作玩家的状态
		-- autoPass :是否自动过牌
-- }
function NinePiecesPlayer:handleNextPlayer(args)
	--是否是自己操作
	print(string.format("handleNextPlayer %d",args.nextPlayerId))
	print(string.format("self.playerData.wChairID %d",self.playerData.wChairID))
	self.isMyOperate = false
	if args.nextPlayerId == tonumber(self.playerData.wChairID) then
		--计录下当前玩家操作的牌组序号
		if self.fsm:getState() == "deciding" then
			print("[9zhang], [丢包 引起状态机状态不对，客户端自行调整]")
			self.fsm:doEvent("end")
		end

		print("handleNextPlayer decide autoPass="..args.autoPass)
		--self.fsm:doEvent("decide",args.autoPass)
		--清除上一轮的出牌
		self.playerView:getOutCardView():clearOutCards()

		self.isMyOperate = true
		--下个玩家是自已的话
		if self.playerData.wChairID == self.workflow:getMyChairID() then
			if args.autoPass ~=0  then
				print("args.autoPass"..args.autoPass)
				--1封牌 2大主上
				if args.autoPass == 1 then
					self.playerView:getOutCardView():showPromptImage("feipai")
				else
					self.playerView:getOutCardView():showPromptImage("dazhushang")
				end
				--2秒后自动出牌
				scheduler.performWithDelayGlobal(handler(self, self.autoPassCard),2)
				--to do 显示相应的提示，大主上，封牌
				self.autoPass = args.autoPass
			else
				--检查所选中的牌型是否可出
				--self:checkCanOutCardHandler(self.playerView:getCardView():getOutCards())
				--找出提示牌型
				self:prePrompt()
				--两次被动托管
				if self.isTuoGuan == true then
					--2秒后出牌，更逼真一点
					scheduler.performWithDelayGlobal(handler(self, self.tuoGuanPro),2)
					--self:tuoGuanPro()
				else
					--下家报警
					if self:downplayerIsWaring() then
						--上家出单，下家报警且有比上家大的牌，不能不出
						if #self.promptCard >0 and #self.lastOutCards == 1 then
							--提示请顶大
							self.playerView:getCardView():showCanotOutCardTip(4)
							self.canNotPass = true--不能过牌	
						end
					end
				end
			end
		end
		--进入操作倒计时状态
		self.fsm:doEvent("decide",args.autoPass)
	end
end

--自动过牌
function NinePiecesPlayer:autoPassCard()
	print("autoPassCard")
	self.fsm:doEvent("end")
	self.playerView:getOutCardView():showPromptImage("pass")
	self.command:pass(1)
	if self.autoPass and self.autoPass ~=0 then
		self.autoPass = 0
	end
	--清空以前算出的提示牌
	self.promptCard = {}
end

--主动过牌
function NinePiecesPlayer:pass()
	--超时计数置0
	self.countDownCount = 0
	self.fsm:doEvent("end")
	self.command:pass(1)
	self.playerView:getOutCardView():showPromptImage("pass")
end

function NinePiecesPlayer:prompt()
	if self.autoPass and self.autoPass ~=0 then
		print("self.autoPass"..self.autoPass)
		return
	end

	if not self.promptIndex or self.promptIndex >= #self.promptCard then
		self.promptIndex = 1
	else
		self.promptIndex = self.promptIndex+1
	end

	print("self.promptCard"..#self.promptCard)
	if #self.promptCard > 0 then
		dump(self.promptCard)
		local curPrompt = self.promptCard[self.promptIndex]
		if curPrompt then
			self.playerView:getCardView():showPromptCard(curPrompt)

			local args = {isCanPlay = true }
			--修改出牌按钮状态
			self.workflow:modifyOprateStatus(args)
		end	
	else
		--发送过牌消息
		self:pass()
		--提示没有大的牌
		self.playerView:getCardView():showCanotOutCardTip(3)
	end
end

--找到同一张牌的位置
--self.allTypeCards["Straight"] = {{1,1},{2},{3,3},{4,4,4}}
function NinePiecesPlayer:getLastCardPos(nextCard)
	for k ,v in pairs(self.allTypeCards["Straight"]) do
		if #v > 0 then
			for i = 1,#v do
				local curCard  = v[i]
				if curCard.number == nextCard.number then
					return k 
				end
			end
		end
	end
	return nil
end

--提示
function NinePiecesPlayer:prePrompt()
	--压牌提示
	local lastCardType  = nil
	local outMaxCardValue = nil 
	--for test
	--{{ctype=1,number =1},{ctype=1,number =2},{ctype=3,number =3},{ctype=2,number =4},{ctype=2,number =5}}
	--self.lastOutCards = {{ctype=0,number =3},{ctype=1,number =4},{ctype=2,number =5},{ctype=2,number =6},{ctype=2,number =7}}
	--self.lastOutCards = {{ctype=0,number =3},{ctype=2,number =3},{ctype=3,number =3},{ctype=1,number =5},{ctype=2,number =5}}
	--self.lastOutCards = {{ctype=1,number =2}}
	if #self.lastOutCards > 0 then
		--上家牌型及最大值
		lastCardType,outMaxCardValue = self:analyzeCardType(self.lastOutCards)
	end

	--提示牌数组
	self.promptCard = {}
	self.promptIndex = 0
	--手牌
	--for test
	local leftHandCards = self.playerView:getCardView():getHandCards()
	--leftHandCards = {{ctype=0,number =1},{ctype=0,number =2},{ctype=0,number =3},
	--{ctype=0,number =4},{ctype=3,number =5},{ctype=1,number =6},
	--{ctype=1,number =7},{ctype=1,number =8},{ctype=0,number =9}}

	--leftHandCards = {{ctype=0,number =5},{ctype=1,number =5},{ctype=2,number =5},
	--{ctype=3,number =5},{ctype=1,number =6},{ctype=2,number =6},
	--{ctype=0,number =7},{ctype=2,number =7},{ctype=3,number =7}}

	--leftHandCards = {{ctype=0,number =8},{ctype=1,number =8},{ctype=2,number =8},
	--{ctype=3,number =8},{ctype=0,number =7},{ctype=1,number =7},
	--{ctype=2,number =7}}

	--先从小到大排序 少于三张牌型下A,2 为大
	table.sort( leftHandCards, handler(self, self.cardCompare2))
	--计算出牌值相同的张数
	self.allCard = {} 
	for k ,v in pairs(leftHandCards) do
		self:calCardCount(v)
	end
	--所有牌型
	self.allTypeCards = {}

	--分别存放一张，到四级的牌
	self.allTypeCards[1] = {}
	self.allTypeCards[2] = {}
	self.allTypeCards[3] = {}
	self.allTypeCards[CardType.Twopair] = {}

	for i = 1 ,#self.allCard do
		if #self.allCard[i] == 1 then
			--{{1},{2},{3},...}
			table.insert(self.allTypeCards[1],self.allCard[i])
		elseif #self.allCard[i] == 2 then
			--{{2,2},{3,3}}
			table.insert(self.allTypeCards[2],self.allCard[i])
		elseif #self.allCard[i] == 3 then --3张
			--{{2,2,2},{3,3,3}..}
			table.insert(self.allTypeCards[3],self.allCard[i])
		elseif #self.allCard[i] == 4 then --4张
			--{{2,2,2,2},{3,3,3,3}..}
			table.insert(self.allTypeCards[CardType.Twopair],self.allCard[i])
		end
	end
	print("self.allTypeCards[2]")
	dump(self.allTypeCards[2])

	--压牌
	if lastCardType then
		if lastCardType < CardType.Straight then
			for k ,v in pairs(self.allTypeCards) do
				if k == lastCardType then
					for i =1,#v do
						local curCards = v[i]
						local isBigger = self:checkIsBigger(curCards, lastCardType,true)
						if isBigger then
							table.insert(self.promptCard,curCards)
						end
					end
				else
					--不同的牌型 取出比他大的一组就可以了
					if k > lastCardType then
						--取第一个元素
						if #v > 0 then
							for m, curCards in pairs(v) do
								--单张特殊处理
								if lastCardType == CardType.SingleCard then
									for l,single in pairs(curCards) do
										local isBigger = self:checkIsBigger({single}, lastCardType,true)
										if isBigger then
											table.insert(self.promptCard,{single})
											break
										end
									end
								else
									local temp = {}
									for j=1,lastCardType do
										table.insert(temp,curCards[j])
									end
									local isBigger = self:checkIsBigger(temp, lastCardType,true)
									if isBigger then
										table.insert(self.promptCard,temp)
										break
									end
								end
							end
						end
					end
				end
			end
		end
	else
		--出牌提示
		for k ,v in pairs(self.allTypeCards) do
			if #v >0 and #v[1] ~= 4 then
				table.insert(self.promptCard,v[1])
			end
		end
	end

	local  isCheckFiveCard = true
	--压牌但对家不是5张的牌型
	if lastCardType and lastCardType < CardType.Straight then
		print("isCheckFiveCard is false")
		isCheckFiveCard = false
	end
	--手牌少于5张
	if #leftHandCards < 5 then
		isCheckFiveCard = false
	end

	--查找5张的牌型
	if isCheckFiveCard == true then
		--从小到大排序
		table.sort(leftHandCards, handler(self, self.cardCompare))
		dump(leftHandCards)
		if  not self.allTypeCards["Straight"] then
			self.allTypeCards["Straight"] = {}
		end
		--默认索引在第一个位置
		self.index = 1
		--找顺子 
		local difLen = 1
		--to do 有特殊情况中间有连着，后面的不连着
		while self.index ~= #leftHandCards do
			--少于5张情况下清空
			if #self.allTypeCards["Straight"] < 5 then
				self.allTypeCards["Straight"] = {}
			end

			for i= self.index,#leftHandCards do
				self.index = i--记录当前位置
				local curCard = leftHandCards[i]
				local index = self:getLastCardPos(curCard)
				if index  then
					table.insert(self.allTypeCards["Straight"][index],curCard)
				else
					table.insert(self.allTypeCards["Straight"],{curCard})
				end
				if i < #leftHandCards then
					local nextCard = leftHandCards[i+1]
					if nextCard.number == curCard.number+1 then
						difLen = difLen + 1
					elseif nextCard.number > curCard.number+1 then
						difLen = 1
						self.index = self.index + 1
						break
					end
				end
				
			end
		end

		--for k ,v in pairs(self.allTypeCards["Straight"]) do
		--	dump(v)
		--end

		self.allTypeCards["StraightArray"] = {}
		--找出所有的顺子
		print("difLen --"..difLen)
		if #self.allTypeCards["Straight"] >= 5 then
			self:findAllStraight()
		end

		--元数为0 则没有顺子
		if #self.allTypeCards["StraightArray"] == 0 then
			
		else
			self.allTypeCards[CardType.Straight] = {}
			for k,straight in pairs(self.allTypeCards["StraightArray"]) do
				--顺子中区分顺子及同花顺
				local cardCnt = #straight
				for i=1,cardCnt do
					if cardCnt - i  >= 4 then
						local  testCards = {}
						for k = i,i+4 do
							table.insert(testCards,straight[k])
						end
						local curType,MaxCardValue  = self:checkIsStraightOrFlush(testCards)
						if curType == CardType.Straight then
							table.insert(self.allTypeCards[CardType.Straight],testCards)
						elseif curType == CardType.StraightFlush then
							if not self.allTypeCards[CardType.StraightFlush] then
								self.allTypeCards[CardType.StraightFlush] = {}
							end
							table.insert(self.allTypeCards[CardType.StraightFlush],testCards)
						end
					end
				end
			end
		end

		--dump(self.allTypeCards[CardType.Straight])
		--找同花
		self.allTypeCards["Flush"] = {}
		for i= 1,#leftHandCards do
			local firstCard = leftHandCards[i]
			if not self.allTypeCards["Flush"][firstCard.ctype] then
				self.allTypeCards["Flush"][firstCard.ctype] = {}
			end
			local  pos = table.indexof(self.allTypeCards["Flush"][firstCard.ctype],firstCard)
			if not pos then
				table.insert(self.allTypeCards["Flush"][firstCard.ctype],firstCard)
				for k = i+1,#leftHandCards do
					local secondCard = leftHandCards[k]
					--自已不跟自已比
					if firstCard.ctype == secondCard.ctype  then
						table.insert(self.allTypeCards["Flush"][firstCard.ctype],secondCard)
					end
				end
			end
		end
		--取出所有同花
		self.allTypeCards[CardType.Flush] = {}
		for k , v in pairs(self.allTypeCards["Flush"]) do
			--少于5个元素，移除
			if type(v) == "table"  then
				if #v < 5 then
					table.remove(self.allTypeCards["Flush"],k)
				elseif #v == 5 then
					--排除不是同花顺的情况
					local cardType ,cardValue = self:checkIsStraightOrFlush(v)
					if cardType ~= CardType.StraightFlush then
						table.insert(self.allTypeCards[CardType.Flush],v)
					end
				elseif #v > 5 then
					local cardCnt = #v 
					for i =1 ,cardCnt do 
						if cardCnt - i  >= 4 then
							local  testCards = {}
							for m = i,i+4 do
								table.insert(testCards,v[m])
							end
							local curType,MaxCardValue  = self:checkIsStraightOrFlush(testCards)
							if curType ~= CardType.StraightFlush then
								table.insert(self.allTypeCards[CardType.Flush],testCards)
							end
						end
					end
				end
			end
		end
		
		--找3带2 
		self.allTypeCards[CardType.FullHouse] = {}
		--找出所有3带2的情况
		self:findAllThreeTakeTwo()
		--4带1
		if self.allTypeCards[CardType.Twopair] and #self.allTypeCards[CardType.Twopair] >0 then
			self.allTypeCards[CardType.FourOfKind] = {}
			for k ,v in pairs(self.allTypeCards[CardType.Twopair]) do
				self:findAllFourTakeOne(v)
			end
		end

		self.allTypeCards["Flush"] = nil
		self.allTypeCards["StraightArray"] = nil
		self.allTypeCards["Straight"] = nil
		self.allTypeCards[CardType.Twopair] = nil
		for k ,v in pairs(self.allTypeCards) do
			dump(v)
		end
		--找5张相应提示牌
		self:findFivePromptCards(lastCardType,outMaxCardValue)
	end

	self.allTypeCards[CardType.Twopair] = nil

	local curHandCardCount = self.playerView:getCardView():getCardCount()
	print("curHandCardCount=="..curHandCardCount)
	dump(self.promptCard)
	print("self.workflow.mustHave3User=="..self.workflow.mustHave3User)
	--从提示牌中，排除首发带2的情况
	local removeIndex = {}
	for k ,v in pairs(self.promptCard) do 
		if self:cardshasCardTwo(v) and curHandCardCount == 9 then
			local  index = table.indexof(removeIndex,k)
			if not index then
				table.insert(removeIndex,k)
			end
		end
		--是自已
		if self.playerData.wChairID == self.workflow:getMyChairID() and self.playerData.wChairID == self.workflow.mustHave3User then
			--首次出牌只提示带片3的牌型
			if not self:cardshasDiamond3(v) then
				local  index = table.indexof(removeIndex,k)
				if not index then
					table.insert(removeIndex,k)
				end
			end
		end
	end

	dump(removeIndex,1)

	if #removeIndex > 0 then
		for i = #removeIndex,1,-1 do
			table.remove(self.promptCard,removeIndex[i])
		end
	end
end

--判断该组牌能不能出
function NinePiecesPlayer:CheckCanOut(cards)
	local curHandCardCount = self.playerView:getCardView():getCardCount()
	--首张不能带2
	if self:cardshasCardTwo(cards) and curHandCardCount == 9 then
		return false
	end
	--首张必须带片3
	if self.playerData.wChairID == self.workflow.mustHave3User then
		--首次出牌只提示带片3的牌型
		if not self:cardshasDiamond3(cards) then
			return false
		end
	end
	return true
end

--找出5张提示牌
function NinePiecesPlayer:findFivePromptCards(lastCardType,outMaxCardValue)
	if not lastCardType then
		--自已出牌
		for k ,v in pairs(self.allTypeCards) do
			--只考虑5个的牌型 每个牌型 取一个能出的
			if k >= CardType.Straight  then
				for i=1,#v do 
					if self:CheckCanOut(v[i]) then
						table.insert(self.promptCard,v[i])
						break
					end
				end
				
			end
		end
	else
		--压牌
		for k ,v in pairs(self.allTypeCards) do 
			--只考虑5个的牌型
			if k >= CardType.Straight then
				if lastCardType == k then
					for i =1 ,#v do
						local curCards = v[i]
						if lastCardType == CardType.FullHouse or lastCardType == CardType.FourOfKind then
							local curCardType,curMaxValue = self:analyzeCardType(curCards,lastCardType)
							if curMaxValue > outMaxCardValue then
								table.insert(self.promptCard,curCards)
							end
						else
							local isBigger = self:checkIsBigger(curCards, lastCardType,true)
							if isBigger then
								table.insert(self.promptCard,curCards)
							end
						end
					end
				else
					--不同类型取一个能出的
					if k > lastCardType  then
						for i=1,#v do
							if self:CheckCanOut(v[i]) then
								table.insert(self.promptCard,v[i])
								break
							end
						end
					end
				end
			end
		end
	end
end

--找出所有三带2的情况
function NinePiecesPlayer:findAllThreeTakeTwo()
	--手牌有三张的情况
	if #self.allTypeCards[3] > 0 then
		for k ,v in pairs(self.allTypeCards[3]) do
			--有两张
			if #self.allTypeCards[2] > 0 then
				for i= 1,#self.allTypeCards[2] do
					local tempThree = {}
					for m,n in pairs(v) do
						table.insert(tempThree,n)
					end
					local towCards = self.allTypeCards[2][i]
					table.insert(tempThree,towCards[1])
					table.insert(tempThree,towCards[2])
					table.insert(self.allTypeCards[CardType.FullHouse],tempThree)
				end
			end
			
			--有三张 三张里取两张 自已除外
			if #self.allTypeCards[3] > 0 then
				for j = 1, #self.allTypeCards[3] do
					local tempThree = {}
					for m,n in pairs(v) do
						table.insert(tempThree,n)
					end
					local  curCard = self.allTypeCards[3][j]
					if curCard[1].number ~= v[1].number then
						table.insert(tempThree,curCard[1])
						table.insert(tempThree,curCard[2])
						table.insert(self.allTypeCards[CardType.FullHouse],tempThree)
					end
				end
			end

			--有四张里面取两
			if #self.allTypeCards[CardType.Twopair] > 0 then
				for m = 1, #self.allTypeCards[CardType.Twopair] do
					local tempThree = {}
					for m,n in pairs(v) do
						table.insert(tempThree,n)
					end
					local  curCard = self.allTypeCards[CardType.Twopair][m]
					table.insert(tempThree,curCard[1])
					table.insert(tempThree,curCard[2])
					table.insert(self.allTypeCards[CardType.FullHouse],tempThree)
				end
			end
		end
	end

	----手牌有四张的情况
	if #self.allTypeCards[CardType.Twopair] > 0 then
		for k ,v in pairs(self.allTypeCards[CardType.Twopair]) do
			--有两张
			if #self.allTypeCards[2] > 0 then
				for i= 1,#self.allTypeCards[2] do
					local tempThree = {}
					--从四张中取三张放入tempThree
					for i = 1, 3 do 
						table.insert(tempThree,v[i])
					end

					local towCards = self.allTypeCards[2][i]
					table.insert(tempThree,towCards[1])
					table.insert(tempThree,towCards[2])
					table.insert(self.allTypeCards[CardType.FullHouse],tempThree)
				end
			end
			--有三张 三张里取两张
			if #self.allTypeCards[3] > 0 then
				for j = 1, #self.allTypeCards[3] do
					local tempThree = {}
					--从四张中取三张放入tempThree
					for i = 1, 3 do 
						table.insert(tempThree,v[i])
					end
					local  curCard = self.allTypeCards[3][j]
					table.insert(tempThree,curCard[1])
					table.insert(tempThree,curCard[2])
					table.insert(self.allTypeCards[CardType.FullHouse],tempThree)
				end
			end

			--有四张里面取两张 自已除外
			for m = 1, #self.allTypeCards[CardType.Twopair] do
				local tempThree = {}
				--从四张中取三张放入tempThree
				for i = 1, 3 do 
					table.insert(tempThree,v[i])
				end
				local  curCard = self.allTypeCards[CardType.Twopair][m]
				if curCard[1].number ~= v[1].number then
					table.insert(tempThree,curCard[1])
					table.insert(tempThree,curCard[2])
					table.insert(self.allTypeCards[CardType.FullHouse],tempThree)
				end
			end
		end
	end

end

--找出所有的顺子，or 同花顺
function NinePiecesPlayer:findAllStraight()
	local cardCnt = #self.allTypeCards["Straight"]
	if cardCnt >= 5 then
		local tempStraight = {}
		for k ,v in pairs(self.allTypeCards["Straight"]) do
			if k > 1 then
				--当前数组中的元素个数
				local curCount = #v
				tempStraight[k] = {}
				for j , preCards in pairs(tempStraight[k-1]) do
					for i=1,#v do
						local  index = (j-1)*curCount + i
						if not tempStraight[k][index] then
							tempStraight[k][index] = {}
						end
						--把以前数组中的元素加进去
						for h =1,#preCards do
							table.insert(tempStraight[k][index],preCards[h])
						end
						table.insert(tempStraight[k][index],v[i])
					end
				end
			else
				tempStraight[k] = {}
				if type(v) == "table" then
					for i=1,#v do
						if not tempStraight[k][i] then
							tempStraight[k][i] = {}
						end
						table.insert(tempStraight[k][i],v[i])
					end
				end
			end
		end

		for m ,straight in pairs(tempStraight[cardCnt]) do
			table.insert(self.allTypeCards["StraightArray"],straight)
		end
	end
end

--找出所有4带1的牌型
function NinePiecesPlayer:findAllFourTakeOne( fourCard)
	local minCard = nil
	if #self.allTypeCards[1] > 0 then --有单张取最小的单张
		table.sort( self.allTypeCards[1], handler(self,self.cardCompareWithAce))
		for k ,v in pairs(self.allTypeCards[1]) do
			local tmp = {}
			for m,n in pairs(fourCard) do
				table.insert(tmp,n)
			end
			table.insert(tmp,v[1])
			table.insert(self.allTypeCards[CardType.FourOfKind],tmp)
			break
		end	
	end
	--对子中拆一张
	if #self.allTypeCards[2] >0 then
		for k ,v in pairs(self.allTypeCards[2]) do
			local tmp = {}
			for m,n in pairs(fourCard) do
				table.insert(tmp,n)
			end
			dump(v)
			table.insert(tmp,v[1])
			dump(tmp)
			table.insert(self.allTypeCards[CardType.FourOfKind],tmp)
		end
	end
	--三张中取一张
	if #self.allTypeCards[3] >0 then
		for k ,v in pairs(self.allTypeCards[3]) do
			local tmp = {}
			for m,n in pairs(fourCard) do
				table.insert(tmp,n)
			end
			table.insert(tmp,v[1])
			table.insert(self.allTypeCards[CardType.FourOfKind],tmp)
		end
	end
	--除自已以外的四张中取一张
	if #self.allTypeCards[CardType.Twopair] >1 then
		for k ,v in pairs(self.allTypeCards[CardType.Twopair]) do
			if v[1].number ~= fourCard[1].number then
				local tmp = {}
				for m,n in pairs(fourCard) do
					table.insert(tmp,n)
				end
				table.insert(tmp,v[1])
				table.insert(self.allTypeCards[CardType.FourOfKind],tmp)
			end
		end
	end

	--dump(self.allTypeCards[CardType.FourOfKind])
end

--找出单牌中最小的牌
function NinePiecesPlayer:findMinSingerCard(card)
	local  minCard = nil
	if #self.allTypeCards[1] > 0 then --有单张
		table.sort( self.allTypeCards[1], self.cardCompareWithAce)
		minCard = self.allTypeCards[1][1]
	elseif #self.allTypeCards[2] > 0 then --有对子
		table.sort( self.allTypeCards[2], self.cardCompareWithAce)
		minCard = self.allTypeCards[2][1]
	elseif #self.allTypeCards[3] > 0 then --有三张
		table.sort( self.allTypeCards[3], self.cardCompareWithAce)
		minCard = self.allTypeCards[3][1]
	elseif #self.allTypeCards[CardType.Twopair] > 0 then --有4张
		
	end
	return minCard
end
--计算每张牌的张数
--[[
card = {number = number牌值 ,ctype = ctype类型}
]]
--[[function NinePiecesPlayer:calCardCount(card)
	local hasIn = false
	for k ,v in pairs(self.allCard) do
		if type(v) == "table" and v.card and v.count then
			if  v.card.number == card.number then
				hasIn = true
				v.count = v.count + 1
			end
		end
	end
	--不在的话 加入数组
	if not hasIn then
		table.insert(self.allCard,{card = card,count = 1 })
	end
end]]

function NinePiecesPlayer:calCardCount(card)
	local hasIn = false
	for k ,v in pairs(self.allCard) do
		if type(v) == "table" then
			if  v[1].number == card.number then
				hasIn = true
				table.insert(self.allCard[k],card)
			end
		end
	end
	--不在的话 加入数组
	if not hasIn then
		table.insert(self.allCard,{card})
	end
end

--出牌
function NinePiecesPlayer:outCard()
	--主动出牌，超时计数清0
	self.countDownCount = 0

	local outCards = self.playerView:getCardView():getOutCards()
	--首次出牌不能带2 特殊处理
	if self.playerView:getCardView():getCardCount() == 9 then
		--首次不能出2
		if self:cardshasCardTwo(outCards) then
			self.playerView:getCardView():showCanotOutCardTip(1)
			return
		end
	end

	--必须出3 只能出带3的可出牌型
	if self.playerData.wChairID == self.workflow.mustHave3User then
		if not self:cardshasDiamond3(outCards) then
			self.playerView:getCardView():showCanotOutCardTip(2)
			return
		end
	end

	--下家报警特别处理
	downChairId = self.playerData.wChairID+1
	--当自已chair ==3 下家为0
	if self.playerData.wChairID == 3 then
		downChairId = 0
	end
	local downplayer = self.workflow:getPlayerByChairId(downChairId)
	if downplayer:getPlayerView():getCardView():getCardCount() == 1 then
		if #outCards == 1 then
			local isBiggest = self.playerView:getCardView():checkCardIsBiggest(outCards[1])
			if not isBiggest then
				--下家剩一张请顶大
				self.playerView:getCardView():showCanotOutCardTip(4)
				return
			end
		end
	end

	local cardPara = {}
	for k,v in pairs(outCards) do
		local cardValue = GameUtil:GetCardValueByPokerCard(v)
		table.insert(cardPara,cardValue)
		--从手牌区域移除出掉的牌
		self.playerView:getCardView():removeOutCard(v)
	end
	dump(cardPara)
	self.command:playCard(cardPara)
	--出牌区域添加牌
	self.playerView:getOutCardView():showOutCard(cardPara,#cardPara)
	self.fsm:doEvent("end")
end

--分析牌型 
function NinePiecesPlayer:analyzeCardType(cards)
	local MaxCardValue = 0
	if #cards == 1 then
		return CardType.SingleCard,MaxCardValue 
	elseif #cards == 2 then
		if cards[1].number == cards[2].number then
			return CardType.Onepair,MaxCardValue
		end
		return CardType.ValidType,MaxCardValue
	elseif #cards == 3 then
		for i=1,#cards do
			if i < #cards then
				if cards[i].number ~= cards[i+1].number then
					return CardType.ValidType,MaxCardValue
				end
			end
		end
		MaxCardValue = cards[1].number
		return CardType.ThreeCard,MaxCardValue
	elseif #cards == 5 then
		--返回一个牌型 和三张的那张牌 或者四张的那张牌
		local  cardType,MaxCardValue = self:checkIsFullHouseOrFourOfKind(cards)
		if cardType ~= CardType.ValidType then
			return cardType,MaxCardValue
		end
		--顺子 or 同花顺
		return self:checkIsStraightOrFlush(cards)
	else
		return CardType.ValidType,MaxCardValue
	end
end

--判断是不是葫芦 或者四皇后
function NinePiecesPlayer:checkIsFullHouseOrFourOfKind(cards)
	local  isFourOfKind = false
	local  isHasThree = false
	local  isHasPair = false
	local  MaxCardValue = 0
	self.tmpcard = {} --{{value = value,count = count},{value = value2,count = count2}..}
	for k ,v in pairs(cards) do
		self:isInCardArray(v.number)
	end

	for i = 1 ,#self.tmpcard do
		local curTmp = self.tmpcard[i]
		if curTmp.count == 4 then
			isFourOfKind = true
			MaxCardValue = curTmp.value
		elseif curTmp.count == 3 then
			isHasThree = true
			MaxCardValue = curTmp.value
		elseif curTmp.count == 2 then
			isHasPair = true
		end
	end

	--A 和2 特殊处理
	if MaxCardValue == 1 or MaxCardValue == 2 then
		MaxCardValue = MaxCardValue + 9
	end

	if isFourOfKind then
		return CardType.FourOfKind,MaxCardValue
	end

	if isHasThree and isHasPair then
		return CardType.FullHouse,MaxCardValue
	end

	return CardType.ValidType,MaxCardValue
end

--判断是不是在数组内
function NinePiecesPlayer:isInCardArray(cardValue)
	local hasIn = false
	for k ,v in pairs(self.tmpcard) do
		if type(v) == "table" and v.value and v.count then
			if  v.value == cardValue then
				hasIn = true
				v.count = v.count + 1
			end
		end
	end
	--不在的话 加入数组
	if not hasIn then
		table.insert(self.tmpcard,{value =cardValue,count = 1 })
	end
end

--判断是不是同花，杂顺，同花顺
function NinePiecesPlayer:checkIsStraightOrFlush(cards)
	--从大到小排序
	local  isSameColor = true -- 是否同色
	local  isStraight  = true -- 是否是顺子
	local  MaxCardValue = 0
	table.sort(cards,handler(self,self.cardCompare))
	for i=1,#cards do
		if i < #cards then
			if cards[i].number + 1 ~= cards[i+1].number then
				isStraight = false
			end

			if cards[i].ctype ~= cards[i+1].ctype  then
				isSameColor = false
			end
		end
	end

	if isStraight then
		if isSameColor then
			return CardType.StraightFlush,MaxCardValue
		else
			return CardType.Straight,MaxCardValue
		end
	else
		if isSameColor then
			return CardType.Flush,MaxCardValue
		else
			return CardType.ValidType,MaxCardValue
		end
	end
end


--不考虑A 2为大 的情况
function NinePiecesPlayer:cardCompare(card1,card2)
	if card1.number < card2.number then
        return true
    else
        --相同牌值比花色
        if card1.number == card2.number then
            if  card1.ctype  < card2.ctype then
                return true
            end
        end
        return false
    end
end

--考虑A 2为大 的情况
function NinePiecesPlayer:cardCompare2(card1,card2)
	local number1 = card1.number
	local number2 = card2.number
	if number1 == 1 or number1 == 2 then
		number1 = number1 + 9
	end

	if number2 == 1 or number2 == 2 then
		number2 = number2 + 9
	end

	if number1 < number2 then
        return true
    else
        --相同牌值比花色
        if number1 == number2 then
            if  card1.ctype  < card2.ctype then
                return true
            end
        end
        return false
    end
end

--考虑A 2为大 的情况
function NinePiecesPlayer:cardCompareWithAce(card1,card2)
	local number1 = card1[1].number
	local number2 = card2[1].number
	if number1 == 1 or number1 == 2 then
		number1 = number1 + 9
	end

	if number2 == 1 or number2 == 2 then
		number2 = number2 + 9
	end


	if number1 < number2 then
        return true
    else
        --相同牌值比花色
        if number1 == number2 then
            if  card1[1].ctype  < card2[1].ctype then
                return true
            end
        end
        return false
    end
end

-- 打印当前的牌组信息，测试的时候用
function NinePiecesPlayer:printCurrentCards()
	local group1String = ""
	for i, v in ipairs(self.cardGroup[1]) do
		if v.type and v.number then
			group1String = group1String .. GameUtil:GetCardByChinese(v.type, v.number) .. ", "
		end
	end
	print("group1String"..group1String)
end

function  NinePiecesPlayer:receiveOutCardMessage(outCardInfo)
	dump(outCardInfo)
	print("self.playerData.wChairID"..self.playerData.wChairID)
	if self.playerData.wChairID == outCardInfo.wOutCardUser then
		--自已收到出牌
		if self.playerData.wChairID == self.workflow:getMyChairID() then
			--上把是自已出牌 清空上手牌数组
			self.lastOutCards = {}
			--置不能过牌标忘为0
			self.canNotPass = false
		else
			--收到别人出的牌，在出牌区显示添加牌
			self.playerView:getOutCardView():showOutCard(outCardInfo.cbCardData,outCardInfo.cbCardCount)
		end 
		local  maxCount = self.playerView:getCardView():getCardCount()
		self.playerView:getCardView():setCardCount(maxCount - outCardInfo.cbCardCount)
		--一张牌时报警
		if self.playerView:getCardView():getCardCount() == 1 then
			self.isAlarm = true
			self.playerView:showAlarm(true)
			SoundManager:playMusicEffect("ys9zhang/audio/waring.mp3", false)
			--可以主动托管
			if self.playerData.wChairID == self.workflow:getMyChairID() then
				self.workflow:canTuoguanMySelf()
			end
		end
	else
		--自已收到其他玩家出牌消息处理
		if self.playerData.wChairID == self.workflow:getMyChairID() then
			--清空上手牌数组
			self.lastOutCards = {}
			--保存上一手其他玩家出的牌
		 	if outCardInfo.wOutCardUser ~= self.playerData.wChairID  then
		 		for k ,value in pairs(outCardInfo.cbCardData) do
					if tonumber(value) > 0 then
						local cardType, cardNumber = GameUtil:GetCardForPc(tonumber(value))
						table.insert(self.lastOutCards,{ctype = cardType, number = cardNumber})
					end
				end
		 	end
		end
	end

	self.playerView:setCountDownTimeInterval(outCardInfo.OutCardTime)
	
	print("NinePiecesPlayer:receiveOutCardMessage")
	dump(self.lastOutCards)
	--先切换状态
	self.fsm:doEvent("end")

	self:handleNextPlayer{nextPlayerId = tonumber(outCardInfo.wCurrentUser),autoPass = outCardInfo.cbAutoPass}
end

function  NinePiecesPlayer:receivePassMessage(passCardInfo)
	if self.playerData.wChairID == passCardInfo.wPassCardUser then
		--自已收到过牌
		if self.playerData.wChairID == self.workflow:getMyChairID() then
		 	
		else
			self.playerView:getOutCardView():showPromptImage("pass")
		end 
	else
		if self.playerData.wChairID == self.workflow:getMyChairID() then
			--一轮结束，且是自已出牌
			if passCardInfo.wCurrentUser == self.playerData.wChairID and passCardInfo.cbTurnOver == 1 then
				self.canNotPass = true
			end
		end
	end

	self.playerView:setCountDownTimeInterval(passCardInfo.OutCardTime)
	print("NinePiecesPlayer:receivePassMessage")
	--先切换状态
	self.fsm:doEvent("end")

	self:handleNextPlayer{nextPlayerId = tonumber(passCardInfo.wCurrentUser),autoPass = passCardInfo.cbAutoPass}
	
end

--接收到正在游戏的消息 恢复场景
function NinePiecesPlayer:receiveStatusPlayingMessage(statusInfo)
	--玩家手牌张数
	local  handcardCnt = statusInfo.cbHandCardCount[self.playerData.wChairID + 1]
	local  isMySelf = false
	--自已
	if self.playerData.wChairID == self.workflow:getMyChairID() then
		isMySelf = true
		table.sort(statusInfo.cbHandCardData,handler(self, GameUtil.compByIndex))
		--根据牌的张数算出CardView偏移的距离
		local cardView = self.playerView:getCardView()
		local distance = ((9 - handcardCnt)*cardView.CardOffset)/2
		cardView:setPosition(cc.p(cardView:getPositionX()+distance,cardView:getPositionY()))
		for i= 1, handcardCnt do
			local index = statusInfo.cbHandCardData[i]
			local cardType, cardNumber = GameUtil:GetCardForPc(index)
			local card = PokerCard.new{ctype = cardType, number = cardNumber ,clickHandler = handler(self, self.clickCardHandler)}
			card:setScale(0.9)
			self.playerView:getCardView():giveCard{card = card, delay = 0,isMySelf = true}
		end
		--加上触摸事件
		self.playerView:getCardView():addClickNode()
		--清空上手牌数组
		self.lastOutCards = {}
		--不是自已出的牌，加入到出牌数组
		if self.playerData.wChairID ~= statusInfo.wTurnWiner then
			for l=1 ,statusInfo.cbTurnCardCount  do
				local  value = statusInfo.cbTurnCardData[l]
				if value > 0 then
					local cardType, cardNumber = GameUtil:GetCardForPc(value)
					table.insert(self.lastOutCards,{ctype = cardType, number = cardNumber})
				end
			end
		end
	else
		--给一张盖牌
		local cardType, cardNumber = GameUtil:GetCardForPc(tonumber(3))
		local card = PokerCard.new{ctype = cardType, number = cardNumber}
		card:cover()
		card:setScale(0.34)
		self.playerView:getCardView():giveCard{card = card, delay = 0,isMySelf = false}
	end

	--设置牌的张数
	self.playerView:getCardView():setCardCount(handcardCnt)
	--恢复报警灯
	if handcardCnt == 1 then
		self.isAlarm = true
		self.playerView:showAlarm(true)
	end
	--玩家有出牌信息
	if self.playerData.wChairID == statusInfo.wTurnWiner then
		self.playerView:getOutCardView():showOutCard(statusInfo.cbTurnCardData,statusInfo.cbTurnCardCount)
	else 
		--显示不出
		self.playerView:getOutCardView():showPromptImage("pass")
	end

	self.playerView:setCountDownTimeInterval(statusInfo.cbTimeOutCard)
	
	if self.playerData.wChairID == self.workflow:getMyChairID() then
		--恢复场景时，上手出牌玩家和下个操作是同一个的时候，不能不出
		if statusInfo.wCurrentUser == statusInfo.wTurnWiner then
			self.canNotPass = true
		end
	end

	self:handleNextPlayer{nextPlayerId = tonumber(statusInfo.wCurrentUser),autoPass = statusInfo.cbAutoPass}
end

function NinePiecesPlayer:receiveRoundOverMessage( roundInfo )
	-- 重置玩家的状态
	self.fsm:doEvent("end")
	--获取余下的手牌
	local  loseCards = self:getLeftCards(roundInfo.cbCardCount,roundInfo.cbHandCardData)
	if #loseCards > 0 then
		--先清除上一把的出牌
		self.playerView:getOutCardView():clearOutCards()
		table.sort(loseCards,handler(self, GameUtil.compByIndex))
		--[[for k,value in pairs(loseCards) do
			local cardType, cardNumber = GameUtil:GetCardForPc(tonumber(value))
			local  card =  PokerCard.new{ctype = cardType, number = cardNumber }
			card:setScale(0.6)
			local  isMySelf = false
			if self.playerData.wChairID == self.workflow:getMyChairID() then
				isMySelf = true
			end
	 		self.playerView:getCardView():showOutCard{card = card,isMySelf = isMySelf}
		end]]
		local cardCnt = roundInfo.cbCardCount[self.playerData.wChairID+1]
		self.playerView:getOutCardView():showOutCard(loseCards,cardCnt)
	end
	
	--手牌数置0
	self.handCardCount = 0
	--上手牌清空
	self.lastOutCards = {}
	self.isAlarm = false
	self.isTuoGuan = false
	self.playerView:showAlarm(false)
	self:cancelTuoGuan()
	--一把结束处理
	self.playerView:getCardView():roundOver()
end



function NinePiecesPlayer:getLeftCards(cardCount,handCardData)
	local loseCards = {} 
	local  chairId  = self.playerData.wChairID
	local  cardCnt = cardCount[chairId + 1]

	if  cardCnt > 0 then
		if chairId == 0  then
			for i=1,cardCnt do
				table.insert(loseCards,handCardData[i])
			end
		else
			local  preCnt = 0 --前置牌张数
			for k=1,chairId do
				preCnt = preCnt + cardCount[k]
			end
			print(string.format("wChairID = %d, preCnt = %d",chairId,preCnt))
			--取出玩家剩下的手牌
			for k=preCnt+1,preCnt+cardCnt do
				table.insert(loseCards,handCardData[k])
			end
		end
	end

	return loseCards
end


function NinePiecesPlayer:sendReadyRequest()
	self.command:ready()
	--点两下测试 提示牌是否正确
	--[[if not self.isPre then
		self:prePrompt()
		self.isPre = 1
	else
		self:prompt()
	end]]
end

function NinePiecesPlayer:sendStandUpRequest()
	self.command:standUp()
end

--操作超时
function NinePiecesPlayer:DecidingCountDownEnd()
	print("操作超时")
	if self.countDownCount < 2 then
		self.countDownCount = self.countDownCount + 1
	end

	if  self.playerData.wChairID == self.workflow:getMyChairID() then
		if self.countDownCount == 1 then
			if self.playerData.wChairID == self.workflow.mustHave3User then
				self.command:playCard({3})--自动出片3
				--出牌区域显示
				self.playerView:getOutCardView():showOutCard({3},1)
				--从手牌区域移除 找到最小的牌出 就是片3
				local minCard = self.playerView:getCardView():getMinCard()
				self.playerView:getCardView():removeOutCard(minCard)
			else
				--不能过牌，自动出最少的牌
				if self.canNotPass then
					--下家报警处理
					self:downplayerAlarmPro()
				else
					self.command:pass(0) --自动过牌
					self.playerView:getOutCardView():showPromptImage("pass")
				end
			end
		elseif self.countDownCount == 2 then --超时两次 自动托管 根据上家出的牌判断 能压就压 
			--to do 暂时过牌处理
			print("超时二次PASS")
			self.isTuoGuan = true
			self:tuoGuanPro()
			--牌组变暗且不能操作
			self.playerView:getCardView():tuoGuanPro(true)
			self.workflow:tuoGuanPro(true)
		end
	end
	--切换到空闲状态
	self.fsm:doEvent("end")
end

--主动托管
function NinePiecesPlayer:autoTuoGuan()
	self.isTuoGuan = true
	self.playerView:getCardView():tuoGuanPro(true)
end

--获取托管标记
function NinePiecesPlayer:getTuoGuanFlag()
	return self.isTuoGuan
end

--设置托管标记
function NinePiecesPlayer:setTuoGuanFlag(value)
	 self.isTuoGuan = value
end

--下家报警处理
function NinePiecesPlayer:downplayerAlarmPro()
	--下家报警特别处理
	downChairId = self.playerData.wChairID+1
	--当自已chair ==3 下家为0
	if self.playerData.wChairID == 3 then
		downChairId = 0
	end
	local downplayer = self.workflow:getPlayerByChairId(downChairId)
	--下家报警出最大
	local outCard =nil
	print("card cnt ="..downplayer:getPlayerView():getCardView():getCardCount())
	if downplayer:getPlayerView():getCardView():getCardCount() == 1 then
		outCard = self.playerView:getCardView():getMaxCard()
	else
		--找到最小的牌出
		outCard = self.playerView:getCardView():getMinCard()
	end
	--发送出牌请求
	local toCardValue = outCard.ctype*16+outCard.number
	self.command:playCard({toCardValue})

	self.playerView:getOutCardView():showOutCard({toCardValue},1)
	--从手牌区域移除
	self.playerView:getCardView():removeOutCard(outCard)
end


--下家是否报警
function NinePiecesPlayer:downplayerIsWaring()
	--下家报警特别处理
	downChairId = self.playerData.wChairID+1
	--当自已chair ==3 下家为0
	if self.playerData.wChairID == 3 then
		downChairId = 0
	end
	local downplayer = self.workflow:getPlayerByChairId(downChairId)
	if downplayer:getPlayerView():getCardView():getCardCount() == 1 then
		print("下家报警了")
		return true
	end
	return false
end
--托管处理
function NinePiecesPlayer:tuoGuanPro()
	--托管压牌
	if #self.lastOutCards >0 then
		--上家牌型及最大值
		lastCardType,outMaxCardValue = self:analyzeCardType(self.lastOutCards)
		print("lastCardType"..lastCardType)
		print("CardType.SingerCard"..CardType.SingleCard)
		if lastCardType == CardType.SingleCard then
			--单张判断下家是否报警
			print("单张，判断下家是否报警")
			if self.canNotPass then
				self:downplayerAlarmPro()
			else
				--下家报警判断,最大一张能不能出,封牌，大主上不会进入超时托管处理
				if self:downplayerIsWaring() then
					--下家报警处理
					self:downPlayerWaringPro()
				else
					self:canBiggerUpPlayer()
				end
			end
		else
			self:canBiggerUpPlayer()
			--[[if #self.promptCard > 0 then
				local outCards = {}
				for k ,v in pairs(self.promptCard[1]) do
					table.insert(outCards,v)
				end
				local cardPara = {}
				for k,v in pairs(outCards) do
					local cardValue = GameUtil:GetCardValueByPokerCard(v)
					table.insert(cardPara,cardValue)
					--从手牌区域移除出掉的牌
					self.playerView:getCardView():removeOutCard(v)
				end
				self.command:playCard(cardPara)
				--出牌区域添加牌
				self.playerView:getOutCardView():showOutCard(cardPara,#cardPara)
			else
				self.command:pass(0)
				self.playerView:getOutCardView():showPromptImage("pass")
			end]]
		end
	else
		--不能过牌
		if self.canNotPass then
			self:downplayerAlarmPro()
		else
			--下家报警
			if self:downplayerIsWaring() then
				--下家报警处理
				self:downPlayerWaringPro()
			else
				self:canBiggerUpPlayer()
			end
		end
	end
	self.fsm:doEvent("end")
end

--下家报警处理
function NinePiecesPlayer:downPlayerWaringPro()
	local outCard = self.playerView:getCardView():getMaxCard()
	local temp = {}
	table.insert(temp,{ctype = outCard.ctype, number = outCard.number})
	local isBigger = self:checkIsBigger(temp, CardType.SingleCard, false)
	if isBigger then
		local toCardValue = outCard.ctype*16+outCard.number
		self.command:playCard({toCardValue})

		self.playerView:getOutCardView():showOutCard({toCardValue},1)
		--从手牌区域移除
		self.playerView:getCardView():removeOutCard(outCard)
	else
		self.command:pass(0)
		self.playerView:getOutCardView():showPromptImage("pass")
	end
end

--托管能压就压
function NinePiecesPlayer:canBiggerUpPlayer()
	if #self.promptCard > 0 then
		local outCards = {}
		for k ,v in pairs(self.promptCard[1]) do
			table.insert(outCards,v)
		end
		local cardPara = {}
		for k,v in pairs(outCards) do
			local cardValue = GameUtil:GetCardValueByPokerCard(v)
			table.insert(cardPara,cardValue)
			--从手牌区域移除出掉的牌
			self.playerView:getCardView():removeOutCard(v)
		end
		self.command:playCard(cardPara)
		--出牌区域添加牌
		self.playerView:getOutCardView():showOutCard(cardPara,#cardPara)
	else
		self.command:pass(0)
		self.playerView:getOutCardView():showPromptImage("pass")
	end
end

function NinePiecesPlayer:cancelTuoGuan()
	--托管记数置0
	self.countDownCount = 0	
	self:setTuoGuanFlag(false)
	--恢复牌组操作
	self.playerView:getCardView():tuoGuanPro(false)
end

function NinePiecesPlayer:getCanPassFalg()
	return self.canNotPass
end

function NinePiecesPlayer:setCanPassFalg(flag)
	self.canNotPass = flag
end

function NinePiecesPlayer:checkClickCard(winPos)
	if self.playerView and self.playerView:getCardView() then
		self.playerView:getCardView():checkClickCard(winPos)
	end
end

function NinePiecesPlayer:clickEndedPro()
	if self.playerView and self.playerView:getCardView() then
		self.playerView:getCardView():clickEndedPro()
	end
end

function NinePiecesPlayer:onReadyPro()
	self.playerView:getOutCardView():showPromptImage("ready")
end

return NinePiecesPlayer