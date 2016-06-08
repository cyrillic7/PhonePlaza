-- 
-- 游戏中牌桌座位视图
-- Author: tanjl
-- Date: 2015-09-11 19:08:14
--

local PlayerSeatView = class("PlayerSeatView", function()
		return ccui.Layout:create()
	  end)

-- args {
--      id   :坐位号
--		userID : 玩家USERID
--		name : 玩家名称
--      isMyself : 是否自己
--      countDownTimeInterval : 倒计时时间间隔
--      countDownHandler  : 倒计时的处理句柄
--		vipLevel : VIP等级
--		headId   : 头像ID
-- }
function PlayerSeatView:ctor(args)
	self.args = args

	self.id = args.id

	self.userId = args.userID

	self.isMyself = args.isMyself

	--if self.isMySelf then
	--	self:setTouchEnabled(true)
	--end

	if args.touchEventHandler then
		self.touchEventHandler = args.touchEventHandler
	end

	self.countDownTimeInterval = args.countDownTimeInterval
	self.countDownHandler = args.countDownHandler
	self.clickHeadHandler = args.clickHeadHandler
	
	if not self.isMyself then
		self.headIcon = ccui.ImageView:create():addTo(self)
		self.headIcon:loadTexture(string.format("pic/face/%d.png",args.headId),1)
	   	self.headIcon:setScale(0.45)
	   	self.headIcon:setTouchEnabled(true)
	   --头像点击事件
		self.headIcon:addTouchEventListener(handler(self, self.onClickHead))

		self.bg =  ccui.ImageView:create():addTo(self)
		
		self.bg:loadTexture("ys9zhang/u_game_personal_bg.png",0)
	
		local  nameBg = ccui.Scale9Sprite:create("ys9zhang/u_game_translucent_bg3.png")
	    nameBg:setContentSize(cc.size(160,37))
	    nameBg:setPosition(cc.p(self.bg:getContentSize().width/2+nameBg:getContentSize().width/4,self.bg:getContentSize().height/2 + nameBg:getContentSize().height/2))
	    self.bg:addChild(nameBg)

	    self.nameText = ccui.Text:create()
	    self.nameText:setString(args.name)
	    self.nameText:setFontSize(25)
	    self.nameText:setPosition(cc.p(nameBg:getContentSize().width/2,nameBg:getContentSize().height/2))
	    nameBg:addChild(self.nameText)

	    local  goldBg = ccui.Scale9Sprite:create("ys9zhang/u_game_translucent_bg1.png")
	    goldBg:setContentSize(cc.size(160,25))
	    goldBg:setPosition(cc.p(nameBg:getPositionX(),nameBg:getPositionY()-nameBg:getContentSize().height/2 - goldBg:getContentSize().height/2 - 10))
	    self.bg:addChild(goldBg)

	    self.goldIcon = ccui.ImageView:create()
	    self.goldIcon:loadTexture("ys9zhang/u_game_gold.png",0)
	    self.goldIcon:setPosition(cc.p(self.goldIcon:getContentSize().width/2,goldBg:getContentSize().height/2))
	    goldBg:addChild(self.goldIcon)

	 	--金币
	    self.goldText = ccui.Text:create()
	    self.goldText:setString(tostring(args.score))
	    self.goldText:setFontSize(25)
	    self.goldText:setColor(cc.c3b(255,255,0))
	    self.goldText:setPosition(cc.p(goldBg:getContentSize().width/2,goldBg:getContentSize().height/2))
	    goldBg:addChild(self.goldText)
	else
		self.headIcon = ccui.ImageView:create():addTo(self)
		self.headIcon:loadTexture(string.format("pic/face/%d.png",args.headId),1)
	   	self.headIcon:setScale(0.45)
	   	self.headIcon:setTouchEnabled(true)
	   --头像点击事件
		self.headIcon:addTouchEventListener(handler(self, self.onClickHead))

		self.bg =  ccui.ImageView:create():addTo(self)
		self.bg:setPosition(cc.p(-95,0))
		self.bg:loadTexture("ys9zhang/u_game_personal_bgmy.png",0)
	
		local  nameBg = ccui.Scale9Sprite:create("ys9zhang/u_game_translucent_bg3.png")
	    nameBg:setContentSize(cc.size(200,37))
	    nameBg:setPosition(cc.p(100+self.bg:getContentSize().width/2+nameBg:getContentSize().width/4,self.bg:getContentSize().height/2 - nameBg:getContentSize().height/2 + 10 ))
	    self.bg:addChild(nameBg)

	    self.nameText = ccui.Text:create()
	    self.nameText:setString(args.name)
	    self.nameText:setFontSize(25)
	    self.nameText:setPosition(cc.p(nameBg:getContentSize().width/2,nameBg:getContentSize().height/2))
	    nameBg:addChild(self.nameText)

	    local  goldBg = ccui.Scale9Sprite:create("ys9zhang/u_game_translucent_bg3.png")
	    goldBg:setContentSize(cc.size(200,37))
	    goldBg:setPosition(cc.p(nameBg:getPositionX()+240,nameBg:getPositionY()))
	    self.bg:addChild(goldBg)

	    self.goldIcon = ccui.ImageView:create()
	    self.goldIcon:loadTexture("ys9zhang/u_game_gold.png",0)
	    self.goldIcon:setPosition(cc.p(self.goldIcon:getContentSize().width/2,goldBg:getContentSize().height/2))
	    goldBg:addChild(self.goldIcon)

	 	--金币
	    self.goldText = cc.LabelAtlas:_create("0","ys9zhang/u_game_num_card.png",17,24,string.byte("0"))
	    self.goldText:setString(tostring(args.score))
	    self.goldText:setAnchorPoint(cc.p(0.5,0.5))
	    self.goldText:setPosition(cc.p(goldBg:getContentSize().width/2,goldBg:getContentSize().height/2))
	    goldBg:addChild(self.goldText)
	end
   
	-- 是否在倒计时中
	self.isCountdowning = false

	self.leftTime = ccui.ImageView:create()
    self.leftTime:loadTexture("ys9zhang/u_game_icon_clock.png",0)
    self.leftTime:setVisible(false)
    if self.isMyself then
    	self.leftTime:setPosition(cc.p(40,70))
    else
    	self.leftTime:setPosition(cc.p(0,-100))
    end
    self:addChild(self.leftTime)

    self.labelTime = cc.LabelAtlas:_create("0:","ys9zhang/u_game_num_clock.png",20,27,string.byte("0"))
    self.labelTime:align(display.CENTER, self.leftTime:getContentSize().width/2,self.leftTime:getContentSize().height/2-5)
    self.leftTime:addChild(self.labelTime)

    self.alarmBg = ccui.ImageView:create()
    self.alarmBg:loadTexture("ys9zhang/u_game_icon_alarm2.png",0)
    self.alarmBg:setVisible(false)
    self:addChild(self.alarmBg)

    self.imageAlram = ccui.ImageView:create()
    self.imageAlram:loadTexture("ys9zhang/u_game_icon_alarm1.png",0)
    self.imageAlram:setPosition(cc.p(self.alarmBg:getContentSize().width/2,self.alarmBg:getContentSize().height/2))
    self.alarmBg:addChild(self.imageAlram)
    --app.notificationCenter:addEventListener("APP_STAY_BACKGROUND", handler(self, self.receiveEnterForegroundMessage))

    --聊天框
	self.messageWindow = ccui.ImageView:create():addTo(self)
	self.messageWindow:setVisible(false)
	self.messageWindow:setLocalZOrder(99)

	--文字型
	self.Label = ccui.Text:create()
	self.Label:setFontSize(15)
	self.Label:setAnchorPoint(cc.p(0.5,0.5))
	self.messageWindow:addChild(self.Label)
	self.Label:setVisible(false)

	--图片型
	self.Image = ccui.ImageView:create()
	self.Image:setAnchorPoint(cc.p(0.5,0.5))
	self.messageWindow:addChild(self.Image)
	self.Image:setVisible(false)

