--
-- baccaratHistoryView
-- Author: tjl
-- Date: 2016-02-29 9:20:01
--
local  baccaratHistoryView = class("baccaratHistoryView",function()
	return ccui.Widget:create()
end)


local UITag = {
  	ImageBgTag =   349,
    imageLabelBg = 712,
    item1 = { playerTag = 729,bankerTag =714 ,index = 12 },
    item2 = { playerTag = 730,bankerTag =716 ,index = 11 },
    item3 = { playerTag = 731,bankerTag =718 ,index = 10 },
    item4 = { playerTag = 733,bankerTag =720 ,index = 9 },
    item5 = { playerTag = 734,bankerTag =721 ,index = 8 },
    item6 = { playerTag = 735,bankerTag =722 ,index = 7 },
    item7 = { playerTag = 736,bankerTag =723 ,index = 6 },
    item8 = { playerTag = 737,bankerTag =724 ,index = 5 },
    item9 = { playerTag = 738,bankerTag =725 ,index = 4 },
    item10 = { playerTag = 739,bankerTag =726 ,index = 3 },
    item11 = { playerTag = 740,bankerTag =727 ,index = 2 },
    item12 = { playerTag = 741,bankerTag =728 ,index = 1 },
}

function baccaratHistoryView:ctor(workflow)
    print("baccaratHistoryView:ctor")
	self:setContentSize(cc.size(display.width,display.height))

    self.app = AppBaseInstanse.BaccaratApp
    
	self:loadUI(workflow)
    --注册消息
    self:registerEvents()
end

function baccaratHistoryView:loadUI(workflow)
	self.mainWidget = GameUtil:widgetFromCocostudioFile("baccaratnew/BaccaratHistoryView")
    self.mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
    self.mainWidget:setPosition(cc.p(display.cx,display.cy))
    self:addChild(self.mainWidget)

    self.workflow = workflow
    local  bg  = self.mainWidget:getChildByTag(UITag.ImageBgTag)
    self.labelBg = bg:getChildByTag(UITag.imageLabelBg)

    self:refreshHistoryInfo()
end

function baccaratHistoryView:refreshHistoryInfo()
    local recordInfo = self.workflow:getRecordInfo()
    --取最后12记录
    local recordCnt = #recordInfo
    for k ,v in pairs(UITag) do
        if type(v) == "table"  then
            local labelPlayer = self.labelBg:getChildByTag(v.playerTag)
            labelPlayer:setString(tostring(recordInfo[recordCnt-v.index+1].cbPlayerCount))
            local labelBanker = self.labelBg:getChildByTag(v.bankerTag)
            labelBanker:setString(tostring(recordInfo[recordCnt-v.index+1].cbBankerCount))
        end
    end
end

function baccaratHistoryView:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    eventListeners[self.app.Message.NewAddRecord] = handler(self,self.receiveNewAddRecordMessage)
    self.eventHandles = self.app.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function baccaratHistoryView:unregisterEvents( )
    -- 移除所有lua层事件
    self.app.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function baccaratHistoryView:receiveNewAddRecordMessage(evt)
    self:refreshHistoryInfo()
end



return baccaratHistoryView

