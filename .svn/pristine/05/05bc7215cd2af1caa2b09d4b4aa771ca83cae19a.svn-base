--
-- NPRoundOverView
-- Author: tjl
-- Date: 2014-09-24 9:20:01
--
--[[
NPRoundOverView
]]
local  NPRoundOverView = class("NPRoundOverView",function()
	return ccui.Widget:create()
end)


function NPRoundOverView:ctor(args)
	self:setContentSize(cc.size(display.width,display.height))
	self:setTouchEnabled(true)
	self:setSwallowTouches(true)

	self.app = AppBaseInstanse.NinePieceApp
	--注册消息
	self:registerEvents()
	
	
	

	self.workflow = args.workflow
	local powerInfo = args.powerInfo
	local score = args.scoreInfo
	--加个蒙板
	local shade = cc.LayerColor:create()
	shade:setColor(display.COLOR_BLACK)
	shade:setOpacity(180)
	--shade:setPosition(cc.p(-display.cx,-display.cy))
	self:addChild(shade)
	--bg
	local bg_full_path ="ys9zhang/u_bounced_bg1.png"
	local bg = ccui.Scale9Sprite:create(bg_full_path):addTo(self)
	bg:setContentSize(cc.size(570,380))
	bg:setPosition(cc.p(display.cx,display.cy-80))

	--[[self.overEffect = nil
	local aniName = nil
	if args.isWin then
		self.overEffect = ccs.Armature:create("OverWinAnimation"):addTo(self)
		aniName= "Animationwin"
		self.overEffect:getAnimation():setMovementEventCallFunc(handler(self,self.onAnimationEventOver))
		self.overEffect:setPosition(cc.p(display.cx,display.cy + 200))
	else
		self.overEffect = ccs.Armature:create("OverLoseAnimation"):addTo(self)
		aniName= "Animationlose"
		self.overEffect:setPosition(cc.p(display.cx,display.cy + 140))
	end
	self.overEffect:getAnimation():play(aniName,-1,-1)]]

	local imageTitle = ccui.ImageView:create():addTo(self)
	if args.isWin then
		imageTitle:loadTexture("ys9zhang/image_win.png",0)
	else
		imageTitle:loadTexture("ys9zhang/image_lose.png",0)
	end
	imageTitle:setPosition(cc.p(display.cx,display.cy + 120))

	local imageNick = ccui.ImageView:create():addTo(self)
	imageNick:loadTexture("ys9zhang/image_font_nick.png",0)
	imageNick:setPosition(cc.p(display.cx- 220,display.cy+20))
	--imageNick:setPosition(cc.p(display.cx- 220,340))

	local imageWin = ccui.ImageView:create():addTo(self)
	imageWin:loadTexture("ys9zhang/image_font_win.png",0)
	imageWin:setPosition(cc.p(display.cx- 70,display.cy+20))

	local imageScore = ccui.ImageView:create():addTo(self)
	imageScore:loadTexture("ys9zhang/image_font_score.png",0)
	imageScore:setPosition(cc.p(display.cx + 40,display.cy+20))

	local pos = cc.p(display.cx- 90,display.cy-20)
	for i=1,4 do
		local chairId = i-1
		local player = self.workflow:getPlayerByChairId(chairId)
		local playerData = player:getPlayerData()
		local itemBg = ccui.Scale9Sprite:create("ys9zhang/u_game_translucent_bg3.png"):addTo(self)
		itemBg:setContentSize(cc.size(343,37))
		itemBg:setPosition(cc.p(pos.x,pos.y -(i-1)*50))

		if self.workflow:getMyChairID() == chairId then
			--cc.rect(25,4,20,0)
			local itemMy = ccui.Scale9Sprite:create(cc.rect(20,14,20,1),"ys9zhang/u_game_bg_me_press.png"):addTo(self)
			itemMy:setContentSize(cc.size(346,42))
			itemMy:setPosition(cc.p(pos.x,pos.y -(i-1)*50))
		end
		local labelName = ccui.Text:create():addTo(itemBg)
		labelName:setString(G_TruncationString(playerData.szNickName,18))
	    labelName:setFontSize(24)
	    labelName:setColor(cc.c3b(255,255,255))
	    labelName:setAnchorPoint(cc.p(0,0.5))
   		labelName:setPosition(cc.p(10,itemBg:getContentSize().height/2))

   		local labelScore = ccui.Text:create():addTo(itemBg)
		labelScore:setString(tostring(score[i]))
	    labelScore:setFontSize(24)
	    if score[i] > 0 then
	    	labelScore:setColor(cc.c3b(255,255,0))
	    else
	    	labelScore:setColor(cc.c3b(255,255,255))
	    end
	    labelScore:setAnchorPoint(cc.p(0.5,0.5))
   		labelScore:setPosition(cc.p(190,itemBg:getContentSize().height/2))

   		local labelPower = ccui.Text:create():addTo(itemBg)
		labelPower:setString(tostring(powerInfo[i]))
	    labelPower:setFontSize(24)
	    if powerInfo[i] > 0 then
	    	labelPower:setColor(cc.c3b(255,255,0))
	    else
	    	labelPower:setColor(cc.c3b(255,255,255))
	    end
	    labelPower:setAnchorPoint(cc.p(0.5,0.5))
   		labelPower:setPosition(cc.p(300,itemBg:getContentSize().height/2))
	end

	local btnContinue = ccui.Button:create():addTo(self)
	btnContinue:setTouchEnabled(true)
    btnContinue:loadTextureNormal("ys9zhang/u_btn_bb.png",0)
    btnContinue:loadTexturePressed("ys9zhang/u_btn_bb.png",0)
    btnContinue:setScale(0.8)
    btnContinue:setPosition(cc.p(display.cx+100,display.cy - 230))
    btnContinue:addTouchEventListener(handler(self, self.onClickContinue))

    local imageContinue = ccui.ImageView:create():addTo(btnContinue)
	imageContinue:loadTexture("ys9zhang/u_game_text_continue.png",0)
	imageContinue:setPosition(cc.p(btnContinue:getContentSize().width/2,btnContinue:getContentSize().height/2))

	local btnExit = ccui.Button:create():addTo(self)
	btnExit:setTouchEnabled(true)
    btnExit:loadTextureNormal("ys9zhang/u_btn_bg.png",0)
    btnExit:loadTexturePressed("ys9zhang/u_btn_bg.png",0)
    btnExit:setScale(0.8)
    btnExit:setPosition(cc.p(display.cx-100,display.cy - 230))
    btnExit:addTouchEventListener(handler(self, self.onClickExit))

    local imageExit = ccui.ImageView:create():addTo(btnExit)
	imageExit:loadTexture("ys9zhang/image_font_exti.png",0)
	imageExit:setPosition(cc.p(btnExit:getContentSize().width/2,btnExit:getContentSize().height/2))

	--分界线
	local imageLine = ccui.ImageView:create():addTo(self)
	imageLine:loadTexture("ys9zhang/u_line.png",0)
	imageLine:setScaleX(6)
	imageLine:setRotation(90)
	imageLine:setPosition(cc.p(display.cx+100,display.cy-80))

	--宣传图片
	self.imageUrl = ccui.ImageView:create():addTo(self)
	self.imageUrl:setPosition(cc.p(display.cx+190,display.cy -35))
	--底分背景
	local cellBg = ccui.Scale9Sprite:create("ys9zhang/u_game_bg_acti.png"):addTo(self)
	cellBg:setContentSize(cc.size(160,37))
	cellBg:setPosition(cc.p(display.cx+190,display.cy-170))

	local imageCellScore = ccui.ImageView:create():addTo(cellBg)
	imageCellScore:loadTexture("ys9zhang/image_font_cellScore.png",0)
	imageCellScore:setPosition(cc.p(cellBg:getContentSize().width/2 - imageCellScore:getContentSize().width/2,cellBg:getContentSize().height/2))


	local lableCellScore = cc.LabelAtlas:_create("0:","ys9zhang/timeNumber.png",14,19,string.byte("0"))
	lableCellScore:setString(tostring(self.workflow:getCellScore()))
	lableCellScore:setAnchorPoint(cc.p(0.5,0.5))
	lableCellScore:setPosition(cc.p(cellBg:getContentSize().width*3/4 ,cellBg:getContentSize().height/2))
	cellBg:addChild(lableCellScore)
