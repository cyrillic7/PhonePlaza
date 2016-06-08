--
-- baccaratRecordView
-- Author: tjl
-- Date: 2016-02-29 9:20:01
--
local  baccaratRecordView = class("baccaratRecordView",function()
	return ccui.Widget:create()
end)

local recordItem = import(".recordItemView")
--最多显示项
local  showTotalCount = 10

local UITag = {
  	ImageBgTag =   349,
    BtnCloseTag =      450, 
    imageInnerBg = 350,
    ListRecordViewTag = 695,
}



function baccaratRecordView:ctor(workflow)
	self:setContentSize(cc.size(display.width,display.height))
	self:setTouchEnabled(true)
	self:setSwallowTouches(true)

    self.app = AppBaseInstanse.BaccaratApp
    --注册消息
    self:registerEvents()
	--加个蒙板
	local shade = cc.LayerColor:create()
	shade:setColor(display.COLOR_BLACK)
	shade:setOpacity(180)
	self:addChild(shade)

	self:loadUI(workflow)
end

function baccaratRecordView:loadUI(workflow)
	self.mainWidget = GameUtil:widgetFromCocostudioFile("baccaratnew/BaccaratTrendView")
    self.mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
    self.mainWidget:setPosition(cc.p(display.cx,display.cy))
    self:addChild(self.mainWidget)

    local bg = self.mainWidget:getChildByTag(UITag.ImageBgTag)

    local btnOk = bg:getChildByTag(UITag.BtnCloseTag)
    btnOk:addTouchEventListener(handler(self, self.onClickOk))

    local innerBg = bg:getChildByTag(UITag.imageInnerBg)
    self.recordList = innerBg:getChildByTag(UITag.ListRecordViewTag)

    self.workflow = workflow
    self:refreshRecordList()
end

function baccaratRecordView:refreshRecordList()
    local recodeInfo = self.workflow:getRecordInfo()
    self.recordList:removeAllItems()
    for k ,v in pairs(recodeInfo)do
        local item = recordItem.new(v) 
        self.recordList:pushBackCustomItem(item)
    end

    local s = cc.DelayTime:create(0.2)
    
    local f = cc.CallFunc:create(function()
        self.recordList:jumpToRight()
    end)
     
    self:runAction(cc.Sequence:create(s,f))
end


function baccaratRecordView:onClickOk(pSender,touchType)
	if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        self:unregisterEvents()
        self:removeFromParent()
    end  
end



function baccaratRecordView:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    eventListeners[self.app.Message.NewAddRecord] = handler(self,self.receiveNewAddRecordMessage)

    self.eventHandles = self.app.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function baccaratRecordView:unregisterEvents( )
    -- 移除所有lua层事件
    self.app.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function baccaratRecordView:receiveNewAddRecordMessage( evt )
    local item = recordItem.new(evt.para.info) 
    self.recordList:pushBackCustomItem(item)
    local s = cc.DelayTime:create(0.2)
    
    local f = cc.CallFunc:create(function()
        self.recordList:jumpToRight()
    end)
     
    self:runAction(cc.Sequence:create(s,f))
end

return baccaratRecordView

