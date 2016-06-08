--
-- Author: SuperM
-- Date: 2016-01-25 14:56:13
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local HallWXInviteWidget = class("HallWXInviteWidget", XWWidgetBase)

function HallWXInviteWidget:ctor(parentNode,callBack)
	HallWXInviteWidget.super.ctor(self)

	self.callBack = callBack

	self:addTo(parentNode)
end

function HallWXInviteWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
	HallWXInviteWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_HALL_WXINVITE_CSB_FILE)
    if not node then
        return
    end

    local closeBtn = cc.uiloader:seekNodeByName(node, "Button_Close")
    local shareBtn = cc.uiloader:seekNodeByName(node, "Button_WXShare")
    local sendMsgBtn = cc.uiloader:seekNodeByName(node, "Button_WXSendMsg")
    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")
    
    if closeBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(closeBtn)
    	closeBtn:onButtonClicked(function ()
            if self.callBack then
                self.callBack()
            end
    		self:removeFromParent()
    	end)    	
    end
    if shareBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(shareBtn)
    	shareBtn:onButtonClicked(function ()
    		self:onOperateBtnClicked(true)
    	end) 
    end
    if sendMsgBtn then
    	AppBaseInstanse.PLAZACENTER_APP:buttonTouchEvent(sendMsgBtn)
    	sendMsgBtn:onButtonClicked(function ()
    		self:onOperateBtnClicked(false)
    	end) 
    end
    
    self:addChild(node)

    G_ShowNodeWithBackout(bgnode)
end

function HallWXInviteWidget:onCleanup()
	HallWXInviteWidget.super.onCleanup(self)
end

function HallWXInviteWidget:onOperateBtnClicked(bShare)
    self:removeFromParent()

    local wxURL = "http://hdapp.719you.com/YS151226WeiXin/index.html?UserID="..GlobalUserInfo.dwUserID
    local wxTitle = "719游戏"
    local wxDesc = "注册有礼，百分百中奖，玩阳山打九张，赢百元话费，快来和我一起嘿嘿嘿吧"
    if device.platform == "android" then
    	if bShare then
    		luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "shareMsgToWX", {wxURL,wxDesc}, "(Ljava/lang/String;Ljava/lang/String;)V")
    	else
    		luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "sendMsgToWX", {wxURL,wxDesc}, "(Ljava/lang/String;Ljava/lang/String;)V")
    	end
    elseif device.platform == "ios" then
    	if bShare then
    		luaoc.callStaticMethod("LuaCallObjcFuncs", "shareMsgToWX", 
    			{url=wxURL,title=wxTitle,desc=wxDesc})
    	else
    		luaoc.callStaticMethod("LuaCallObjcFuncs", "sendMsgToWX", 
    			{url=wxURL,title=wxTitle,desc=wxDesc})
    	end
    end
end

return HallWXInviteWidget