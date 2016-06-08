--
-- 扑克牌的model
-- Author: tanjl
-- Date: 2015-09-11 15:14:01
--

local PokerCard = class("PokerCard", function(args)
	local animationCard 

	if args.issmall then
		animationCard = ccs.Armature:create("AnimationCard2")
	else
		animationCard = ccs.Armature:create("AnimationCard")
	end
	
	
	local touchNode = display.newNode()
	:align(display.CENTER, 0, 0)
	touchNode:size(animationCard:getContentSize())
	animationCard.touchNode = touchNode
	animationCard:addChild(animationCard.touchNode)
	return animationCard
end)

--扑克牌花色
PokerCardType = {
	CardTypeDiamond = 0,	-- 方块
	CardTypeClub = 1, 		-- 梅花
	CardTypeHeart = 2,		-- 红桃
	CardTypeSpade = 3, 		-- 黑桃
	CardTypeBack  = 5,      -- 背面
}

local cardUpDis = 28
-- 扑克牌对应图片前缀
local PrefixCardImageNames = {
	"diamond",		-- 方块
	"club", 		-- 梅花
	"heart",		-- 红桃
	"spade", 		-- 黑桃
}

--扑克牌序号列表
PokerCardNumber = {
	CardNumber_Ace = 1,
	CardNumber_Two = 2,
	CardNumber_Three = 3,
	CardNumber_Four = 4,
	CardNumber_Five = 5,
	CardNumber_Six = 6,
	CardNumber_Seven = 7,
	CardNumber_Eight = 8,
	CardNumber_Nine = 9,
	CardNumber_Ten = 10,
	CardNumber_Jack = 11,
	CardNumber_Queen = 12,
	CardNumber_King = 13,
}

-- 扑克牌花色
PokerCard.ctype = 0

-- 扑克牌序号
PokerCard.number = 0

--[[
	--ctype :牌的类型 
	--number :牌值 
	--clickHandler :点击事件处理
]]
function PokerCard:ctor(args)
	if args.ctype then
		self.ctype = args.ctype
	end

	if args.number then
		self.number = args.number
	end  


	if args.clickHandler then

   		--点击事件
   		self.touchNode:setTouchEnabled(true)
		self.touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT,handler(self, self.onClickCard))
		
    	self.clickHandler = args.clickHandler
	end

	-- 加载资源
	self:open() 

	self.status = 0

	self.statustemp=0

	self.hight=0

    self.IsNew=false
	--self.imagePress  = ccui.ImageView:create():addTo(self)
	--self.imagePress:loadTexture("ys9zhang/u_game_bg_card_press.png")
	--self.imagePress:setVisible(false)
	-- 默认30度倾斜
	--self:set3DRotationAngle(30)
	--for tesst
	--local color = display.newSprite("ys9zhang/u_game_bg_cardb.png"):addTo(self)
	--color:setPosition(cc.p(10,10))
	--color:setContentSize(self:getContentSize().width, self:getContentSize().height)
	
	--self.retctArea = display.newRect(cc.rect(self:getContentSize().width, self:getContentSize().height,self:getContentSize().width/2,self:getContentSize().height/2), {fillColor=cc.c4f(255, 0, 0, 0.5)})
	--self.retctArea:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
	--self:addChild(self.retctArea)
end

function PokerCard:updateTouchSize()
	local size = self:getContentSize()
	self.touchNode:size(self:getContentSize())
end
-- 判断两张扑克牌是否相同, 花色相同和数字相等即相同
-- other	另外比较的牌
function PokerCard:sameAs( other )
	if self.ctype == other.ctype and self.number == other.number then
		return true
	end
	return false
end

function PokerCard:onClickCard(args)
	--dump(args)
	if self.clickHandler then
		self.clickHandler(self,args.name,args.x,args.y)
	end
	return true
end

function PokerCard:set3DRotationAngle(angle)
	self:setRotation3D({x = 0-angle, y=0, z=0})
end

-- 比较花色是否相同, 相同返回true
-- other	另外比较的牌
function PokerCard:sameTypeAs( other )
	return self.ctype == other.ctype
end

-- 比较两张牌的大小 
-- other	另外比较的牌
-- 自己比other大    返回1
-- 自己和other相等  返回0
-- 自己比other小    返回-1
function PokerCard:compare( other )
	if self.number > other.number then
		return 1
	elseif self.number < other.number then 
		return -1
	else
		return 0
	end
