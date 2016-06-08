--
-- talkWidget
-- Author: tjl
-- Date: 2014-09-24 9:20:01
--
--[[
talkWidget
]]
local  TalkUITag = {
		bgTag      = 42,
		listBgTag  = 45,
		listViewTag = 46,
		inputBgTag = 49,
		inputTag   = 50,
		btnSendTag = 51,
		imageTabTag = 53,
		checkBoxFace = 57,
		checkBoxlanguage = 58,
		language = {{tag = 1, text = "大家好，很高兴见到各位。"},
        {tag = 2, text = "看什么看呢，快点出牌~"},
        {tag = 3, text = "你的牌打的也太好了！"},
        {tag = 4 ,text = "胜利女神眷顾着我。"},
        {tag =5,text ="小小意思，金币拿去花吧。" },
        {tag = 6,text = "这下赚大发啦！"},
        {tag = 7,text ="你是MM，还是GG？"},
        {tag = 8,text = "下次再玩吧，我要走了。"},
        {tag = 9,text = "再见了，我会想念大家的。"},
        {tag = 10,text = "不要走，决战到天亮。"}},
 
		face = {{tag = 23,img = "chat_1.png"},
                {tag = 24,img = "chat_2.png"},
                {tag = 25,img = "chat_3.png"},
				{tag = 26,img = "chat_4.png"},
				{tag = 27,img = "chat_5.png"},
				{tag = 28,img = "chat_6.png"},
				{tag = 29,img = "chat_7.png"},
				{tag = 30,img = "chat_8.png"}
				}, 
		faceBgOn ="Common/chat/chaticon_cur.png",
		facebgTag = 100,
}


local ChatImageDir = "Common/chat/"

local  TalkWidget = class("TalkWidget",function()
	return ccui.Widget:create()
end)

--常用语类型
TalkWidget.COMMON_LANGUAGE_TYPE = 0
--表情类型
TalkWidget.COMMON_FACE_TYPE = 1
--消息类型
TalkWidget.COMMON_MESSAGE_TYPE = "PublicMessage"--"chat"

--[[ chat消息
parameters:
	args:
	{
		type: 类型（0 表示常用语，1 表示表情 ）,
		value: 内容（文本 / 图片路径）,
	}
]]

-- 必须传入service client
function TalkWidget:ctor( serviceClient )
	--加载JSON
    self.mainWidget = GameUtil:widgetFromCocostudioFile("oxtwo/talkWidget"):addTo(self)

    local bg  = self.mainWidget:getChildByTag(TalkUITag.bgTag)
    local contentBg = bg:getChildByTag(TalkUITag.listBgTag)
    --内容的下拉列表
    self._scroll =  contentBg:getChildByTag(TalkUITag.listViewTag)

    local editBg = bg:getChildByTag(TalkUITag.inputBgTag)
    self.inputText = editBg:getChildByTag(TalkUITag.inputTag)

    --btn send
    local btnSend = bg:getChildByTag(TalkUITag.btnSendTag)
    btnSend:addTouchEventListener(handler(self, self.onClickSend))

    local swithchTab = bg:getChildByTag(TalkUITag.imageTabTag)
    self.checkBoxFace = swithchTab:getChildByTag(TalkUITag.checkBoxFace)
    self.checkBoxLan  = swithchTab:getChildByTag(TalkUITag.checkBoxlanguage)
    self.checkBoxLan:addEventListener(handler(self, self.onClickLan))
   	self.checkBoxFace:addEventListener(handler(self, self.onClickFace))
    --self:initCommonLanguage()
	self:initCommonFace()
	self.checkBoxFace:setSelected(true)
-- 获取当前的service client
	self.serviceClient = serviceClient
end

function TalkWidget:onClickLan(pSender ,touchType)
	pSender:setSelected(true)
	if self.page == 1 then
		if touchType == 0 then
			pSender:setSelected(true)
			self.checkBoxFace:setSelected(false)
			self:initCommonLanguage()
		end	
	end
end

function TalkWidget:onClickFace(pSender ,touchType)
	pSender:setSelected(true)
	if self.page == 2 then
		if touchType == 0 then
			self.checkBoxLan:setSelected(false)
			self:initCommonFace()
		end	
	end
end

function TalkWidget:playScaleAnimation(flag,pSender)
	local  scale = less and 0.7 or 0.8
	pSender:runAction(cc.ScaleTo:create(0.2,scale))
end

