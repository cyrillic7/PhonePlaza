--
-- Author: SuperM
-- Date: 2016-01-20 14:11:36
--
local XWWidgetBase = require("plazacenter.widgets.XWWidgetBase")
local FriendsPlayWidget = class("FriendsPlayWidget", XWWidgetBase)


function FriendsPlayWidget:ctor(parentNode)
	FriendsPlayWidget.super.ctor(self)

	self:addTo(parentNode)
end

function FriendsPlayWidget:onEnter()
    if not self.bFirstEnter then
        return
    end
    FriendsPlayWidget.super.onEnter(self)

    local node, width, height = cc.uiloader:load(WIDGET_FRIEND_PLAY_CSB_FILE)
    if not node then
        return
    end

    local shareBtn = cc.uiloader:seekNodeByName(node, "Button_WXShare")
    local sendMsgBtn = cc.uiloader:seekNodeByName(node, "Button_WXSendMsg")
    local bgnode = cc.uiloader:seekNodeByName(node, "Image_Animation")

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
end

function FriendsPlayWidget:onCleanup()
    FriendsPlayWidget.super.onCleanup(self)
end

function FriendsPlayWidget:cleanPlistRes()
    print("FriendsPlayWidget:cleanPlistRes")
    display.removeSpriteFramesWithFile("UIHallFriend.plist", "UIHallFriend.png")
end

function FriendsPlayWidget:onOperateBtnClicked(bShare)
    local wxURL = "http://m.719you.com/?UserID="..GlobalUserInfo.dwUserID
    local wxTitle = "719游戏"
    local wxDesc = "快来一起玩正规棋牌游戏！我在719游戏大厅等着你！"
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

return FriendsPlayWidget

