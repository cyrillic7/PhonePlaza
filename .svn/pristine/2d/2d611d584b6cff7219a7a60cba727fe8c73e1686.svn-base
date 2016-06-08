--[[
用于发牌和留存底牌的牌堆

]]
local PokerCard = import("..Kernel.PokerCard")

local BackCard =class("BackCard", function()
return display.newLayer()end) 
--构造
function BackCard:ctor(x,y)
	self.Backcards = {} --牌(pokercard)数组
	self.BackCardScal =0.8 --牌堆初始大小

    --加载牌的资源
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Common/AnimationCardSmall.ExportJson")
	--self.node=node
	self:setTouchEnabled(false)

    --底牌位置
	self.posBackCardPos = 
	{
	   cc.p(23,display.height-107),
	   cc.p(23+43,display.height-107),
	   cc.p(23+43+43,display.height-107),
	}

		self.posBackCardPosNo = 
	{
	   cc.p(23,display.height-122),
	   cc.p(23+43,display.height-122),
	   cc.p(23+43+43,display.height-122),
	}
    self.Event = { OPEN_BACK_CARD_FINISH = "OPEN_BACK_CARD_FINISH",}--底牌翻开消息
end
--清空数据
function BackCard:FreeControl()
	self:removeAllChildren()
	self.Backcards = {} --牌(pokercard)数组
end
--设置底牌
function BackCard:ShowBackCard(isHaveBeishu)

print("设置底牌")
	for i=1,3 do
		local cardType, cardNumber = GameUtil:GetCardForPc(1)
        local Poker = PokerCard.new{ctype = cardType, number = cardNumber ,issmall=true}


		Poker:cover()
	
	    Poker:scale(self.BackCardScal)
	    if isHaveBeishu then
	    	Poker:setPosition(self.posBackCardPos[i].x,self.posBackCardPos[i].y)
	    else
	    	Poker:setPosition(self.posBackCardPosNo[i].x,self.posBackCardPosNo[i].y)
	    end
	    
	    self:addChild(Poker)
	    table.insert(self.Backcards,Poker)
	end

end




--加入一张牌(有一张明牌可直接设置显示)_
function BackCard:AddOneCard(carddata,isshow)

	
end
function BackCard:SetbackCarddata(data)

    self.BackCardCount=0
	for i=1,3 do
		local cardType, cardNumber = GameUtil:GetCardForPc(data[i])

	    if self.Backcards[i]:isCover() then
		self.Backcards[i]:modify(cardType, cardNumber)
		self.Backcards[i]:open()
	    
	    end
	end

end
function BackCard:SetOpenbackCard(data)

    self.BackCardCount=0
	for i=1,3 do
		local cardType, cardNumber = GameUtil:GetCardForPc(data[i])

	    if self.Backcards[i]:isCover() then
		self.Backcards[i]:modify(cardType, cardNumber)
	    
        --决定牌大小
	   	local Turndelay=0.1+0.12*i

	    local args=
	    {
	      --Turndelay=Turndelay,
	      isTurnOpen=true,
	      TurnOpenEndHandler= handler(self,self.OpenBackCardfinish),--结束回调处理
	    }
	    self.Backcards[i]:doTurnOpenHeapCardAnimation(args)

	    end
	end

end
--获取类型和倍数描述
function BackCard:GetCardTypeAndScore(type,score)
	-- body
	local typename=""
	local scorename=""
	if type==7 then
		typename="双王"
		scorename=score.."倍"
	end
	if type==6 then
		typename="全小"
		scorename=score.."倍"
	end
	if type==5 then
		typename="三条"
		scorename=score.."倍"
	end
	if type==4 then
		typename="同花"
		scorename=score.."倍"
	end
	if type==3 then
		typename="顺子"
		scorename=score.."倍"
	end
	if type==2 then
		typename="对二"
		scorename=score.."倍"
	end
	if type==1 then
		typename="单王"
		scorename=score.."倍"
	end
    

    return typename,scorename
end

--清空数据重置NODE
function BackCard:ClearBackCard()
	for i=1,table.getn(self.Backcards) do
        self:removeChild(self.Backcards[i])
	end
	self.PokerCards={}
end

--翻开底牌回调
function BackCard:OpenBackCardfinish(sender)
   self.BackCardCount=self.BackCardCount+1
   if self.BackCardCount==3 then
   	--通知到场景
    AppBaseInstanse.ErRenLandApp.EventCenter:dispatchEvent({
        name = self.Event.OPEN_BACK_CARD_FINISH,
    })
    self.BackCardCount=0
   end

end



return BackCard