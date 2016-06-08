
local UserCardControl =class("UserCardControl", function()
	return display.newLayer()end) 


local PokerCard = import("..Kernel.PokerCard")

--构造
function UserCardControl:ctor()
	self.PokerCards={} 
	self.count=0
	self:setTouchEnabled(false)
end
--清空数据重置NODE
function UserCardControl:FreeControl()
	--for i=1,table.getn(self.PokerCards) do
	 -- self:removeChild(self.PokerCards[i])
	--end
	self:removeAllChildren()	
	self.PokerCards={}
end
--设置地主牌标志
function UserCardControl:SetLandCard()
    local count=table.getn(self.PokerCards)
    if count>=1 then
    	self.PokerCards[count]:Setland()
    end
	
end
--设置牌数据
function UserCardControl:SetCardData(count,data)
    --先清空
    self:FreeControl()
    self.count=count
    --遍历设置
	for i=1,count do
		--初始化这张牌
	  local cardType, cardNumber = GameUtil:GetCardForPc(data[i])
	  local Poker = PokerCard.new{ctype = cardType, number = cardNumber }
	  Poker:open()

      Poker:setPosition(self.CardPos.x,self.CardPos.y)
      self.CardPos.x=self.CardPos.x+self.CardDistance
	  --设置大小
	  Poker:setScale(self.CardScal)
	  --牌元素
	  table.insert(self.PokerCards,Poker)
	  self:addChild(Poker)
	end
	--self:SortCard()
    self:ResetCardPos()
end


--根据颜色和数字创建PC的数据值
function UserCardControl:MakePcLogicCardNum(cardType, Number)
	local num=(cardType)*16+Number
	return num
end




--排序
function UserCardControl:SortCard()

	table.sort(self.PokerCards, handler(self,self.Compara))
    self:ResetCardPos()
    
end
--整理位置
function UserCardControl:ResetCardPos()

	local CardCount=table.getn(self.PokerCards)
	local x = display.width-(CardCount-1)*self.CardDistance
	x=x/2
	local y= self.CardPos.y
	for i=1,CardCount do
		self.PokerCards[i]:zorder(i)
		self.PokerCards[i]:setPosition(x+(i-1)*self.CardDistance, y)
	end
end
--用户手牌的初始位置
function UserCardControl:SetStartPos(Pos)
	-- body
	self.CardPos=Pos
end
--用户手牌的间距
function UserCardControl:SetDistance(Distance)
	-- body
	self.CardDistance=Distance
end
--用户手牌的大小
function UserCardControl:SetScal(Scal)
	-- body
	self.CardScal=Scal
end


--比较牌
function UserCardControl:Compara(a,b)

    local num1=self:GetCardLogicValue(a.number)
	local num2=self:GetCardLogicValue(b.number)

	if a.ctype ==4 then
		num1 =num1+2
	end

	if b.ctype ==4 then
		num2 =num2+2
	end


	if num1>num2 then
		return true
	end
	if num1==num2 then
		if a.ctype>b.ctype then
			return true
		end
	end
	return false
end
function UserCardControl:GetCardLogicValue(number)
	-- body
    local cardNumber=number
    if cardNumber<2 then
    	cardNumber=cardNumber+13
    end
    return cardNumber
end
return UserCardControl