end

-- 根据花色和数字获取图片
function PokerCard:getCardAnimation( ctype, number )
	local aniName = nil
	if ctype and number then	
		aniName = string.format("card_%d_%d",ctype,number)
	end
	return aniName
end

-- 盖住
function PokerCard:cover()
    self:getAnimation():play("card_5_0",-1,-1)
    self.isOpen = false
end
function PokerCard:Setland()
	---------------
	local LandSprite=ccui.ImageView:create()
	LandSprite:loadTexture("errenland/LandCard.png",0)
	LandSprite:setPosition(21,-40)
    self:addChild(LandSprite,10)

end
function PokerCard:SetBackCard(cbbkcard)
	self.backCard=cbbkcard
end
function PokerCard:IsBackCard()
	return self.backCard
end
-- 打开
function PokerCard:open()
	--print("颜色",self.ctype,self.number)
	--设置值并显示
	local aniName = self:getCardAnimation(self.ctype, self.number)
	if aniName then
    	self:getAnimation():play(aniName,-1,-1)
    	self.isOpen = true
	end
end

--修改牌的类型与值
function PokerCard:modify(ctype,number)
	if self.ctype then
		self.ctype = ctype
	end
	if self.number then
		self.number = number
	end
end

-- args :
-- {startPos :		起始位置
--  endPos :		结束位置
--  delay :			延迟时间
--  isTurnOpen :	最后是否翻开牌
-- }
--发牌
function PokerCard:dealCard(args)
	args.isVisibleFirst = false
	self:doCardAnimation(args)
end

-- args :
-- {startPos :		起始位置
--  endPos :		结束位置
--  delay :			延迟时间
--  isTurnOpen :	最后是否翻开牌
-- }
--翻牌
function PokerCard:turnOverCard(args)
	args.isVisibleFirst = true
	self:doCardAnimation(args)
end

-- 原地翻转
function PokerCard:turnOverInPlace(interval)
	local actionArray = {}
	local op = self.isOpen and cc.CallFunc:create(handler(self, self.cover)) or cc.CallFunc:create(handler(self, self.open)) 
	local _zoomOut = cc.OrbitCamera:create(interval/2, 1, 0, 0, 90, 0, 0)
	local _zoomIn = cc.OrbitCamera:create(interval/2, 1, 0, -90, 90, 0, 0)
	table.insert(actionArray, _zoomOut)
	table.insert(actionArray, op)
	table.insert(actionArray, _zoomIn)
	local seq = cc.Sequence:create(actionArray)
	self:runAction(seq)
end

-- args :
-- {startPos :		起始位置
--  endPos :		结束位置
--  delay :			延迟时间
--  isTurnOpen :	最后是否翻开牌
--moveEndHandler:   移动结束回调处理
--  isVisibleFirst :起始显示(发牌隐藏,翻牌显示)
-- }
function PokerCard:SetCardMoveToPos(pos)

	if self.IsNew==false then
		self:setPosition(pos.x, pos.y)
		self.IsNew=true
	else
		self:CardMoveTo(pos)
	end

	   --self.oldpos=self:getPosition()
	--if pos==cc.p(0,0) then
		--self:setPosition(pos.x, pos.y)

		

		
	--end
end
function PokerCard:CardMoveTo(pos)
	local _mt = cc.MoveTo:create(0.06, pos)
	self.discardMove=self:runAction(_mt)
