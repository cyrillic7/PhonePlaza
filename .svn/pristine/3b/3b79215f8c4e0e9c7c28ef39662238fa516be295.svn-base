
local CardControl =class("CardControl", function()
    return display.newLayer()end)


local PokerCard = import("..Kernel.PokerCard")
local GameLogic = import("..Kernel.GameLogic")

function CardControl:ctor()
    self.PokerCards={}
    self.Carddata={}
    self.Shoot = {}
    self.cbOXCardCount = 0
    self.OXCarddata = {}
    self.cbCardCount = 0
    self:setTouchEnabled(false)
end

--设置牌数据
function CardControl:SetCardData(CardData,count)
    self.cbCardCount = count 
    self.Carddata=CardData
end 
--加入一张牌
function CardControl:AddOneCard(carddata,show)
    --初始化这张牌
    local cardType, cardNumber = GameUtil:GetCardForPc(carddata)
    --print("cardType,= cardNumber=" .. cardType .. cardNumber)
    local Poker = PokerCard.new{ctype = cardType, number = cardNumber ,clickHandler = handler(self, self.OnClickOneCard)}

    Poker:setScale(0.3)
    --牌数据
    table.insert(self.Carddata,carddata)
    --牌元素
    table.insert(self.PokerCards,Poker)
    table.insert(self.Shoot,false) 
    self.cbCardCount=5 
    Poker:cover()
    Poker:setPosition(display.cx,display.cy) 
    self:addChild(Poker)

    self.Event =
        {
            SEND_ONE_CARD = "SEND_ONE_CARD_FINISH",
            SEND_CARD_FINISH = "SEND_CARD_FINISH"
        }
    return Poker
end

function CardControl:FreeControl()
    --self:ResetCardPos()
    self:removeAllChildren()
    self.PokerCards={}
    self.Carddata = {} 
end

function CardControl:getShootCard()

    for key, var in pairs(self.PokerCards) do
        if var:getselect()then
            return self.Carddata[key]
        end
    end
    return nil
end

--点击牌
function CardControl:OnClickOneCard(s,msgtype,x,y)
    print("点击牌")
    if self.EnableTouch==false then
        --print("cardnumber1"..sender.number)
        return false
    end
    --dump(msgtype)
    --local CardCount=table.getn(self.Carddata)
    if msgtype=="began" then
        if not s:getselect() then
            s:setSelect()
        else
            s:setunSelect()
        end
        for key, var in pairs(self.PokerCards) do
            if var:getselect() and var ~= s then
                var:setunSelect()
            end
        end
    end
end

function CardControl:GetShootCardCount(bCardData,bShoot)
    --变量定义
    local cbShootCount=0

    --拷贝扑克
    for i=1,self.cbCardCount do 
        if self.Shoot[i] then
            cbShootCount = cbShootCount + 1
            bCardData[cbShootCount] = self.cbCardData[i]
        end
    end

    return cbShootCount
end

function CardControl:setUnSelected()
    for key, var in pairs(self.PokerCards) do
        if var:getselect() then
            var:setunSelect()
        end
    end
end

function CardControl:SetShootCard(cbCardData,cbCardCount)
 
    local bChangeStatus=false;
     
    --收起扑克
    self:setUnSelected()  
 
    for  i=1,cbCardCount do 
        for j=1,self.cbCardCount do
            if self.Shoot[j]==false and self.cbCardData[j]==cbCardData[i] then  
                bChangeStatus=true
                self.Shoot[j]=true
            end
        end
    end

    return bChangeStatus
end 

--删除牌
function CardControl:RemoveCard(count,carddata)
    local CardCount=table.getn(self.Carddata) 
end

function CardControl:SetPositively(param)
    self.isPositively = param
end

--重新设置卡牌
function CardControl:OnChangeCard(oldCardData,newCardData)
    local cbFirData=oldCardData
    local cbSecData=newCardData
    if (cbFirData==0 or cbSecData==0) then
        return false
    end
    for i=1,OxTwoDefine.MAXCOUNT do
        if self.Carddata[i]==cbFirData then
            self.Carddata[i]=cbSecData
            print("cbSecData=================================" .. cbSecData)
            local cardType, cardNumber = GameUtil:GetCardForPc(cbSecData)
            self:modify(i,cardType, cardNumber)
            break
        end
    end
