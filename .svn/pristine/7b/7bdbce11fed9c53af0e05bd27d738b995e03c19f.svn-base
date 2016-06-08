--
-- Author: Your Name
-- Date: 2015-10-26 13:45:20
--
local SetTableLockWidget = class("SetTableLockWidget")

function SetTableLockWidget:ctor(parentNode,callBack)
    if not parentNode then
        return
    end
    local node, width, height = cc.uiloader:load(WIDGET_SET_TABLE_LOCK_CSB_FILE)
    if not node then
        return
    end

    local inputBg = cc.uiloader:seekNodeByName(node, "Image_InputBg")
    local buttonOK = cc.uiloader:seekNodeByName(node, "Button_Ok")
    local buttonCancel = cc.uiloader:seekNodeByName(node, "Button_Cancel")
    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")

    -- 创建输入框
    if inputBg then
        self.EditPwd = cc.ui.UIInput.new({
                image="#pic/plazacenter/Sundry/u_input_bg.png",
                x=inputBg:getContentSize().width/2,
                y=inputBg:getContentSize().height/2,
                size=inputBg:getContentSize() })
        self.EditPwd:setInputFlag(0)
        self.EditPwd:setFontColor(cc.c3b(112,55,10))
        self.EditPwd:setFontSize(28)
        self.EditPwd:setFontName("微软雅黑")
        self.EditPwd:setPlaceHolder("点击输入桌子进入密码")
        self.EditPwd:setPlaceholderFont("微软雅黑",28)
        self.EditPwd:setMaxLength(31) 
        inputBg:addChild(self.EditPwd)
    end

    self:buttonTouchEvent(buttonOK)
    buttonOK:onButtonClicked(function ()
        if string.len(self.EditPwd:getText())<1 then
            return
        end
        if callBack then
            callBack(self.EditPwd:getText())
        end
        node:removeFromParent()
    end)
    self:buttonTouchEvent(buttonCancel)
    buttonCancel:onButtonClicked(function ()
        node:removeFromParent()
    end)

    parentNode:addChild(node)
    G_ShowNodeWithBackout(bgnode)
end

function SetTableLockWidget:buttonTouchEvent(btn)
    if btn then
        btn:onButtonPressed(function ()
            btn:scaleTo(0.1,0.9)
        end)
        btn:onButtonRelease(function ()
            btn:scaleTo(0.1,1)
        end)
    end
end

return SetTableLockWidget