function TalkWidget:onClickSend(pSender,touchType)
	if touchType == TOUCH_EVENT_BEGAN then
        self:playScaleAnimation(true, pSender)
    else
        self:playScaleAnimation(false, pSender)
    end
    if touchType == TOUCH_EVENT_ENDED then
    	if string.len(self.inputText:getString()) == 0 then
    		local dataMsgBox = {
                nodeParent=self:getParent(),
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="发送内容不能为空"
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
    	else
    		self.serviceClient:sendUserChatMsg(self.inputText:getString())
    		self:setVisible(false)
    		self.inputText:setString("")
    	end
    end
end

--初始化常用语
function TalkWidget:initCommonLanguage()
	self.page = 2
	--移除当前所有项
	self._scroll:removeAllItems()
	local  listWidth = self._scroll:getContentSize().width 
	for k, v in pairs(TalkUITag.language) do
        if  v.tag and v.text then
            local  _label = ccui.Text:create()
            _label:setString(v.text)
            _label:setTag(v.tag)
            _label:setFontSize(25)
            _label:setColor(cc.c3b(83,75,68))
            local  itemHeight = 35
            local lineLayout = ccui.Layout:create()
			local lineSize = cc.size(listWidth,itemHeight)
			lineLayout:setContentSize(lineSize)
			lineLayout:setLayoutType(LAYOUT_LINEAR_HORIZONTAL)
			lineLayout:setAnchorPoint(cc.p(0.5,0.5))
			lineLayout:ignoreContentAdaptWithSize(false)
			lineLayout:setTouchEnabled(true)
			lineLayout:addTouchEventListener(handler(self,self.onPressedLanguage))
			lineLayout:addChild(_label)
			self._scroll:pushBackCustomItem(lineLayout)
        end
    end
end

--初始化常用表情
function TalkWidget:initCommonFace()
	--移除当前所有项
	self.page = 1

	self._scroll:removeAllItems()
	local listWidth = self._scroll:getContentSize().width
	--临时项 以便获取每一项的SIZE
	local tempItem = cc.Sprite:create(TalkUITag.faceBgOn)
	local itemSize = tempItem:getContentSize()
	--一行所能放下的最大项数
	--local  colnum = math.floor(listWidth/itemSize.width)
	colnum = 4
	--每一行的列索引计数
	self.colIndex =0
	--当前的layer
	self.curlayout = nil
    dump(TalkUITag.face)
	for k, v in pairs(TalkUITag.face) do
        if v.tag and v.img then
        	--达到一行最大项数，换行，重置列索引 
       		if self.colIndex == colnum then
       			self.colIndex = 0
       		end

       		--新创一个layerOut
       		if self.colIndex == 0 then
       			local lineLayout = ccui.Layout:create()
       			local lineSize = cc.size(listWidth,itemSize.height+20)
				lineLayout:setContentSize(lineSize)
				lineLayout:setLayoutType(LAYOUT_LINEAR_HORIZONTAL)
				lineLayout:setAnchorPoint(cc.p(0.5,0.5))

				self.curlayout = lineLayout
				self._scroll:pushBackCustomItem(self.curlayout)
       		end

       		--表情按钮
			local  _faceBtn = ccui.Button:create()
            _faceBtn:setTag(v.tag)
            _faceBtn:loadTextureNormal(ChatImageDir..v.img)
            _faceBtn:loadTexturePressed(ChatImageDir..v.img)
            _faceBtn:setTouchEnabled(true)
            _faceBtn:addTouchEventListener(handler(self, self.onPressedFace))
			self.colIndex = self.colIndex + 1
			
			--表情选中图片
			local _facebg = ccui.ImageView:create()
			_facebg:loadTexture(TalkUITag.faceBgOn)
			_facebg:setVisible(false)
			_facebg:setPosition(cc.p(_faceBtn:getContentSize().width/2,_faceBtn:getContentSize().height/2))
			_faceBtn:addChild(_facebg,-1,TalkUITag.facebgTag)
			
			local linearLayout = ccui.LinearLayoutParameter:create()
			linearLayout:setGravity(1)
			local Margin = {top = 0, right = 8, bottom = 0, left = 8}
			linearLayout:setMargin(Margin)
			_faceBtn:setLayoutParameter(linearLayout)
			self.curlayout:addChild(_faceBtn)
        end
    end
end

--表情选中响应
function TalkWidget:onPressedFace(sender ,touchType)

	local _selectfacebg = sender:getChildByTag(TalkUITag.facebgTag)
	if touchType == TOUCH_EVENT_BEGAN  or  touchType == TOUCH_EVENT_MOVED then
		--显示背景图片
		if _selectfacebg ~= nil and _selectfacebg:isVisible() == false then
			_selectfacebg:setVisible(true)
		end
	end

	if touchType == TOUCH_EVENT_CANCELED then
		if _selectfacebg ~= nil  and _selectfacebg:isVisible() == true then
			_selectfacebg:setVisible(false)
		end
	end

	if touchType == TOUCH_EVENT_ENDED then
		if _selectfacebg ~= nil and _selectfacebg:isVisible() == true then
			_selectfacebg:setVisible(false)
		end
		--通过按扭的tag到table(face)里 找到对应的图片名称
		for k, v in pairs(TalkUITag.face) do 
			if v.tag == sender:getTag() then
				local  fullpath = ChatImageDir..v.img
				--发送聊天消息
				self.serviceClient:SendUserExpression(v.tag-22)
				self:setVisible(false)
				break
			end
		end 
		
	end
end

--选中常用语响应
function TalkWidget:onPressedLanguage(sender, touchType )
	local child = sender:getChildren()
	local cnt = sender:getChildrenCount()
	if cnt > 0 then
		local _curlable = child[1]
		if _curlable ~= nil then 
			if touchType == TOUCH_EVENT_BEGAN then
				--选中 变成黄色
				_curlable:setColor(cc.c3b(147,66,4))
			end 

			if touchType == TOUCH_EVENT_ENDED then
				--触摸结事置回白色
				_curlable:setColor(cc.c3b(83,75,68))
				
				-- 发送常用语消息
				self.serviceClient:sendUserChatMsg(_curlable:getString(),_curlable:getTag()-1)

				self:setVisible(false)
			end
			if touchType == TOUCH_EVENT_CANCELED then
				--触摸取消，重置回白色
				_curlable:setColor(cc.c3b(83,75,68))
			end
		end
	end
end

--退出响应
function TalkWidget:onClose( sender,touchType )
	if TOUCH_EVENT_ENDED == touchType then
		self:removeFromParent()
	end
end

return TalkWidget