end
--发牌
function PokerCard:doCardAnimation(args)
	local actionArray = {}
	self:setPosition(args.startPos)
	local cardScale = self:getScale()
	--延迟发牌
	if args.delay ~= nil then
		self:setVisible(isVisibleFirst)
		local _dt = cc.DelayTime:create(args.delay)
		table.insert(actionArray,_dt)
		local _show = cc.CallFunc:create(handler(self, self.show))
		table.insert(actionArray,_show)
	end
	--计算运动时间
	local moveTime = cc.pGetDistance(args.endPos, args.startPos) / 900
	local _mt = cc.MoveTo:create(moveTime, args.endPos)
	table.insert(actionArray,_mt)
	--是否在最后翻开
	if args.isTurnOpen ~= nil and args.isTurnOpen then
		--先盖住
		self:cover()
		local _zoomOut = cc.OrbitCamera:create(0.2, 1, 0, 0, 90, 0, 0)--cc.ScaleTo:create(0.2, 0, cardScale)
		local _open = cc.CallFunc:create(handler(self, self.open))
		local _zoomIn = cc.OrbitCamera:create(0.2, 1, 0, -90, 90, 0, 0)--cc.ScaleTo:create(0.2, cardScale, cardScale)
		table.insert(actionArray,_zoomOut)
		table.insert(actionArray,_open)
		table.insert(actionArray,_zoomIn)
	end
	
	--移动到终点的回调
	if args.moveEndHandler then
		self.moveEndHandler = args.moveEndHandler
		local _moveEnd = cc.CallFunc:create(args.moveEndHandler)
		table.insert(actionArray,_moveEnd)
	end

	if not args.isTurnOpen then
		local scaleto = cc.ScaleTo:create(moveTime,0.34)
		local _spawn = cc.Spawn:create{cc.Sequence:create(actionArray),scaleto}
		self:runAction(_spawn)
	else
		local _seq = cc.Sequence:create(actionArray)
		self:runAction(_seq)
	end
	
end

-- args :
-- {startPos :		起始位置
--  endPos :		结束位置
--  ToScale :		目标大小
--  delay :			延迟时间
--  isTurnOpen :	最后是否翻开牌
--moveEndHandler:   移动结束回调处理
--  isVisibleFirst :起始显示(发牌隐藏,翻牌显示)
-- }
--发牌
function PokerCard:doDispacthCardAnimation(args)
	local actionArray = {}
	self:setPosition(args.startPos)

	--延迟发牌
	if args.delay ~= nil then
		--self:setVisible(isVisibleFirst)
		local _dt = cc.DelayTime:create(args.delay)
		table.insert(actionArray,_dt)
		--local _show = cc.CallFunc:create(handler(self, self.show))
		--table.insert(actionArray,_show)
	end
	--计算运动时间

	local moveTime = cc.pGetDistance(args.endPos, args.startPos) / 3000
	local _mt = cc.MoveTo:create(moveTime, args.endPos)
	local scaleto = cc.ScaleTo:create(moveTime, args.ToScale)
	local _spawn = cc.Spawn:create{scaleto,_mt}
	table.insert(actionArray,_spawn)

	--是否在最后翻开
	if args.isTurnOpen ~= nil and args.isTurnOpen then
		--先盖住
		self:cover()
		local _zoomOut = cc.OrbitCamera:create(0.2, 1, 0, 0, 90, 0, 0)--cc.ScaleTo:create(0.2, 0, cardScale)
		local _open = cc.CallFunc:create(handler(self, self.open))
		local _zoomIn = cc.OrbitCamera:create(0.2, 1, 0, -90, 90, 0, 0)--cc.ScaleTo:create(0.2, cardScale, cardScale)
		table.insert(actionArray,_zoomOut)
		table.insert(actionArray,_open)
		table.insert(actionArray,_zoomIn)
	end
	
	--移动到终点的回调
	if args.moveEndHandler then
		self.moveEndHandler = args.moveEndHandler
		local _moveEnd = cc.CallFunc:create(args.moveEndHandler)
		table.insert(actionArray,_moveEnd)
	end


	local _seq = cc.Sequence:create(actionArray)
	self:runAction(_seq)
	

	
end
-- args :
-- {
--startPos :		起始位置
--  endPos :		结束位置
--  moveEndHandler:   移动结束回调处理
-- }
--发牌
function PokerCard:doHeapCardAnimation(args)
	local actionArray = {}
	self:setPosition(args.startPos)
	local cardScale = self:getScale()



	--计算运动时间
	local moveTime = cc.pGetDistance(args.endPos, args.startPos) / 900
	local _mt = cc.MoveTo:create(moveTime, args.endPos)
	table.insert(actionArray,_mt)

	--移动到终点的回调
	if args.moveEndHandler then
		self.moveEndHandler = args.moveEndHandler
		local _moveEnd = cc.CallFunc:create(args.moveEndHandler)
		table.insert(actionArray,_moveEnd)
	end
	local _seq = cc.Sequence:create(actionArray)
	self:runAction(_seq)
