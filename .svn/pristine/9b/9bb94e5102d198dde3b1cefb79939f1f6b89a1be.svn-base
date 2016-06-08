
local PokerCard = import("..Kernel.PokerCard")
local CardLogic    = import("..Kernel.CardLogic")--牌堆管理


local HandCardControl =class("HandCardControl", function()
	return display.newLayer()end) 




--构造
function HandCardControl:ctor()
--	print("手牌构造")
	self.PokerCards={} 
	self.EnableTouch=false
	self:setTouchEnabled(false)
	self.endx=0
    self.beganx=0
    self.findcardresult={}
 

    -- 消息定义--发完一张牌
    self.Event = 
    {
     HINT_CARD = "HINT_CARD",--触摸牌消息
    }
    --扑克逻辑对象
    self.m_CardLogic=CardLogic.new()
end
--清空数据重置NODE
function HandCardControl:FreeControl()

	self:removeAllChildren()
	self.PokerCards={}
	self.EnableTouch=false
	self.Land=false
end

function HandCardControl:OnHintHandCardFind(Pockers)


    local findcount=0
    local CardCount=table.getn(Pockers)
    local ShootCard={}
    for i=1,CardCount do
    	ShootCard[i]=self:MakePcLogicCardNum(Pockers[i].ctype, Pockers[i].number)
    end
    local data={}
    local FindOutCount,FindOutCardData=self.m_CardLogic:SearchslectoutCard(ShootCard,#ShootCard,data,0)
--    print("查找到牌型"..FindOutCount)
    if FindOutCount>0 then
        local maxindex=1
        local carddata=FindOutCardData[1]
        local cardcount=#carddata
        for i=2,FindOutCount do
            local carddatanext=FindOutCardData[i]
            local cardcountnext=#carddatanext
            if cardcountnext>cardcount then
                maxindex=i
            end
        end

        local resultdata=FindOutCardData[maxindex]
        print("最后输出"..#resultdata)
        dump(resultdata)
        --self:ShootCard(resultdata)
        findcount=1

        return findcount,resultdata

    end

   return findcount,resultdata
end
--点击牌
function HandCardControl:OnClickOneCard(sender,msgtype,x,y)
    --print("x="..x.."y="..y.."firstCardx="..firstCardx)
    if self.EnableTouch==false then
	return false
    end


	if msgtype=="began" then
		self.beganx=x

		self.moved = false
		self.beginX = x
		self.beginY = y
	end

	if msgtype=="ended" then

	    if self.moved==true then
	    	self.moved=false
			local CardCount=table.getn(self.PokerCards)
			
			local selectcard={}

			for i=1,CardCount do
			    if self.PokerCards[i].select==true then
			   		--self.PokerCards[i]:setShoot(false)
			   		self.PokerCards[i]:setSelect(false)
			   		table.insert(selectcard, self.PokerCards[i])
			   	end
			end
            local selectupcard={}
	        for k,v in pairs(selectcard) do
	        	if v.status==0 then
	        		table.insert(selectupcard, v)
	        	end
			end
			local findcount,findcard=self:OnHintHandCardFind(selectcard)

			if findcount>0  then
				self:performWithDelay(function ( )	
					self:ShootCard(findcard,false)
					--通知到场景
		            AppBaseInstanse.ErRenLandApp.EventCenter:dispatchEvent({
		            name = self.Event.HINT_CARD,
		            type= true
		            })
			    end, 0.1)

                --self:ShootCard(findcard)
			else
				for k,v in pairs(selectcard) do
		        	v:setShoot(true)
			    end
				--通知到场景
	            AppBaseInstanse.ErRenLandApp.EventCenter:dispatchEvent({
	            name = self.Event.HINT_CARD,
	            type= true
	            })
			end
	        --end
		else
	   	    sender:setShoot(true)
	   	    --通知到场景
            AppBaseInstanse.ErRenLandApp.EventCenter:dispatchEvent({
            name = self.Event.HINT_CARD,
            type= true
            })
	    end

        

	end
	if msgtype=="moved" then
		if math.abs(x-self.beginX)>10 then
			self.moved = true
		end
		self.endx=x
		local newx=self.beganx
	   	if self.endx<self.beganx then
	   	    self.endx=self.beganx
	   		newx=x
	   	end
	   	local CardCount=table.getn(self.PokerCards)
	   	for i=1,CardCount do
	   		local sizex=self.PokerCards[i]:getContentSize().width/2*self.CardScal
            local Cardx=self.PokerCards[i]:getPositionX()-sizex

	   		if Cardx>newx-self.CardDistance and Cardx< self.endx then
	   		   self.PokerCards[i]:setSelect(true)
	   		else
	   		   self.PokerCards[i]:setSelect(false)
	   		end
	   	end
	end
end
function HandCardControl:doshoot()
	-- body
end
--加入一张牌
function HandCardControl:AddOneHandCard(carddata)
  --初始化这张牌
  local cardType, cardNumber = GameUtil:GetCardForPc(carddata)

--  print("cardType="..cardType.."cardNumber="..cardNumber)
  local Poker = PokerCard.new{ctype = cardType, number = cardNumber ,clickHandler = handler(self, self.OnClickOneCard)}

  --设置是否显示
  Poker:open()

  --设置大小
  Poker:setScale(self.CardScal)


  --牌元素
  table.insert(self.PokerCards,Poker)
--table.sort(self.PokerCards, handler(self,self.Compara))
  self:ResetCardPosForDisCard()
  --self:SortCard()

  self:addChild(Poker)
end
--插入底牌
function HandCardControl:SetBackCardData(data)

--dump(data)
	--全部先回位
   -- for index=1,table.getn(self.PokerCards) do
      --  self.PokerCards[index]:setSelectLowDown()
	--end

    local backcard={}
	--遍历设置
	for i=1,3 do
		--初始化这张牌
	  local cardType, cardNumber = GameUtil:GetCardForPc(data[i])
	  local Poker = PokerCard.new{ctype = cardType, number = cardNumber ,clickHandler = handler(self, self.OnClickOneCard)}

	
		Poker:open()
		Poker:setShoot(false)
		Poker:SetBackCard(true)
		--设置大小
		Poker:setScale(self.CardScal)

        --local y= self.CardPos.y
		--Poker:setPositionY(y)
	
		--牌元素
		table.insert(self.PokerCards,Poker)
		self:addChild(Poker)
		backcard[i]=Poker
	end

    self:SortCard()

	for i=1,3 do
		backcard[i]:setBackCardShootDown()
		backcard[i]:SetBackCard(false)
	end

	---self:SortCard()
end
--设置牌数据
function HandCardControl:SetCardData(count,data)
    --先清空
    self:FreeControl()
    --遍历设置
	for i=1,count do
		--初始化这张牌
	  local cardType, cardNumber = GameUtil:GetCardForPc(data[i])
	  local Poker = PokerCard.new{ctype = cardType, number = cardNumber ,clickHandler = handler(self, self.OnClickOneCard)}

	  --设置是否显示
	  if self.ShowCard==true then 
		Poker:open()
	  else
		Poker:cover()
	  end
	  --设置大小
	  Poker:setScale(self.CardScal)
	  --牌元素
	  table.insert(self.PokerCards,Poker)
	  self:addChild(Poker)
	end
	self:SortCard()
    --self:ResetCardPos()
end
--设置牌数据
function HandCardControl:SetOthHandCardData(count,data,pos)
    --先清空
    self:FreeControl()
    self.OthHandCardPos=pos
    print("位置")
    dump(self.OthHandCardPos)
    --遍历设置
	for i=1,count do
		--初始化这张牌
	  local cardType, cardNumber = GameUtil:GetCardForPc(data[i])
	  local Poker = PokerCard.new{ctype = cardType, number = cardNumber }

	--Poker:open()

	  --设置大小
	  Poker:setScale(0.6)
	  --牌元素
	  table.insert(self.PokerCards,Poker)
	  self:addChild(Poker)
	end
	table.sort(self.PokerCards, handler(self,self.Compara))
    self:ResetOthHandCardPos()
end
--整理位置
function HandCardControl:ResetOthHandCardPos()

	--[[local CardCount=table.getn(self.PokerCards)
	local x = self.OthHandCardPos.x
	local y= self.OthHandCardPos.y

	for i=1,CardCount do
		self.PokerCards[i]:zorder(i)
		self.PokerCards[i]:setPosition(x+(i-1)*21, y)
	end]]

	local CardCount=table.getn(self.PokerCards)
	local x = display.width-(CardCount-1)*28
	local y= self.OthHandCardPos.y
	x=x/2
	for i=1,CardCount do
		self.PokerCards[i]:zorder(i)
		self.PokerCards[i]:setPosition(x+(i-1)*28, y)
	end
end

--获取弹起牌
function HandCardControl:GetShootCard()
	local ShootCard=
	{
	 count=0,
	 data={}
    }
    for index=1,table.getn(self.PokerCards) do
        if self.PokerCards[index].status==1 then
        	ShootCard.count=ShootCard.count+1
        	local data=self:MakePcLogicCardNum(self.PokerCards[index].ctype,self.PokerCards[index].number)
        	table.insert(ShootCard.data,data)
        end
	end
	return ShootCard

end
--根据颜色和数字创建PC的数据值
function HandCardControl:MakePcLogicCardNum(cardType, Number)
	local num=(cardType)*16+Number
	return num
end
--设置所有手牌归位
function HandCardControl:SetCardLowDown()
	    --全部先回位
    --for index=1,table.getn(self.PokerCards) do
     --   self.PokerCards[index]:setSelectLowDown()
        
	--end
	self:SortCard()
end
--设置弹起牌
function HandCardControl:ShootCard(carddata,auto)


    --全部先回位
   -- for index=1,table.getn(self.PokerCards) do
     --   self.PokerCards[index]:setSelectLowDown() 
	--end
	--self:SortCard()
	self:ResetCardPos()

	for i,v in ipairs(carddata) do
		local cardType, cardNumber = GameUtil:GetCardForPc(carddata[i])
	    for j=1,table.getn(self.PokerCards) do
	    if self.PokerCards[j].number==cardNumber and self.PokerCards[j].ctype==cardType then
			card=self.PokerCards[j]
			end	
	    end
	    if card then
	    	if auto==true then
	    		card:setShoot(false)
	    	else
	    		card:setShoot(true)
	    	end
	    	
		end 
	end
end

--删除牌
function HandCardControl:RemoveCard(count,carddata)
	for i=1, count do
		local cardType, cardNumber = GameUtil:GetCardForPc(carddata[i])
		local card=0
	    for j=1,table.getn(self.PokerCards) do
		    if self.PokerCards[j].number==cardNumber and self.PokerCards[j].ctype==cardType then
				card=self.PokerCards[j]
				break
			end	
	    end
	    if card ~=0 then
			--删除
			local index = table.indexof(self.PokerCards, card)  
	        if index then
			   table.remove(self.PokerCards, index)
		    end 

			self:removeChild(card) 
		end 
		--print(carddata[i])
	end
    self:ResetCardPosForDisCard()
   -- self:SortCard()
    self:ReSetLandCard()
end

--排序
function HandCardControl:SortCard()

	table.sort(self.PokerCards, handler(self,self.Compara))
    self:ResetCardPos()
    --self:ResetCardPosForDisCard()
 
    
end

--整理位置
function HandCardControl:ResetCardPosForDisCard()
	local CardCount=table.getn(self.PokerCards)
	local x = display.width-(CardCount-1)*self.CardDistance
	x=x/2
	for i=1,CardCount do
		self.PokerCards[i]:zorder(i)
		local y= self.CardPos.y
		if self.PokerCards[i]:IsBackCard()==true then
			y=y+self.PokerCards[i]:getShootHight()
		end
		self.PokerCards[i]:setShootstatus(0)
		local cp=cc.p(x+(i-1)*self.CardDistance, y)
		self.PokerCards[i]:SetCardMoveToPos(cp)
	end
end
--整理位置
function HandCardControl:ResetCardPos()

	local CardCount=table.getn(self.PokerCards)
	local x = display.width-(CardCount-1)*self.CardDistance
	x=x/2
	for i=1,CardCount do
		self.PokerCards[i]:zorder(i)
		local y= self.CardPos.y
		if self.PokerCards[i]:IsBackCard()==true then
			y=y+self.PokerCards[i]:getShootHight()
		end
		self.PokerCards[i]:setShootstatus(0)
		self.PokerCards[i]:setPosition(x+(i-1)*self.CardDistance, y)
	end
end
--设置地主牌标志
function HandCardControl:SetLandCard()
	print("设置地主牌标志")
	self.Land=true
    local count=table.getn(self.PokerCards)
	self.PokerCards[count]:Setland()
end
--设置地主牌标志
function HandCardControl:ReSetLandCard()
  --  for index=1,table.getn(self.PokerCards) do
    --    self.PokerCards[index]:Setland()
	--end
	
	if self.Land==true then
		local count=table.getn(self.PokerCards)
		if count>0 then
			self.PokerCards[count]:Setland()
		end
		
	end

end

--用户手牌的初始位置
function HandCardControl:SetStartPos(Pos)
	-- body
	self.CardPos=Pos
end
--用户手牌的间距
function HandCardControl:SetDistance(Distance)
	-- body
	self.CardDistance=Distance
end
--用户手牌的大小
function HandCardControl:SetScal(Scal)
	-- body
	self.CardScal=Scal
end
--设置是否显示牌
function HandCardControl:SetShow(isshow)
	-- body
	self.ShowCard=isshow
	local CardCount=table.getn(self.PokerCards)
	for i=1,CardCount do
		if isshow==true then 
			self.PokerCards[i]:open()
		else
		    self.PokerCards[i]:cover()	
		end
	end
end

--设置是否托管reorderChild
function HandCardControl:SetTuoguanStatus(istuoguan)
	local CardCount=table.getn(self.PokerCards)
	for i=1,CardCount do
		self.PokerCards[i]:setTuoGuanstatus(istuoguan)
	end
end
--设置响应
function HandCardControl:SetCardTouchEnabled(enable)
	self.EnableTouch=enable
end
--比较牌
function HandCardControl:Compara(a,b)

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
function HandCardControl:GetCardLogicValue(number)
	-- body
    local cardNumber=number
    if cardNumber<=2 then
    	cardNumber=cardNumber+13
    end
    return cardNumber
end
return HandCardControl