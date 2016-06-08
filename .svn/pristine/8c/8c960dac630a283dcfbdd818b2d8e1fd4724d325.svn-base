--
-- Author: SuperM
-- Date: 2016-02-24 17:50:26
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local HallPayTypeWidget = class("HallPayTypeWidget", XWWidgetBase)

function HallPayTypeWidget:ctor(parentNode,callBack)
	HallPayTypeWidget.super.ctor(self)

	self.callBack = callBack

	self:addTo(parentNode)
end
function HallPayTypeWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	HallPayTypeWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_HALL_PAY_TYPE_CSB_FILE)
    if not node then
        return
    end

    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Cancel")
    local alipayBtn = cc.uiloader:seekNodeByName(node, "Button_Alipay")
    local weixinPayBtn = cc.uiloader:seekNodeByName(node, "Button_WeixinPay")
    local appStorePayBtn = cc.uiloader:seekNodeByName(node, "Button_AppstorePay")

    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    if closeBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
    	closeBtn:onButtonClicked(function ()
    		self:closeWidget()
    	end)
    end
    if alipayBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(alipayBtn)
    	alipayBtn:onButtonClicked(function ()
    		self:closeWidget(eHallPayType.eAlipay)
    	end)
    end
    if weixinPayBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(weixinPayBtn)
    	weixinPayBtn:onButtonClicked(function ()
    		self:closeWidget(eHallPayType.eWeixinPay)
    	end)
    end
    if appStorePayBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(appStorePayBtn)
    	appStorePayBtn:onButtonClicked(function ()
    		self:closeWidget(eHallPayType.eAppStorePay)
    	end)
    end
    if device.platform == "android" then
        if alipayBtn then
            alipayBtn:setPositionX(bgnode:getContentSize().width/3*1)
        end
        if weixinPayBtn then
            weixinPayBtn:setPositionX(bgnode:getContentSize().width/3*2)
        end
        if appStorePayBtn then
            appStorePayBtn:hide()
        end
    end
    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function HallPayTypeWidget:closeWidget(retType)
	if self.callBack then
		self.callBack(retType)
    	self:removeFromParent()
	end
end

return HallPayTypeWidget