end
-- args :
-- {
--startPos :		起始位置
--  endPos :		结束位置
--Turndelay
--isTurnOpen
--TurnOpenEndHandler
--  moveEndHandler:   移动结束回调处理
-- }
--先翻牌再移动
function PokerCard:doTurnOpenHeapCardAnimation(args)
	local actionArray = {}
	--self:setPosition(args.startPos)
	local cardScale = self:getScale()

	--是否在最后翻开
	if args.isTurnOpen ~= nil and args.isTurnOpen then
		--先盖住
		self:cover()
		local _zoomOut = cc.ScaleTo:create(0.1, 0, cardScale)--cc.OrbitCamera:create(0.2, 1, 0.5, 0, 90, 0, 0)
		local _open = cc.CallFunc:create(handler(self, self.open))
		local _zoomIn =cc.ScaleTo:create(0.1, cardScale, cardScale)-- cc.OrbitCamera:create(0.2, 1, 0.5, -90, 90, 0, 0)
		table.insert(actionArray,_zoomOut)
		table.insert(actionArray,_open)
		table.insert(actionArray,_zoomIn)
	end

    --翻牌完成的回调
	if args.TurnOpenEndHandler then
		local _OpenEnd = cc.CallFunc:create(args.TurnOpenEndHandler)
		table.insert(actionArray,_OpenEnd)
	end

	local _seq = cc.Sequence:create(actionArray)
	self:runAction(_seq)
end

function PokerCard:isCover()
	return not self.isOpen
end

function PokerCard:show()
	self:setVisible(true)
end

function PokerCard:setTuoGuanstatus(tuoguan)

	if tuoguan==true then
		--todo
		self:Pressed()
	else
		self:unPressed()
	end
end
--弹起变换
function PokerCard:setSelect(select)
	self.select=select
	if self.select==true then
		--todo
		self:Pressed()
	else
		self:unPressed()
	end
end
--弹起变换不真正弹起 用于检索划牌
function PokerCard:setShootTemp()
	self.statustemp=1
end
--弹起变换不真正弹起 用于检索划牌
function PokerCard:getShootTemp()
	return self.statustemp
end
function PokerCard:getShootHight( )
	return cardUpDis
end

--弹起变换
function PokerCard:setBackCardShootDown()

	
	
	local actionArray = {}
	local _dt = cc.DelayTime:create(0.3)
	table.insert(actionArray,_dt)
	local mb = cc.MoveBy:create(0.3, cc.p(0, -1*cardUpDis))
	table.insert(actionArray,mb)
	local _seq = cc.Sequence:create(actionArray)
	self.LowDownAction=self:runAction(_seq)

end

function PokerCard:setShootstatus(status)
	self.status = status
	if self.LowDownAction~=nil then
		self:stopAction(self.LowDownAction)
	end

	if self.discardMove~=nil then
		self:stopAction(self.discardMove)
	end
end
--弹起变换
function PokerCard:setShoot(doanimation)
	if  self.status == 0 then
		self.status = 1

		if doanimation then
			--local mb = cc.MoveBy:create(0.0, cc.p(0, cardUpDis))
			local y=self:getPositionY()
			y=y+cardUpDis
			self:setPositionY(y)
		    self:unPressed()
		    --self:runAction(mb)
		end
		
	else
		self.status = 0
		if doanimation then

			local y=self:getPositionY()
			y=y-cardUpDis
			self:setPositionY(y)
			--local mb = cc.MoveBy:create(0.0, cc.p(0, -1*cardUpDis))
			self:unPressed()
			--self:runAction(mb)
		end
		
	end	
end

function PokerCard:getStatus()
	return self.status
end

function PokerCard:Pressed()
	--print("PokerCard:Pressed"..self.ctype..self.number)
	if not self.isPressed then
		self:setColor(cc.c4b(143,144,138,0.2*255))
		self.isPressed = true
	end
end

function PokerCard:unPressed()
	--print("PokerCard:unPressed"..self.ctype..self.number)
	if self.isPressed then
		self:setColor(cc.c4b(255,255,255,255))
		self.isPressed = false
	end
end

function PokerCard:disable()
	self:setColor(cc.c4b(0,0,0,255*0.5))
end

return PokerCard