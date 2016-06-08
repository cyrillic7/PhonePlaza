--
-- Author: SuperM
-- Date: 2016-01-18 10:33:26
--

local HallBagUseGoodWidget = class("HallBagUseGoodWidget")

function HallBagUseGoodWidget:ctor(parentNode,info,callBack)
    if not parentNode then
        return
    end
    local node, width, height = cc.uiloader:load(WIDGET_BAG_USE_CSB_FILE)
    if not node then
        return
    end

    local inputBg = cc.uiloader:seekNodeByName(node, "Image_InputBg")
    local buttonOK = cc.uiloader:seekNodeByName(node, "Button_Ok")
    local buttonCancel = cc.uiloader:seekNodeByName(node, "Button_Cancel")
    local labelNoName = cc.uiloader:seekNodeByName(node, "Label_NoName")
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
        self.EditCount:setPlaceholderFont("微软雅黑",28)
        self.EditCount:setMaxLength(14)
        inputBg:addChild(self.EditCount)
    end

    self:buttonTouchEvent(buttonOK)
    buttonOK:onButtonClicked(function ()
        if string.len(self.EditCount:getText())<1 then
            return
        end
        if callBack then
            callBack(self.EditCount:getText())
        end
        node:removeFromParent()
    end)
    self:buttonTouchEvent(buttonCancel)
    buttonCancel:onButtonClicked(function ()
        node:removeFromParent()
    end)

    if labelNoName and desc then
    	-- 兑换话费 5
    	if info.dwUseType == 5 then
    		labelNoName:setString("手机号码:")
    		desc:setString("请确认手机号码输入无误!")
    	-- 兑换Q币
    	elseif info.dwUseType == 6 then
    		labelNoName:setString("QQ号码:")
    		desc:setString("请确认QQ号码输入无误!")
    	end
    end
    if title then
        title:setString(info.szName)
    end
    if imgGoodPic then
        imgGoodPic:setTexture("download/"..info.szImgName..".png")
    end

    parentNode:addChild(node)
    G_ShowNodeWithBackout(bgnode)
end

function HallBagUseGoodWidget:buttonTouchEvent(btn)
    if btn then
        btn:onButtonPressed(function ()
            btn:scaleTo(0.1,0.9)
        end)
        btn:onButtonRelease(function ()
            btn:scaleTo(0.1,1)
        end)
    end
end

return HallBagUseGoodWidget