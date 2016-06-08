--
-- baccaratBankerListView
-- Author: tjl
-- Date: 2016-03-21 9:20:01
--
local bankerItemView = import(".bankerItemView")

local  baccaratBankerListView = class("baccaratBankerListView",function()
	return ccui.Widget:create()
end)


local UITag = {
  	ImageBgTag =   349,
    ImageInnerBgTag =      350, 
    ListViewPlayerTag = 353,
    LabelTipTag       = 355,
    BtnCloseTag = 450,
    BtnUpBankerTag = 356,
    BtnDownBankerTag = 546,
    BtnQiangBankerTag = 547,
}


function baccaratBankerListView:ctor(workflow)
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

function baccaratBankerListView:loadUI(workflow)
	self.mainWidget = GameUtil:widgetFromCocostudioFile("baccaratnew/BaccaratBankerVeiw")
    self.mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
    self.mainWidget:setPosition(cc.p(display.cx,display.cy))
    self:addChild(self.mainWidget)

    local bg = self.mainWidget:getChildByTag(UITag.ImageBgTag)
    local innerBg = bg:getChildByTag(UITag.ImageInnerBgTag)

    local btnClose = bg:getChildByTag(UITag.BtnCloseTag)
    btnClose:addTouchEventListener(handler(self, self.onClose))

    self.btnUpBanker = bg:getChildByTag(UITag.BtnUpBankerTag)
    self.btnUpBanker:addTouchEventListener(handler(self, self.onClickUpbanker))

    self.btnDownBanker = bg:getChildByTag(UITag.BtnDownBankerTag)
    self.btnDownBanker:addTouchEventListener(handler(self, self.onClickDownbanker))
    self.btnDownBanker:setVisible(false)

    self.btnQiangBanker = bg:getChildByTag(UITag.BtnQiangBankerTag)
    self.btnQiangBanker:addTouchEventListener(handler(self, self.onClickQiangbanker))
    self.btnQiangBanker:setVisible(false)
    
    self.workflow = workflow


    self.playerListView = innerBg:getChildByTag(UITag.ListViewPlayerTag)
    self.tipLabel = innerBg:getChildByTag(UITag.LabelTipTag)
    --self.tipLabel:setString(string.format("上庄至少需要%s金币",tostring(workflow.lApplyBankerCondition)))
    
    self:setBtnState()
    self:refreshPlayerList()
end

function baccaratBankerListView:setBtnState()
    --当前是自己庄家
    if self.workflow:getCurBankerUserId() ==self.workflow:getMyChairID() then
        self.btnUpBanker:setVisible(false)
        
        self.btnDownBanker:setVisible(true)
        self.btnQiangBanker:setVisible(true)
        if self.workflow:isPlaying() then
            self.btnDownBanker:loadTextureNormal("btn_downBanker_an.png",1)
            self.btnDownBanker:loadTexturePressed("btn_downBanker_an.png",1)
            self.btnDownBanker:setTouchEnabled(false)
        else
            self.btnDownBanker:loadTextureNormal("u_btn_xzh.png",1)
            self.btnDownBanker:loadTexturePressed("u_btn_xzh.png",1)
            self.btnDownBanker:setTouchEnabled(true)
        end
    else
        --不在上庄列表
        if not self.workflow:checkInBankerList() then
            self.btnUpBanker:setVisible(true)
            self.btnDownBanker:setVisible(false)
            self.btnQiangBanker:setVisible(false)
        else
            --在上庄列表
            self.btnUpBanker:setVisible(false)
            self.btnDownBanker:setVisible(true)
            self.btnDownBanker:setTouchEnabled(true)
            self.btnDownBanker:loadTextureNormal("u_btn_xzh.png",1)
            self.btnDownBanker:loadTexturePressed("u_btn_xzh.png",1)
            self.btnQiangBanker:setVisible(true)
        end
    end

    if self.btnQiangBanker:isVisible() then
        self.tipLabel:setString(string.format("抢庄需要%s金币",tostring(2000000)))
    else
        self.tipLabel:setString(string.format("上庄至少需要%s金币",tostring(self.workflow.lApplyBankerCondition)))
    end
