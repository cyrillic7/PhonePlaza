--
-- Author: Your Name
-- Date: 2015-10-27 15:35:59
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local AboutWidget = class("AboutWidget", XWWidgetBase)

function AboutWidget:ctor(parentNode,callBack)
	AboutWidget.super.ctor(self)

	self.callBack = callBack

	self:addTo(parentNode)
end
function AboutWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	AboutWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_HALL_ABOUT_CSB_FILE)
    if not node then
        return
    end

    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Close")

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    if closeBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
    	closeBtn:onButtonClicked(function ()
    		self.callBack()
    		self:removeFromParent()
    	end)
    	
    end
    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

return AboutWidget