end

function CardControl:modify(index,cardType, cardNumber)
    self.PokerCards[index]:modify(cardType, cardNumber)
    self.PokerCards[index]:open()
end

function CardControl:Compara(a,b)
    print("aaaaaa=" ..  a)
    print("bbbbbb=" ..  b)
    if a.number>b.number then
        return true
    end
    if a.number==b.number then
        if a.ctype>b.ctype then
            return true
        end
    end
    return false
end
--排序
function CardControl:SortCard()
    table.sort(self.Carddata, function (a,b)
        self:Compara(a,b)
    end)
    --self:ResetCardPos()
    --dump(self.Carddata)
end

function CardControl:ResetCardPos()
    local CardCount=table.getn(self.PokerCards)
    local x = display.width-(CardCount-1)*self.CardDistance
    x=x/2
    local y= self.CardPos.y
    for i=1,CardCount do
        self.PokerCards[i]:zorder(i)
        self.PokerCards[i]:setPosition(x+(i-1)*self.CardDistance, y)
    end
end

function CardControl:SetScal(Scal)
    self.CardScal=Scal
    local CardCount = table.getn(self.PokerCards)
    for i=1,CardCount do
    --self.PokerCards[i]:setScale(Scal)
    end
end

--用户手牌的位置
function CardControl:SetStartPos(Pos)
    -- body
    self.CardPos=Pos
end
--用户手牌的间距
function CardControl:SetDistance(Distance)
    -- body
    self.CardDistance=Distance
end
--用户手牌的大小
function CardControl:SetScal(Scal)
    -- body
    self.CardScal=Scal
end
--设置是否显示牌
function CardControl:SetShow(isshow)
    -- body
    self.ShowCard=isshow
    print("显示卡牌")
    print("self.PokerCards" .. table.getn(self.PokerCards))
    --dump(self.Carddata)
    if #self.PokerCards > 0 then 
        for i=1,OxTwoDefine.MAXCOUNT do
            if isshow==true then
                self.PokerCards[i]:modify(GameUtil:GetCardForPc(self.Carddata[i]))
                self.PokerCards[i]:open()
            else
                self.PokerCards[i]:cover()
            end
            print("CardControl .. isshow" .. i)
        end
    end
end
--设置响应
function CardControl:SetCardTouchEnabled(enable)
    self.EnableTouch=enable
end

function CardControl:SetDisplayItem(id,enable)
    self.CardControl[id].bDisplayItem = enable
end

function CardControl:SetbShow(id,enable)
    self.CardControl[id].bShow = enable
end

function CardControl:SetbShowOX(id,enable)
    self.CardControl[id].bShowOX = enable
end

function CardControl:SetShootOXOpoker()
    for key, var in pairs(self.PokerCards) do
        if var:getselect() then
            var:setunSelect()
        end
    end
    local bTemp= {} 
    local bSum=0
    local CardCount=table.getn(self.PokerCards)
    for i=1 ,CardCount do
        bTemp[i]=GameLogic:GetCardLogicValue(self.Carddata[i])
        bSum =bTemp[i] +bSum
    end
    local index1,index2,index3
    for a=1, 3 do
        for b=a+1,4 do
            for c=b+1 ,5 do
                if((bTemp[a]+bTemp[b]+bTemp[c])%10 == 0) then 
                    if self.PokerCards[a] then
                        self.PokerCards[a]:setSelect()
                    end
                    if self.PokerCards[b] then
                        self.PokerCards[b]:setSelect()
                    end
                    if self.PokerCards[c] then
                        self.PokerCards[c]:setSelect()
                    end 
                    return
                end
            end
        end
    end
end

function CardControl:SetUserOxValue(val)
    self.oxValue = val
end 

function CardControl:SetShootOX()
    for key, var in pairs(self.PokerCards) do
        if var:getselect() then
            var:setunSelect()
        end
    end 
    for key, poker in pairs(self.PokerCards) do
    	if key > 3 then
            poker:setSelect()
--        else
--            poker:setunSelect()
    	end 
    end
end 
 
 


return CardControl