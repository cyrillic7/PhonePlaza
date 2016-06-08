--
-- TransferBattleRecordView
-- Author: tjl
-- Date: 2016-03-21 9:20:01
--
local playerItemView = import(".TransferBattlePlayerItemView")

local  TransferBattlePlayerListView = class("TransferBattlePlayerListView",function()
	return ccui.Widget:create()
end)

--最多显示项
local  showTotalCount = 10

local UITag = {
  	ImageBgTag =   198,
    BtnOkTag =      217, 
    ListViewPlayerTag = 242,
}


function TransferBattlePlayerListView:ctor(workflow)
	self:setContentSize(cc.size(display.width,display.height))
	self:setTouchEnabled(true)
	self:setSwallowTouches(true)

    self.app = AppBaseInstanse.TurntableApp
    --注册消息
    self:registerEvents()
	--加个蒙板
	local shade = cc.LayerColor:create()
	shade:setColor(display.COLOR_BLACK)
	shade:setOpacity(180)
	--self:addChild(shade)

	self:loadUI(workflow)
end

function TransferBattlePlayerListView:loadUI(workflow)
	self.mainWidget = GameUtil:widgetFromCocostudioFile("transferbattle/gamePlayerListWidget")
    self.mainWidget:setAnchorPoint(CCPoint(0.5, 0.5))
    self.mainWidget:setPosition(cc.p(display.cx,display.cy))
    self:addChild(self.mainWidget)

    local bg = self.mainWidget:getChildByTag(UITag.ImageBgTag)

    local btnOk = bg:getChildByTag(UITag.BtnOkTag)
    btnOk:addTouchEventListener(handler(self, self.onClickOk))

    self.playerListView = bg:getChildByTag(UITag.ListViewPlayerTag)

    self.workflow = workflow
    self:refreshPlayerList()
end

function TransferBattlePlayerListView:onClickOk(pSender,touchType)
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



function TransferBattlePlayerListView:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    eventListeners[self.app.Message.UpdatePlayerList] = handler(self,self.receiveUpdatePlayerListMessage)
    eventListeners[self.app.Message.UpdatePlayerListItem] = handler(self,self.receiveUpdatePlayerListItemMessage)
    eventListeners[self.app.Message.DeletePlayerItem] = handler(self,self.receiveDeleteItemMessage)
    self.eventHandles = self.app.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function TransferBattlePlayerListView:unregisterEvents()
    -- 移除所有lua层事件
    self.app.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function TransferBattlePlayerListView:receiveUpdatePlayerListMessage( evt )
    self:refreshPlayerList()   
end

function TransferBattlePlayerListView:refreshPlayerList()
    self.playerListView:removeAllItems()
    --遍历0-99 个椅子号
    --[[for i=1,100 do
        local wChairID = i-1
        local userItem = self.workflow.delegate:getCurClientKernel():SearchUserByChairID(wChairID)
        if userItem then
            playerData ={}
            playerData.dwUserID = userItem.dwUserID
            playerData.szNickName = userItem.szNickName
            playerData.initScore  = userItem.lScore --进入桌子的初始金币数
            playerData.lScore  = userItem.lScore
            local itemView = playerItemView.new(playerData)
            self.playerListView:pushBackCustomItem(itemView)
        end
    end--]]
    local players = self.workflow:getPlayers()
    for k ,v in pairs(players) do
        if v.dwUserID == self.workflow:getMyUserID() then
            v.isMySelf = true
        else
            v.isMySelf = false
        end
        local itemView = playerItemView.new(v)
        self.playerListView:pushBackCustomItem(itemView)
    end
end

function TransferBattlePlayerListView:receiveUpdatePlayerListItemMessage( evt )
    --一项一项刷新
    for k ,item in pairs(self.playerListView:getItems()) do
        if item:getData().dwUserID == evt.para.dwUserID then
            item:refreshData(evt.para)
        end
    end
end

function TransferBattlePlayerListView:receiveDeleteItemMessage(evt)
    --删除一项
    for k ,item in pairs(self.playerListView:getItems()) do
        if item:getData().dwUserID == evt.para.dwUserID then
            item:removeFromParent()
        end
    end
end

return TransferBattlePlayerListView