end

--[[ 礼物按钮点击后回调
function PlayerSeatView:giftButtonTouched(sender, touchType)
    if touchType == TOUCH_EVENT_ENDED then
    	self.giftTouchEventHandler(self)
    end
end]]

function PlayerSeatView:onClickHead(sender, touchType)
	if touchType == TOUCH_EVENT_ENDED then
		print("onClickHead")
		self.clickHeadHandler(self,self.userId)
   	end
end

-- 开始倒计时
-- 如果原本就在倒计时，则先复位
function PlayerSeatView:start()
	print("PlayerSeatView:start"..self.countDownTimeInterval)
	if self.countDownTimeInterval > 0 then
		self.isCountdowning = true

		self.leftTime:setVisible(true)
		self.labelTime:setString(tostring(self.countDownTimeInterval))
		if not self.schedulerId then
			self.schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.countdown), 1 , false)
		end
	end
end

function PlayerSeatView:receiveEnterForegroundMessage(event)
	if self.isCountdowning then
		self:countdown(event.para)
	end
end

-- 停止倒计时, delete时必须先调用stop方法，否则此精灵不会被释放
function PlayerSeatView:stop( )
	print("PlayerSeatView:stop()")
	self.leftTime:setVisible(false)
	-- 从后台进入前台时，需要把在后台的时间计算入倒计时，所以有这个listener
	--app.notificationCenter:removeEventListener(handler(self, self.receiveEnterForegroundMessage))

	-- 这个schedule必须释放掉
	if self.schedulerId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil
	end
