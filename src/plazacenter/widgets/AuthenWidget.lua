--
-- Author: SuperM
-- Date: 2015-11-17 20:45:36
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local AuthenWidget = class("AuthenWidget", XWWidgetBase)

function AuthenWidget:ctor(parentNode,callBack)
	AuthenWidget.super.ctor(self)

	self.callBack = callBack

	self:addTo(parentNode)
end

function AuthenWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	AuthenWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_AUTHEN_CSB_FILE)
    if not node then
        return
    end

    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Cancel")
    local okBtn = cc.uiloader:seekNodeByName(node, "Button_Ok")
    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    local imgNumberBg = cc.uiloader:seekNodeByName(node, "Image_NumberBg")
    
    if closeBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
    	closeBtn:onButtonClicked(function ()
            if self.callBack then
                self.callBack()
            end
    		self:removeFromParent()
    	end)    	
    end
    if okBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(okBtn)
    	okBtn:onButtonClicked(function ()
    		self:onOkBtnClicked()
    	end) 
    end
    if imgNumberBg then
        self.NumberEdit = cc.ui.UIInput.new({image="#pic/plazacenter/Sundry/u_input_bg.png",
                            x=imgNumberBg:getContentSize().width/2,
                            y=imgNumberBg:getContentSize().height/2,
                            size=imgNumberBg:getContentSize() })
        self.NumberEdit:setFontColor(cc.c3b(83,75,68))
        self.NumberEdit:setFontSize(28)
        self.NumberEdit:setFontName("微软雅黑")
        self.NumberEdit:setPlaceHolder("点击输入身份证号码")
        self.NumberEdit:setPlaceholderFont("微软雅黑",28)
        self.NumberEdit:setMaxLength(32)
        imgNumberBg:addChild(self.NumberEdit)
    end
    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function AuthenWidget:onCleanup()
	AuthenWidget.super.onCleanup(self)

	if self.missionItem then
		self.missionItem:removeServiceClient()
		self.missionItem = nil
	end
end

function AuthenWidget:onOkBtnClicked()
    local strNumber = self.NumberEdit:getText()
	local bSucc,strDesc = G_EfficacyPassPortID(strNumber)
    if not bSucc then
        local dataMsgBox = {
            nodeParent=self,
            msgboxType=MSGBOX_TYPE_OK,
            msgInfo=strDesc
        }
        require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
        return
    end

    if self.callBack then
        self.callBack(strNumber)
    end
    self:removeFromParent()
end

return AuthenWidget