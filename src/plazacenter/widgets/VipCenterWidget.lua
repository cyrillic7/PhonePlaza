--
-- Author: SuperM
-- Date: 2015-11-12 14:19:42
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local VipCenterWidget = class("VipCenterWidget", XWWidgetBase)

function VipCenterWidget:ctor(parentNode,callBack)
	VipCenterWidget.super.ctor(self)

	self.callBack = callBack
    self.MissionType = self.VIP_GET_LIST
    self.widgetType = "VipCenterWidget"

	self:addTo(parentNode)
end

function VipCenterWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	VipCenterWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_VIP_CENTER_CSB_FILE)
    if not node then
        return
    end
    node:setTouchEnabled(false)

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Close")
    local okBtn = cc.uiloader:seekNodeByName(node, "Button_Ok")
    local headBg = cc.uiloader:seekNodeByName(node, "Panel_HeadBg")
 
    if closeBtn then
        AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
        closeBtn:onButtonClicked(function ()
            self.callBack()
            self:removeFromParent()
        end)
    end

    if okBtn then
        AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(okBtn)
        okBtn:onButtonClicked(function ()
            self.callBack()
            self:removeFromParent()
            AppBaseInstanse.PLAZACENTER_APP.notificationCenter:dispatchEvent({
                name = AppBaseInstanse.PLAZACENTER_APP.Message.Ctrl_OpenTopupWidget,
                para = 1,
            })
        end)
    end

    if headBg then
        local orgX = headBg:getPositionX()
        local orgY = headBg:getPositionY()
        local size = headBg:getContentSize()
        display.newLine({{0, size.height}, {0,7*-35}},{borderColor=cc.c4f(160,160,160,1)})
        :addTo(headBg)
        display.newLine({{0, size.height}, {size.width,size.height}},{borderColor=cc.c4f(160,160,160,1)})
        :addTo(headBg)
        for i=1,7 do
            display.newLine({{0, i*-35}, {size.width,i*-35}},{borderColor=cc.c4f(160,160,160,1)})
            :addTo(headBg)
        end
        display.newLine({{size.width, size.height}, {size.width,7*-35}},{borderColor=cc.c4f(160,160,160,1)})
        :addTo(headBg)
    end

    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function VipCenterWidget:onCleanup()
	VipCenterWidget.super.onCleanup(self)
end

function VipCenterWidget:cleanPlistRes()
	print("VipCenterWidget:cleanPlistRes")
    display.removeSpriteFramesWithFile("UIVipCenter.plist", "UIVipCenter.png")
end

return VipCenterWidget