end

-- 添加手牌组视图
function PlayerSeatView:addCardInfoView( cardInfoView )
	self.cardInfoView = cardInfoView
	if cardInfoView then
		--self:resetCardInfoViewPos()
		self.cardInfoView:setTableSide(self.tableSide)
		self:addChild(cardInfoView)
	end
end

--添加出牌组视图
function PlayerSeatView:addOutCardView(outCardView)
	self.outCardView = outCardView
	if outCardView then
		self.outCardView:setTableSide(self.tableSide)
		self:addChild(outCardView)
	end
end

function PlayerSeatView:getOutCardView()
	return self.outCardView
end

function PlayerSeatView:getCardView()
	return self.cardInfoView
end

-- 时间到
function PlayerSeatView:countDownEnd()
    self.countDownHandler(self)
end

--设置倒计时时间隔
function PlayerSeatView:setCountDownTimeInterval(interval)
	self.countDownTimeInterval = interval
end

-- 计时
function PlayerSeatView:countdown( dt )
	if self.leftTime then
		if self.countDownTimeInterval > 0 then
			self.countDownTimeInterval = self.countDownTimeInterval - 1
			self.labelTime:setString(tostring(self.countDownTimeInterval))
		else
			self:stop()
			-- 玩家操作超时后，显示一个闪烁的红点
			--[[if not self.countDownEndIndicator and not self.isMyself then
				self.countDownEndIndicator = cc.DrawNode:create()

				-- 美术的图有问题，没对齐
				if self.isRound and self.isMyself then
					self.countDownEndIndicator:drawDot(CCPoint(0, 70), 4, cc.c4f(1, 0, 0, 1))
				else
					self.countDownEndIndicator:drawDot(CCPoint(0, 74), 4, cc.c4f(1, 0, 0, 1))
				end
				self:addChild(self.countDownEndIndicator, 100)

				-- 先等待一下，感觉自然一点
				local delay = cc.DelayTime:create(1)

				-- 永久闪烁, 闪一小时够了吧。
				local blink = cc.Blink:create(3600, 4000)

				self.countDownEndIndicator:runAction(transition.sequence{delay,blink})
			end]]

			-- 玩家操作超时处理
			self:countDownEnd()
		end
	end
end

-- 设置头像
function PlayerSeatView:setPlayerHead( icon )
	
end

