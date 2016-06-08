--
-- TransferBattleRecordView
-- Author: tjl
-- Date: 2016-02-29 9:20:01
--
local  TransferBattleRecordView = class("TransferBattleRecordView",function()
	return ccui.Widget:create()
end)

--最多显示项
local  showTotalCount = 10

local UITag = {
  	ImageBgTag =   198,
    BtnOkTag =      217, 
    BtnLeftTag =    218,
    BtnRightTag =  220
}

local animTag = 
{
	{animIndex = 1,tag = 200},
  	{animIndex = 2,tag = 201},
 	{animIndex = 3,tag = 202},
    {animIndex = 4,tag = 204},
    {animIndex = 5,tag = 205},
    {animIndex = 6,tag = 206},
    {animIndex = 7,tag = 207},
    {animIndex = 8,tag = 208},
    {animIndex = 9,tag = 209},
    {animIndex = 10,tag = 210},
}


function TransferBattleRecordView:ctor(workflow)
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

function TransferBattleRecordView:loadUI(workflow)
	self.mainWidget = GameUtil:widgetFromCocostudioFile("transferbattle/gameRecordWidget")
    self.mainWidget:setAnchorPoint(CCPoint(0.5, 0.5))
    self.mainWidget:setPosition(cc.p(display.cx,display.cy))
    self:addChild(self.mainWidget)

    local bg = self.mainWidget:getChildByTag(UITag.ImageBgTag)

    local btnOk = bg:getChildByTag(UITag.BtnOkTag)
    btnOk:addTouchEventListener(handler(self, self.onClickOk))

    self.btnLeft = bg:getChildByTag(UITag.BtnLeftTag)
    self.btnLeft:addTouchEventListener(handler(self, self.onClickLeft))

    self.btnRight = bg:getChildByTag(UITag.BtnRightTag)
    self.btnRight:addTouchEventListener(handler(self, self.onClickRight))

    self.pageIndex = 1 

    self.workflow = workflow
    self:refreshRecordList()
    --[[local recodeInfo = self.workflow:getRecordInfo()
    dump(recodeInfo)
    if #recodeInfo <= showTotalCount then
    	self.lastIndex = 1
    else
    	self.lastIndex = #recodeInfo - showTotalCount
    end
    self.pageIndex = 1 
    for k ,v in pairs(animTag) do
    	if type(v) =="table" and v.tag and v.animIndex then
    		print("v.tag ="..v.tag)
    		local imageAnima = bg:getChildByTag(v.tag)
    		local curIndex = v.animIndex + self.lastIndex
    		if  curIndex <= #recodeInfo then
    			print("curIndex==="..curIndex)
    			print("recodeInfo[curIndex]==="..recodeInfo[curIndex])
    			local realIndex  = self:covertoRealAnimIndex(recodeInfo[curIndex])
    			print(string.format("image_anim_%d.png",realIndex))
    			imageAnima:loadTexture(string.format("image_anim_%d.png",realIndex),1)
    		end
    	end
    end]]
end

function TransferBattleRecordView:refreshRecordList()
    local recodeInfo = self.workflow:getRecordInfo()
    local lastIndex = 1
    if #recodeInfo <= showTotalCount then
        lastIndex = 1
    else
        lastIndex = #recodeInfo - self.pageIndex*showTotalCount
    end
    
    local bg = self.mainWidget:getChildByTag(UITag.ImageBgTag)
    for k ,v in pairs(animTag) do
        if type(v) =="table" and v.tag and v.animIndex then
            print("v.tag ="..v.tag)
            local imageAnima = bg:getChildByTag(v.tag)
            local curIndex = v.animIndex + lastIndex
            if  curIndex <= #recodeInfo then
                local realIndex  = self:covertoRealAnimIndex(recodeInfo[curIndex])
                print(string.format("image_anim_%d.png",realIndex))
                imageAnima:loadTexture(string.format("image_anim_%d.png",realIndex),1)
            end
        end
    end

    --最后一页
    if self.pageIndex == 3 then
        self.btnLeft:setEnabled(false)
        self.btnLeft:loadTextureNormal("btn_lmirrow_an.png",1)
        self.btnRight:setEnabled(true)
        self.btnRight:loadTextureNormal("btn_rmirrow.png",1)
    elseif self.pageIndex == 1 then
        self.btnLeft:setEnabled(true)
        self.btnLeft:loadTextureNormal("btn_lmirrow.png",1)
        self.btnRight:setEnabled(false)
        self.btnRight:loadTextureNormal("btn_rmirrow_an.png",1)
    else
        self.btnLeft:setEnabled(true)
        self.btnLeft:loadTextureNormal("btn_lmirrow.png",1)
        self.btnRight:setEnabled(true)
        self.btnRight:loadTextureNormal("btn_rmirrow.png",1)
    end
end

function TransferBattleRecordView:covertoRealAnimIndex(indexFormServer)
	if indexFormServer == 1 then
		return 1
	elseif indexFormServer == 5  then
		return 2
	elseif indexFormServer == 13  then
		return 3
	elseif indexFormServer == 9 then
		return 4
	elseif indexFormServer == 8  or indexFormServer == 11 or indexFormServer == 14 then
		return 5
	elseif indexFormServer == 2  or indexFormServer == 12 or indexFormServer == 16 then
		return 6
	elseif indexFormServer == 4  or indexFormServer == 7 or indexFormServer == 10 then
		return 7
	elseif indexFormServer == 3  or indexFormServer == 6 or indexFormServer == 15 then
		return 8
	end
end


function TransferBattleRecordView:onClickOk(pSender,touchType)
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

function TransferBattleRecordView:onClickRight(pSender,touchType)
    if touchType == TOUCH_EVENT_ENDED then
        self.pageIndex = self.pageIndex - 1
        self:refreshRecordList()
    end  
end


function TransferBattleRecordView:onClickLeft(pSender,touchType)
    if touchType == TOUCH_EVENT_ENDED then
        self.pageIndex = self.pageIndex + 1
        self:refreshRecordList()
    end  
end

function TransferBattleRecordView:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    eventListeners[self.app.Message.UpdateRecord] = handler(self,self.receiveUpdateRecordMessage)

    self.eventHandles = self.app.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function TransferBattleRecordView:unregisterEvents( )
    -- 移除所有lua层事件
    self.app.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function TransferBattleRecordView:receiveUpdateRecordMessage( evt )
    self.pageIndex = 1 
    self:refreshRecordList()
end

return TransferBattleRecordView

