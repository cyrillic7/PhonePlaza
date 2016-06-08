local CommonMsgBoxWidget = class("CommonMsgBoxWidget")

function CommonMsgBoxWidget:ctor(data)
    --[[data={
        nodeParent,
        msgboxType,
        callBack,
        msgTitle,
        msgInfo
    }]]
    if data.nodeParent == nil then
        return
    end
    local node, width, height = cc.uiloader:load(COMMON_MSGBOX_WIDGET_CSB_FILE)
    if not node then
    	return
    end

    local baseNode = ccui.Widget:create()
    baseNode:addChild(node)
    baseNode:setTouchEnabled(true)
    baseNode:setContentSize(display.width,display.height)
    baseNode:setPosition(display.cx,display.cy)

    self.callBack=data.callBack
    self.msgBoxNode=baseNode
    local buttonClose = cc.uiloader:seekNodeByName(node, "buttonClose")
    local buttonOK = cc.uiloader:seekNodeByName(node, "buttonOK")
    local buttonCancel = cc.uiloader:seekNodeByName(node, "buttonCancel")
    local bgnode = cc.uiloader:seekNodeByName(node, "bg")
    if data.msgboxType == MSGBOX_TYPE_OK then
        if buttonClose ~= nil then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(buttonClose)
            buttonClose:onButtonClicked(handler(self,self.onCloseOrOKButtonClicked))
            G_uiWidgetVirtualBtn(buttonClose,cc.size(150,60))
        end
        if buttonOK ~= nil then
            buttonOK:setVisible(false)
        end
        if buttonCancel ~= nil then
            buttonCancel:setVisible(false)
        end
    else
        if buttonClose ~= nil then
            buttonClose:setVisible(false)
        end
        if buttonOK ~= nil then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(buttonOK)
            buttonOK:onButtonClicked(handler(self,self.onCloseOrOKButtonClicked))
            G_uiWidgetVirtualBtn(buttonOK,cc.size(150,60))
        end
        if buttonCancel ~= nil then
            AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(buttonCancel)
            buttonCancel:onButtonClicked(handler(self,self.onCancelButtonClicked))
            G_uiWidgetVirtualBtn(buttonCancel,cc.size(150,60))
        end
    end
    if data.msgInfo ~= nil then
        local infoLabel = cc.uiloader:seekNodeByName(node, "LabelInfo")
        if infoLabel ~= nil then
            infoLabel:setString(data.msgInfo)
        end
    end

    data.nodeParent:addChild(baseNode)
    G_ShowNodeWithBackout(bgnode)
end

function CommonMsgBoxWidget:onCloseOrOKButtonClicked()
    if self.msgBoxNode ~= nil then
        self.msgBoxNode:removeFromParent()
    end
    if self.callBack ~= nil then
        self.callBack(MSGBOX_RETURN_OK)
    end
end

function CommonMsgBoxWidget:onCancelButtonClicked()
    if self.msgBoxNode ~= nil then
        self.msgBoxNode:removeFromParent()
        self.msgBoxNode = nil
    end
    if self.callBack ~= nil then
        self.callBack(MSGBOX_RETURN_CANCEL)
        self.callBack=nil
    end
end

return CommonMsgBoxWidget