end

function NPRoundOverView:registerEvents()
	self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    eventListeners[self.app.Message.ConcludeUrl] = handler(self,self.receiveConcludeUrlMessage)

    self.eventHandles = self.app.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function NPRoundOverView:unregisterEvents( )
    -- 移除所有lua层事件
    self.app.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

--继续游戏
function NPRoundOverView:onClickContinue(pSender,touchType)
	if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        self.workflow:sendReadyRequest()
        self:unregisterEvents()
        self:removeFromParent()
    end  
end

function NPRoundOverView:onClickExit(pSender,touchType)
	if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        self.workflow:onExitGameRoom()
        self:unregisterEvents()
        self:removeFromParent()
    end 
end
--
function NPRoundOverView:onAnimationEventOver(pSender,movementType,animaName)
	if movementType == ccs.MovementEventType.complete then
		if animaName == "Animationwin" then
			--self.overEffect:getAnimation():play("Animationwin1",-1,-1)
		end
	end
end

--退出响应
function NPRoundOverView:onClose( sender,touchType )
	if TOUCH_EVENT_ENDED == touchType then
		self:removeFromParent()
	end
end

function NPRoundOverView:receiveConcludeUrlMessage(evt)
	print("receiveConcludeUrlMessage")
	if  string.len(evt.para.szConcludeUrl) > 0 then
		local imageName = string.split(evt.para.szConcludeUrl,'/')
		if cc.FileUtils:getInstance():isFileExist("download/"..imageName[#imageName]) then
			self.imageUrl:loadTexture("download/"..imageName[#imageName],0)
		else
			local updater = require("common.UpdaterModule").new()
	    	if updater then
	        	updater:updateFile(evt.para.szConcludeUrl
	                    ,imageName[#imageName],function (event,value)
	                        if event == "success" then
	                        	self.imageUrl:loadTexture("download/"..imageName[#imageName],0)
	                        end
	                    end,false)
	        	updater:addTo(self)
	    	end
	    end
	end
end

return NPRoundOverView

