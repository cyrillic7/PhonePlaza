--
-- Author: Your Name
-- Date: 2015-10-26 13:45:20
--
local HallBagExchangeWidget = class("HallBagExchangeWidget")

function HallBagExchangeWidget:ctor(parentNode,info,callBack)
    if not parentNode then
        return
    end
    local node, width, height = cc.uiloader:load(WIDGET_BAG_EXCHANGE_CSB_FILE)
    if not node then
        return
    end

    local inputBg = cc.uiloader:seekNodeByName(node, "Image_InputBg")
    local buttonOK = cc.uiloader:seekNodeByName(node, "Button_Ok")
    local buttonCancel = cc.uiloader:seekNodeByName(node, "Button_Cancel")
    local buttonMax = cc.uiloader:seekNodeByName(node, "Button_Max")
    local title = cc.uiloader:seekNodeByName(node, "Label_Title")
    local desc = cc.uiloader:seekNodeByName(node, "Label_Desc")
    local imgGoodPic = cc.uiloader:seekNodeByName(node, "Image_Pic")
    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")

    -- 创建输入框
    if inputBg then
    	local editSize = inputBg:getContentSize()
    	editSize.width = 190
        self.EditCount = cc.ui.UIInput.new({
                image="#pic/plazacenter/Sundry/u_null.png",
                x=editSize.width/2,
                y=editSize.height/2,
                size=editSize })
        self.EditCount:setInputFlag(3)
        self.EditCount:setFontColor(cc.c3b(112,55,10))
        self.EditCount:setFontSize(28)
        self.EditCount:setFontName("微软雅黑")
        self.EditCount:setPlaceHolder("点击输入数量")
        self.EditCount:setPlaceholderFont("微软雅黑",28)
        self.EditCount:setMaxLength(14) 
        self.EditCount:setText(tostring(info.dwNum))
        inputBg:addChild(self.EditCount)
    end

    self:buttonTouchEvent(buttonOK)
    buttonOK:onButtonClicked(function ()
        if string.len(self.EditCount:getText())<1 then
            return
        end
        if not tonumber(self.EditCount:getText()) then
            local dataMsgBox = {
                nodeParent=node,
                msgboxType=MSGBOX_TYPE_OK,
                msgInfo="请正确填写兑换数量！"
            }
            require("plazacenter.widgets.CommonMsgBoxWidget").new(dataMsgBox)
            return
        end
        if callBack then
            callBack(tonumber(self.EditCount:getText()))
        end
        node:removeFromParent()
    end)
    self:buttonTouchEvent(buttonCancel)
    buttonCancel:onButtonClicked(function ()
        node:removeFromParent()
    end)
    self:buttonTouchEvent(buttonMax)
    buttonMax:onButtonClicked(function ()
        self.EditCount:setText(tostring(info.dwNum))
    end)

    if title then
        title:setString(info.szName)
    end
    if desc then
        desc:setString(info.szRemark)
    end
    if imgGoodPic then
        imgGoodPic:setTexture("download/"..info.szImgName..".png")
    end

    parentNode:addChild(node)
    G_ShowNodeWithBackout(bgnode)
end

function HallBagExchangeWidget:buttonTouchEvent(btn)
    if btn then
        btn:onButtonPressed(function ()
            btn:scaleTo(0.1,0.9)
        end)
        btn:onButtonRelease(function ()
            btn:scaleTo(0.1,1)
        end)
    end
end

return HallBagExchangeWidget