function PlayerSeatView:setPos( pos )
	if pos then
		self:setPosition(pos)
		if pos.x <= display.cx then
			if  pos.x == display.cx then
				self.tableSide = PokerTableSide.middle
			else
				self.tableSide = PokerTableSide.left
			end
			if not self.isMyself then
				self.headIcon:setPosition(cc.p(self.headIcon:getPositionX() - self.bg:getContentSize().width/2 + 5 + self.headIcon:getContentSize().width*self.headIcon:getScale()/2,self.bg:getPositionY()+2))
			else
				self.headIcon:setPosition(cc.p(-95+self.headIcon:getPositionX() - self.bg:getContentSize().width/2 + 5 + self.headIcon:getContentSize().width*self.headIcon:getScale()/2,self.bg:getPositionY()+2))
			end
			--设置聊天框
			if self.tableSide == PokerTableSide.middle then
				self.messageWindow:loadTexture("Common/chat/chatc_r.png")
				self.messageWindow:setPosition(cc.p(-125 - self.messageWindow:getContentSize().width + self:getContentSize().width/2, 30- self.messageWindow:getContentSize().height/2 + self:getContentSize().height/2))
				self.messageWindow:setAnchorPoint(cc.p(0, 0))

				local messgePos = cc.p(self.messageWindow:getContentSize().width / 2, self.messageWindow:getContentSize().height / 2 + 5)
				self.Label:setPosition(messgePos)
				self.Image:setPosition(messgePos)
			else
				self.messageWindow:loadTexture("Common/chat/chatc_l.png")
				self.messageWindow:setPosition(cc.p(20 - self.messageWindow:getContentSize().width/2 + self:getContentSize().width/2, 80 - self.messageWindow:getContentSize().height/2 + self:getContentSize().height/2))
				self.messageWindow:setAnchorPoint(cc.p(0, 0))

				local messgePos = cc.p(self.messageWindow:getContentSize().width / 2, self.messageWindow:getContentSize().height / 2 + 5)
				self.Label:setPosition(messgePos)
				self.Image:setPosition(messgePos)
			end

		else
			self.tableSide = PokerTableSide.right
			self.bg:setFlippedX(true)
			--设置聊天框
			self.messageWindow:loadTexture("Common/chat/chatc_r.png")
			self.messageWindow:setPosition(cc.p(-20 + self.messageWindow:getContentSize().width/2 + self:getContentSize().width/2, 80 - self.messageWindow:getContentSize().height/2  + self:getContentSize().height/2))
			self.messageWindow:setAnchorPoint(cc.p(1, 0))

			local messgePos = cc.p(self.messageWindow:getContentSize().width/2, self.messageWindow:getContentSize().height / 2 + 5)
			self.Label:setPosition(messgePos)
			self.Image:setPosition(messgePos)

			if not self.isMyself then
		    	self.headIcon:setPosition(cc.p(self.headIcon:getPositionX() + self.bg:getContentSize().width/2-5 - self.headIcon:getContentSize().width*self.headIcon:getScale()/2,self.bg:getPositionY()+2))
		    	self.nameText:setFlippedX(true)
		    	self.goldText:setFlippedX(true)
		    	self.goldIcon:setFlippedX(true)
		    	self.goldIcon:setPosition(cc.p(self.goldIcon:getPositionX() + self.goldIcon:getParent():getContentSize().width -  self.goldIcon:getContentSize().width,self.goldIcon:getPositionY()))
		    end
		end
		
		--设置报警器的位置 
		if not self.isMyself then
			if self.tableSide == PokerTableSide.middle then
				self.alarmBg:setPosition(cc.p(-self.bg:getContentSize().width/2 - self.alarmBg:getContentSize().width/2,0))
			elseif self.tableSide == PokerTableSide.left then
				self.alarmBg:setPosition(cc.p(self.bg:getContentSize().width/2 + self.alarmBg:getContentSize().width/2,0))
			elseif self.tableSide == PokerTableSide.right  then
				self.alarmBg:setPosition(cc.p(-self.bg:getContentSize().width/2 - self.alarmBg:getContentSize().width/2,0))
			end
		else
			self.alarmBg:setPosition(cc.p(100,50))
		end
		
		
	end
end

function PlayerSeatView:showAlarm(isVisible)
	self.alarmBg:setVisible(isVisible)
	if isVisible then
		local blink = cc.Blink:create(3600, 4000)
    	self.imageAlram:runAction(blink)
	else
		self.imageAlram:stopAllActions()
	end
end

function PlayerSeatView:sayMessage(args)
	self.messageWindow:stopAllActions()
	if self.labelContent then
		self.labelContent:setVisible(false)
	end
	if args.messageType == 0 then
		self.Label:setString(args.message)
		if self.Label:getContentSize().width > self.messageWindow:getContentSize().width then
			if not self.labelContent then
				self.labelContent = cc.LabelTTF:create(args.message, "Arail Regular", 15, cc.size(self.messageWindow:getContentSize().width-20, 50), cc.TEXT_ALIGNMENT_LEFT)
				self.labelContent:setColor(self.Label:getColor())
				self.labelContent:setPosition( cc.p(self.Label:getPositionX(),self.Label:getPositionY()))
				self.messageWindow:addChild(self.labelContent)
			end
			self.labelContent:setString(args.message)
			self.labelContent:setVisible(true)
			self.Image:setVisible(false)
			self.Label:setVisible(false)
		else
			self.Label:setVisible(true)
			self.Image:setVisible(false)
		end
		
	else
		self.Image:loadTexture("Common/chat/chat_"..args.message..".png")
		self.Image:setVisible(true)
		self.Label:setVisible(false)
	end
	self.messageWindow:setVisible(true)
	local actionArray = {}
	self.messageWindow:setScale(0)
	local _scale = cc.ScaleTo:create(0.3, 1)
	table.insert(actionArray,_scale)
	--6秒后自动隐藏
	local _dt = cc.DelayTime:create(6)
	table.insert(actionArray,_dt)
	local _scaleSmall = cc.ScaleTo:create(0.3, 0)
	table.insert(actionArray,_scaleSmall)
	local _callHide = cc.CallFunc:create(handler(self, self.hideMessage))
	table.insert(actionArray,_callHide)
	local _seq = cc.Sequence:create(actionArray)
	self.messageWindow:runAction(_seq)
end

function PlayerSeatView:hideMessage()
	self.messageWindow:setVisible(false)
end

function PlayerSeatView:updateHeadInfo( userInfo)
	self.goldText:setString(tostring(userInfo.lScore))
end

return PlayerSeatView