end

function baccaratBankerListView:onClose(pSender,touchType)
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

function baccaratBankerListView:onClickUpbanker(pSender, touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        self.workflow:sendApplyBankerRequest()
    end 
end

function baccaratBankerListView:onClickDownbanker(pSender, touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then
        self.workflow:sendCancelBankerRequest()
    end 
end

function baccaratBankerListView:onClickQiangbanker(pSender, touchType)
    if touchType == TOUCH_EVENT_BEGAN then
        GameUtil:playScaleAnimation(true, pSender)
    else
        GameUtil:playScaleAnimation(false, pSender)
    end

    if touchType == TOUCH_EVENT_ENDED then
         if self.workflow:getCurBankerUserId() == self.workflow:getMyChairID() then
            --to do弹出提示已经是庄家,
            local dataMsgBox = {
                nodeParent=self,
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="您已经是最高位置了，请不要抢过头哦！"
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        else 
            self.workflow:sendQiangBankerRequest()
        end
    end 
end


function baccaratBankerListView:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    eventListeners[self.app.Message.UpdateBankerList] = handler(self,self.receiveUpdateBankerListMessage)
    eventListeners[self.app.Message.UpdateBankerListItem] = handler(self,self.receiveUpdateBankerListItemMessage)
    eventListeners[self.app.Message.DeleteBankerItem] = handler(self,self.receiveDeleteItemMessage)
    eventListeners[self.app.Message.RefreshDownBankerBtn] = handler(self,self.receiveRefreshDownBtnState)
    self.eventHandles = self.app.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function baccaratBankerListView:unregisterEvents()
    -- 移除所有lua层事件
    self.app.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function baccaratBankerListView:receiveUpdateBankerListMessage( evt )
    self:refreshPlayerList()   
end

function baccaratBankerListView:refreshPlayerList()
    self:setBtnState()

    self.playerListView:removeAllItems()
    
    local bankerIds = self.workflow.bankerChardIds
    dump(bankerIds)
    for i=1 ,#bankerIds  do
        local info = {}
        local serviceClient = self.workflow.delegate:getCurClientKernel()
        local userInfo = serviceClient:SearchUserByChairID(bankerIds[i])
        if userInfo then
            info.score = userInfo.lScore
            info.nick  = userInfo.szNickName
            info.dwUserID = userInfo.dwUserID
            info.wChairID = bankerIds[i] 
            local  bankItem = bankerItemView.new(info)
            self.playerListView:pushBackCustomItem(bankItem)
        end
    end
end

function baccaratBankerListView:receiveRefreshDownBtnState( evt)
    self.btnDownBanker:setEnabled(evt.para.isEnable)
    if not evt.para.isEnable then
        self.btnDownBanker:loadTextureNormal("btn_downBanker_an.png",1)
        self.btnDownBanker:loadTexturePressed("btn_downBanker_an.png",1)
    else
        self.btnDownBanker:loadTextureNormal("u_btn_xzh.png",1)
        self.btnDownBanker:loadTexturePressed("u_btn_xzh.png",1)
    end
end

--刷新所有庄家的分数
function baccaratBankerListView:receiveUpdateBankerListItemMessage( evt )  
    --一项一项刷新
    for k ,item in pairs(self.playerListView:getItems()) do
        if item:getData().dwUserID == evt.para.dwUserID then
            item:refreshData(evt.para)
        end
    end
end

function baccaratBankerListView:receiveDeleteItemMessage(evt)
    self:setBtnState()
    --删除一项
    for k ,item in pairs(self.playerListView:getItems()) do
        if item:getData().wChairID == evt.para.wChairID then
            item:removeFromParent()
        end
    end
end

return baccaratBankerListView

