local GameTypeController = class("GameTypeController")

function GameTypeController:ctor(frameScene)
	self.frameScene = frameScene
	-- 添加图片
	display.addSpriteFrames("UIGameType.plist", "UIGameType.png")
end

function GameTypeController:registerEvents()
    self.eventHandles = self.eventHandles or {}
    local eventListeners = eventListeners or {}
    local appBase = AppBaseInstanse.PLAZACENTER_APP
    eventListeners[appBase.Message.LP_ListFinish] = handler(self, self.receiveGameItemFinish)
    self.eventHandles = appBase.notificationCenter:addAllEventListenerByTable( eventListeners )
end

function GameTypeController:unregisterEvents()
    AppBaseInstanse.PLAZACENTER_APP.notificationCenter:removeAllListenerByTable(self.eventHandles) 
end

function GameTypeController:receiveGameItemFinish()
	self:updateGameTypeList()
end

function GameTypeController:isExsitGameType(typeID)
	--[[local groupID = {
		ID0=0,ID1=1,ID2=2,ID4=4,ID7=7,ID100=100,
	}]]
	local groupID = {
		ID0=0,ID2=2,ID4=4,ID100=100
	}
	-- 审核状态，仅显示全部游戏
	if GlobalPlatInfo.isInReview then
		groupID = {
			ID0=0
		}
    end
	if groupID["ID"..typeID] then
		return true
	end
end

function GameTypeController:updateGameTypeList()
	if self.frameScene then
		if self.frameScene.imgGameTypeOptionList then
			self.frameScene.imgGameTypeOptionList:removeAllChildren()
            local optionSize = self.frameScene.imgGameTypeOptionList:getContentSize()
			self.group = cc.ui.UICheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
            self.group:align(display.LEFT_TOP, -12, optionSize.height-20)
			self.group:onButtonSelectChanged(handler(self, self.onGameTypeSelectChanged))
			self.group:addButton(self:createGameTypeOption())
			for i,v in ipairs(ServerListData.GameTypeItemMap) do
				if self:isExsitGameType(v.wTypeID) then
					self.group:addButton(self:createGameTypeOption(v.wTypeID))
				end
			end
			-- 朋友同玩
			if self:isExsitGameType(100) then
				self.group:addButton(self:createGameTypeOption(100))
			end
            self.group:setContentSize(optionSize)
            self.group:setLayoutSize(optionSize.width,optionSize.height)
			self.group:setButtonsLayoutMargin(10,0,10,0)
            self.group:getButtonAtIndex(1):setButtonSelected(true)
            self.frameScene.imgGameTypeOptionList:addChild(self.group)
		end
	end
end

function GameTypeController:onGameTypeSelectChanged(event)
	print("onGameTypeSelectChanged: "..event.selected)
    if self.group then
        local selectedItem = self.group:getButtonAtIndex(event.selected)
        if selectedItem then
            AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
            name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_GameTypeSelectChanged,
            para = {wTypeID=selectedItem.wTypeID}
        })
        end
    end
end

function GameTypeController:createGameTypeOption(typeID)
	local wTypeID = 0
	if typeID then
		wTypeID = typeID
	end
	local images={
		off="#pic/plazacenter/GameType/u_gametype_off_"..wTypeID..".png",
		off_pressed="#pic/plazacenter/GameType/u_gametype_on_"..wTypeID..".png",
		on="#pic/plazacenter/GameType/u_gametype_on_"..wTypeID..".png",
	}
	local gameTypeOption = cc.ui.UICheckBoxButton.new(images)
    gameTypeOption:align(display.LEFT_TOP)
	gameTypeOption.wTypeID = wTypeID
	return gameTypeOption
end

return GameTypeController