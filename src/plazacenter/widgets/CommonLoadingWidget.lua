local CommonLoadingWidget = class("CommonLoadingWidget")

function CommonLoadingWidget:ctor(scene)
    local node, width, height = cc.uiloader:load(COMMON_LOADING_WIDGET_CSB_FILE)
    if not node then
    	return
    end

    local manager = ccs.ArmatureDataManager:getInstance()
    manager:addArmatureFileInfo(ANIMATION_LOADING_WIDGET_CSB_FILE)
    local armature = ccs.Armature:create("AnimationLoading")
    armature:align(display.CENTER, display.cx, display.cy)
    node:addChild(armature)
    armature:getAnimation():play("Animation1")
    self.loadingWidget=node

    self.loadingLabel = cc.uiloader:seekNodeByName(node, "LabelLoading")
    if self.loadingLabel then
        self.loadingLabel:setPositionY(display.cy-armature:getContentSize().height/2-30)
        self:updateStatusLabel("正在载入")

        self.scriptEntryID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.updateLoadingLabel), 0.5, false)
    end

    scene:addChild(node)
end

function CommonLoadingWidget:hideLoadingWidget()
	if self.loadingWidget ~= nil then
		self.loadingWidget:removeFromParent()
		self.loadingWidget = nil
	end
    if self.scriptEntryID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scriptEntryID)
    end
end

function CommonLoadingWidget:updateStatusLabel(statusText)
    if self.loadingLabel then
        self.statusText = statusText
        self.loadingLabel:setString(statusText)
    end
end

function CommonLoadingWidget:updateLoadingLabel(dt)
    if self.loadingLabel then
        self.updateIndex = self.updateIndex or 0
        if self.updateIndex < 1 then
            self.loadingLabel:setString(self.statusText..".")
        elseif self.updateIndex < 2 then
            self.loadingLabel:setString(self.statusText.."..")
        elseif self.updateIndex < 3 then
            self.loadingLabel:setString(self.statusText.."...")
        else
            self.updateIndex = -1
        end
        self.updateIndex = self.updateIndex + 1
    end
end

return CommonLoadingWidget